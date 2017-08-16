#include <types.h>
#include <kern/errno.h>
#include <kern/unistd.h>
#include <lib.h>
#include <uio.h>
#include <syscall.h>
#include <vnode.h>
#include <vfs.h>
#include <proc.h>
#include <current.h>

#define BUFFER_SIZE 21 // '\0' compreso -> l'utente può digitare fino a 20 caratteri in una sola volta

#define MAXF 100
struct vnode *fdTable[MAXF];
int currFid=3;

int sys_write(int fd, const char * buffer, int nBytes, int *retval) {
  int i,result;

   switch(fd){
	case 0: kprintf("Error - cannot print stdinput\n");
	*retval = -1;
	break;

	case 1:

	case 2:
  		for (i = 0; i < nBytes; ++i){
		    putch((buffer)[i]);
		}
		*retval = nBytes; // numero di caratteri scritti
		break;
	default:{
		struct iovec iov;
		struct uio u;
		struct vnode *v = fdTable[fd];

		KASSERT(v!=NULL);
		iov.iov_ubase = (userptr_t)buffer;
		iov.iov_len = nBytes;
		u.uio_iov = &iov;
		u.uio_iovcnt = 1;
		u.uio_resid = nBytes;
		u.uio_offset = 0;
		u.uio_segflg = UIO_USERSPACE;
		u.uio_rw = UIO_WRITE;
		u.uio_space = curproc->p_addrspace;

		result = VOP_WRITE(v, &u);
		*retval = nBytes - u.uio_resid;
		}
		break;
	}
  return result;
}

int sys_read(int fd, char * buffer, int nBytes, int *retval){
    int i,result;
    char c;

   switch(fd){
	case 0:
		for (i = 0; i < nBytes; i++){
		    c = getch();
		    *(buffer+i) = c;
		}
		*retval = nBytes; // numero di caratteri letti
		break;

	case 1:

	case 2: 
		kprintf("Error - sys_read\n");
		*retval = -1;
		break;
  		
	default:{
		struct iovec iov;
		struct uio u;
		struct vnode *v = fdTable[fd];

		KASSERT(v!=NULL);
		iov.iov_ubase = (userptr_t)buffer;
		iov.iov_len = nBytes;
		u.uio_iov = &iov;
		u.uio_iovcnt = 1;
		u.uio_resid = nBytes;
		u.uio_offset = 0;
		u.uio_segflg = UIO_USERSPACE;
		u.uio_rw = UIO_READ;
		u.uio_space = curproc->p_addrspace;

		result = VOP_READ(v, &u);
		*retval = nBytes - u.uio_resid;
		}
		break;
	}
  return result;
}


int sys_open(const char *filename, int flags){
	struct vnode *v;
	int fd, result;

	result = vfs_open((char *)filename, flags, 0, &v);

	if(result) return -1;
	if(currFid>=MAXF)return -1;

	fd = currFid++;
	fdTable[fd] = v;

	return fd;
}

int sys_close(int fd){
	if(fd<3 || fd>=MAXF) return -1;
	if(fdTable[fd]==NULL) return -1;

	vfs_close(fdTable[fd]);
	fdTable[fd]=NULL;

	return 0;
}

//remove finta non rimuove veramente..
int sys_remove(char *filename){
	int result;

	result = vfs_remove(filename);
	kprintf("File non eliminato veramente.\n");

	if(result) return -1;

	return 0;
}
