#include <types.h>
#include <kern/errno.h>
#include <kern/unistd.h>
#include <lib.h>
#include <uio.h>
#include <syscall.h>
#include <vnode.h>
#include <vfs.h>
#include <current.h>

#define jumpwrite false


/*
- int fd = file id -> è dove si vorebbe stampare per semplicità si usa sempre lo schermo :(
- const void* buf -> è la stringa da stampare
- size_t nbytes -> è la dimesione che si vuole stampare ossia la lunghezza della stringa
poiché non è obbligatorio che finisca per \0
- int* retval -> è quanti carratteri si è stampati, per semplicità di ritorno se c'è stato un errore si ritorna -1
[da chiedere]-> ma questa funzione cosa ritorna, c'è uno standard da seguire o si possono fare cose a muzzo visto che il kernel
è "personale"? E la funzine che l'ha chiamata cosa saprà?
*/

#if jumwrite
int sys_write(int fd, const void* buf, size_t nbytes, int* retval)
#else
int sys_write(const void* buf, size_t nbytes, int* retval)
#endif
{
  size_t i=0;
  if(!buf)
  {
    //In realtà si dovrebbe usare errno e la costante EFAULT
    return -1;
  }
  for (i = 0; i < nbytes; ++i)
  {
    if(-1==kprintf("%c", ((char*)buf)[i]))
#if jumwrite
    return *retval;
#else
  return 0;
#endif
    *retval = *retval + 1;
  }

  return 0;
}
