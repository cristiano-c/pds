#include <types.h>
#include <kern/errno.h>
#include <kern/unistd.h>
#include <lib.h>
#include <uio.h>
#include <syscall.h>
#include <vnode.h>
#include <vfs.h>
#include <vm.h>
#include <current.h>
#include <synch.h>
#include <proc.h>
#include <mips/trapframe.h>
#include <addrspace.h>

struct parent_info{
	struct addrspace *as;
	struct trapframe *tf;
};

struct parent_info pi;

void fork_process(void *info, unsigned long dummy);

int sys_fork(struct trapframe *tfp, int32_t *retval) {
  
	struct proc *p_child;
	int err;

	/* Create a process for the new program to run in. */
	p_child = proc_create_runprogram(curproc->p_name /* name */);
	if (p_child == NULL) {
		return ENOMEM;
	}

	pi.tf = tfp;
	pi.as = curproc->p_addrspace;
	
	err = thread_fork(curproc->p_name /* thread name */,
			p_child /* new process */,
			fork_process /* fork function */,
			&pi /* thread arg */, 0 /* thread arg */);
	if (err) {
		proc_destroy(p_child);
		return err;
	}	

	*retval = p_child->p_pid;

  	return 0;
}

void fork_process(void *info, unsigned long dummy){
	struct parent_info *pip = (struct parent_info *) info;
	struct addrspace *as, *asp = pip->as;
	struct trapframe *tfp = pip->tf;

	int err = 0;
	(void)dummy;

	err = as_copy(asp, &as);

	if(err)
		return;

	proc_setas(as);
	as_activate(); //TLB
	  
	enter_forked_process(tfp);

}

int sys__exit(int code) {
	struct proc *p = curproc;

	lock_acquire(curthread->t_proc->lock);

	p->exit_code = code;
	
	cv_signal(curthread->t_proc->wait,curthread->t_proc->lock);

	lock_release(curthread->t_proc->lock);

	curthread->exitCode = code;

	kprintf("exit code: %d\n", code);

  	thread_exit();

  	return 0;
}


