#include <types.h>
#include <kern/errno.h>
#include <kern/unistd.h>
#include <lib.h>
#include <uio.h>
#include <syscall.h>
#include <vnode.h>
#include <vfs.h>
#include <current.h>

#define BUFFER_SIZE 900 // '\0' compreso -> l'utente può digitare fino a 900 caratteri in una sola volta


#define jumpwrite false

#if jumwrite
int sys_read(int fd, const void* buf, size_t buflen, int* retval)
#else
int sys_read(const void* buf, size_t buflen, int* retval);
#endif
{
  static char bufferStatico[BUFFER_SIZE];
  size_t i=0;
  int c = 0;
  for(i=0; i<size_t; i++)
  {
    c=kgetc();
    if(c==EOF)
      return -1;
    buf[i]=(char)c;
    *retval = *retval + 1;
  }
  return 0;
}
