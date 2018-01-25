#include <types.h>
#include <kern/errno.h>
#include <kern/unistd.h>
#include <lib.h>
#include <uio.h>
#include <syscall.h>
#include <vnode.h>
#include <vfs.h>
#include <current.h>

int sys_write(int fd, const void* buf, size_t nbytes, int* retval){
//int sys_write(userptr_t buffer, int nBytes, int *retval) {
  size_t i;
  for (i = 0; i < nbytes; ++i)
    kprintf("%c %d", ((char*)buf)[i], fd);

  *retval = 1; // numero di caratteri scritti
  return 0;
}
