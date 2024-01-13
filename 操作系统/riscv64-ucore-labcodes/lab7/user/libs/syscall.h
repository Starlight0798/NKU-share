#ifndef __USER_LIBS_SYSCALL_H__
#define __USER_LIBS_SYSCALL_H__

int sys_exit(int64_t error_code);
int sys_fork(void);
int sys_wait(int64_t pid, int *store);
int sys_yield(void);
int sys_kill(int64_t pid);
int sys_getpid(void);
int sys_putc(int64_t c);
int sys_pgdir(void);
int sys_gettime(void);
/* FOR LAB6 ONLY */
void sys_lab6_set_priority(uint64_t priority);

int sys_sleep(uint64_t time);

#endif /* !__USER_LIBS_SYSCALL_H__ */

