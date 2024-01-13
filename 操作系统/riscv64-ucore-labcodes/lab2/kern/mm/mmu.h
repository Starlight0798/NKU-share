#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif


#define PGSIZE          4096                    // bytes mapped by a page
#define PGSHIFT         12                      // log2(PGSIZE)

// physical/virtual page number of address
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)

// Sv39 linear address structure
// +-------9--------+-------9--------+--------9---------+----------12----------+
// |      VPN2      |      VPN1      |       VPN0       |  Offset within Page  |
// +----------------+----------------+------------------+----------------------+

// Sv39 in RISC-V64 uses 39-bit virtual address to access 56-bit physical address!
// Sv39 page table entry:
// +-------10--------+--------26-------+--------9----------+--------9--------+---2----+-------8-------+
// |    Reserved     |      PPN[2]     |      PPN[1]       |      PPN[0]     |Reserved|D|A|G|U|X|W|R|V|
// +-----------------+-----------------+-------------------+-----------------+--------+---------------+

/* page directory and page table constants */
#define SV39_NENTRY          512                     // page directory entries per page directory

#define SV39_PGSIZE          4096                    // bytes mapped by a page
#define SV39_PGSHIFT         12                      // log2(PGSIZE)
#define SV39_PTSIZE          (PGSIZE * SV39NENTRY)   // bytes mapped by a page directory entry
#define SV39_PTSHIFT         21                      // log2(PTSIZE)

#define SV39_VPN0SHIFT       12                      // offset of VPN0 in a linear address
#define SV39_VPN1SHIFT       21                      // offset of VPN1 in a linear address
#define SV39_VPN2SHIFT       30                      // offset of VPN2 in a linear address
#define SV39_PTE_PPN_SHIFT   10                      // offset of PPN in a physical address

#define SV39_VPN0(la) ((((uintptr_t)(la)) >> SV39_VPN0SHIFT) & 0x1FF)
#define SV39_VPN1(la) ((((uintptr_t)(la)) >> SV39_VPN1SHIFT) & 0x1FF)
#define SV39_VPN2(la) ((((uintptr_t)(la)) >> SV39_VPN2SHIFT) & 0x1FF)
#define SV39_VPN(la, n) ((((uintptr_t)(la)) >> 12 >> (9 * n)) & 0x1FF)

// construct linear address from indexes and offset
#define SV39_PGADDR(v2, v1, v0, o) ((uintptr_t)((v2) << SV39_VPN2SHIFT | (v1) << SV39_VPN1SHIFT | (v0) << SV39_VPN0SHIFT | (o)))

// address in page table or page directory entry
#define SV39_PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x1FF) << 3)

// 3-level pagetable
#define SV39_PT0                 0
#define SV39_PT1                 1
#define SV39_PT2                 2

// page table entry (PTE) fields
#define PTE_V     0x001 // Valid
#define PTE_R     0x002 // Read
#define PTE_W     0x004 // Write
#define PTE_X     0x008 // Execute
#define PTE_U     0x010 // User
#define PTE_G     0x020 // Global
#define PTE_A     0x040 // Accessed
#define PTE_D     0x080 // Dirty
#define PTE_SOFT  0x300 // Reserved for Software

#define PAGE_TABLE_DIR (PTE_V)
#define READ_ONLY (PTE_R | PTE_V)
#define READ_WRITE (PTE_R | PTE_W | PTE_V)
#define EXEC_ONLY (PTE_X | PTE_V)
#define READ_EXEC (PTE_R | PTE_X | PTE_V)
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)

#endif /* !__KERN_MM_MMU_H__ */

