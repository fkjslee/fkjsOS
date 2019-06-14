#include "bootpack.h"

#define EFLAGS_AC_BIT		0x00040000
#define CR0_CACHE_DISABLE	0x60000000

unsigned int memtest(unsigned int start, unsigned int end)
{
	char flg486 = 0;
	unsigned int eflg, cr0, i;

	/* 判断CPU是386?是486以上 */
	eflg = io_load_eflags();
	eflg |= EFLAGS_AC_BIT; /* AC-bit = 1 */
	io_store_eflags(eflg);
	eflg = io_load_eflags();
	if ((eflg & EFLAGS_AC_BIT) != 0) { /* 如果是386，即使?定AC=1，AC的??会自?回到0 */
		flg486 = 1;
	}
	eflg &= ~EFLAGS_AC_BIT; /* AC-bit = 0 */
	io_store_eflags(eflg);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 |= CR0_CACHE_DISABLE; /* 禁止?存 */
		store_cr0(cr0);
	}

	i = memtest_sub(start, end);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 &= ~CR0_CACHE_DISABLE; /* 允??存 */
		store_cr0(cr0);
	}
	return i;
}

void memman_init(struct MEMMAN *man)
{
	man->frees = 0;			/* 剩余内存段 */
	man->maxfrees = 0;		/* 最多可存下的内存段 */
	man->lostsize = 0;		/* ?放失?内存的size */
	man->losts = 0;			/* ?放失?内存个数 */
	return;
}

/* 剩余内存size */
unsigned int memman_total(struct MEMMAN *man)
{
	unsigned int i, t = 0;
	for (i = 0; i < man->frees; i++) {
		t += man->free[i].size;
	}
	return t;
}

/* ?求size大小的空? */
unsigned int memman_alloc(struct MEMMAN *man, unsigned int size)
{
	unsigned int i, a;
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].size >= size) {
			a = man->free[i].addr;
			man->free[i].addr += size;
			man->free[i].size -= size;
			if (man->free[i].size == 0) {
				/* ?内存正好全部分配??去?内存段 */
				man->frees--;
				for (; i < man->frees; i++) {
					man->free[i] = man->free[i + 1];
				}
			}
			return a;
		}
	}
	return 0; /* 分配失? */
}

/* ?放从addr?始的size大小内存 */
int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size) {
	int i, j;
	/* 按地址排序，先找到?放内存addr的位置 */
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].addr > addr) {
			break;
		}
	}
	/* free[i - 1].addr < addr < free[i].addr */
	if (i > 0) {
		if (man->free[i - 1].addr + man->free[i - 1].size == addr) { /* 可与前面内存合成 */
			man->free[i - 1].size += size;
			if (i < man->frees) {	/* 可前后都合成 */
				if (addr + size == man->free[i].addr) { /* 如果?可以和后面?合 */
					man->free[i - 1].size += man->free[i].size;
					man->frees--;
					for (; i < man->frees; i++) { // 把后面所有内存向前移?一?
						man->free[i] = man->free[i + 1];
					}
				}
			}
			return 0; /* ??成功 */
		}
	}
	
	if (i < man->frees) { /* 可与后面内存合成 */
		if (addr + size == man->free[i].addr) {
			man->free[i].addr = addr;
			man->free[i].size += size;
			return 0;
		}
	}
	
	if (man->frees < MEMMAN_FREES) {/* 不能与前面合成，也不能与后面合成 同? 内存管理?可以增加 */
		for (j = man->frees; j > i; j--) { // 从i之后，所有内存段后移一位
			man->free[j] = man->free[j - 1];
		}
		man->frees++;
		if (man->maxfrees < man->frees) {
			man->maxfrees = man->frees; /* 增加一个 */
		}
		man->free[i].addr = addr;
		man->free[i].size = size;
		return 0;
	}
	/* 回收失? */
	man->losts++;
	man->lostsize += size;
	return -1;
}

unsigned int memman_alloc_4k(struct MEMMAN *man, unsigned int size)
{
	unsigned int a;
	size = (size + 0xfff) & 0xfffff000;
	a = memman_alloc(man, size);
	return a;
}

int memman_free_4k(struct MEMMAN *man, unsigned int addr, unsigned int size)
{
	int i;
	size = (size + 0xfff) & 0xfffff000;
	i = memman_free(man, addr, size);
	return i;
}
