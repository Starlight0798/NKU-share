#ifndef _ASM_RISCV_SBI_H
#define _ASM_RISCV_SBI_H

typedef struct {
  unsigned long base;
  unsigned long size;
  unsigned long node_id;
} memory_block_info;

unsigned long sbi_query_memory(unsigned long id, memory_block_info *p);

void sbi_set_timer(unsigned long long stime_value);
void sbi_send_ipi(unsigned long hart_id);
unsigned long sbi_clear_ipi(void);
void sbi_shutdown(void);

void sbi_console_putchar(unsigned char ch);
int sbi_console_getchar(void);

#endif
