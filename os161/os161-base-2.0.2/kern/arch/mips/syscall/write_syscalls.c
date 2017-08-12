 /*
  * write_syscall.c
  *
  */

 #include <types.h>
 #include <kern/errno.h>
 #include <kern/reboot.h>
 #include <kern/unistd.h>
 #include <lib.h>
 #include <spl.h>
 #include <clock.h>
 #include <thread.h>
 #include <current.h>
 #include <synch.h>
 #include <vm.h>
 #include <vfs.h>
 #include <mainbus.h>
 #include <vfs.h>
 #include <vnode.h>
 #include <device.h>
 #include <syscall.h>
 #include <syscall.h>
 #include <kern/fcntl.h>
 #include <kern/file.h>

 /*
  * Write writes up to nbytes bytes to the file specified by fd, at the location
  * in the file specified by the current seek position of the file, taking the
  * data from the space pointed to by buf. The file must be open for writing.
  * The current seek position of the file is advanced by the number of bytes
  * written. Each write (or read) operation is atomic relative to other I/O to
  * the same file.
  *
  */

 int sys_write(int fd, const void* buf, size_t nbytes, int* retval)
 {
         struct file* fcb;
         struct uio u;
         struct iovec iov;
         int errno;
         int spl;

         /* Check if buf is valid */
         if (!buf) {

                 errno = EFAULT;
                 return errno;
         }

         /* Get fcb using fd as index of the open files table */
         fcb = curthread->table_fd[fd];

         /* Check if the open files table entry is valid */
         if ( fcb == NULL )
         {
                 errno = EBADF;
                 return errno;
         }

         /* Check if the file is opened in writing mode */
         if ( fcb->writeable != true ) {
                 errno = EBADF;
                 return errno;
         }

         /* Check if byte to write is more than one */
         if( nbytes < 1 ){
                 *retval = 0;
                 return 0;
         }


         iov.iov_ubase = (userptr_t)buf;         /* Location of the buffer */
         iov.iov_len = nbytes;                           /* Lenght of the buffer */

         /* Set up the uio for writing */
         u.uio_iov = &iov;
         u.uio_iovcnt = 1;
         u.uio_resid = nbytes;                   /* Amount of data to transfer */
         u.uio_offset = fcb->offset;
         u.uio_segflg = UIO_USERISPACE;
         u.uio_rw = UIO_WRITE;
         u.uio_space = curthread->t_addrspace;

         /* Make the write atomic for the file */
         spl = splhigh();

         /* Try to write the file */
         *retval = VOP_WRITE(fcb->vfs_node, &u);

         splx(spl);

         /* Check write result */
         if ( (*retval) ) {
                 errno = EIO;
                 return errno;
         }

         /* Return the number of bytes written to user */
         *retval = nbytes - u.uio_resid;

         /* Update seek position */
         fcb->offset += *retval;

         return 0;
 }
