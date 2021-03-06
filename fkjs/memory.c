#include "bootpack.h"

#define EFLAGS_AC_BIT		0x00040000
#define CR0_CACHE_DISABLE	0x60000000

unsigned int memtest(unsigned int start, unsigned int end)
{
	char flg486 = 0;
	unsigned int eflg, cr0, i;

	/* »fCPU₯386?₯486Θγ */
	eflg = io_load_eflags();
	eflg |= EFLAGS_AC_BIT; /* AC-bit = 1 */
	io_store_eflags(eflg);
	eflg = io_load_eflags();
	if ((eflg & EFLAGS_AC_BIT) != 0) { /* @Κ₯386C¦g?θAC=1CACI??ο©?ρ0 */
		flg486 = 1;
	}
	eflg &= ~EFLAGS_AC_BIT; /* AC-bit = 0 */
	io_store_eflags(eflg);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 |= CR0_CACHE_DISABLE; /* Φ~?Ά */
		store_cr0(cr0);
	}

	i = memtest_sub(start, end);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 &= ~CR0_CACHE_DISABLE; /* ς??Ά */
		store_cr0(cr0);
	}
	return i;
}

void memman_init(struct MEMMAN *man)
{
	man->frees = 0;			/* ]ΰΆi */
	man->maxfrees = 0;		/* Ε½ΒΆΊIΰΆi */
	man->lostsize = 0;		/* ?ϊΈ?ΰΆIsize */
	man->losts = 0;			/* ?ϊΈ?ΰΆ’ */
	return;
}

/* ]ΰΆsize */
unsigned int memman_total(struct MEMMAN *man)
{
	unsigned int i, t = 0;
	for (i = 0; i < man->frees; i++) {
		t += man->free[i].size;
	}
	return t;
}

/* ?sizeε¬Iσ? */
unsigned int memman_alloc(struct MEMMAN *man, unsigned int size)
{
	unsigned int i, a;
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].size >= size) {
			a = man->free[i].addr;
			man->free[i].addr += size;
			man->free[i].size -= size;
			if (man->free[i].size == 0) {
				/* ?ΰΆ³DSͺz???ΰΆi */
				man->frees--;
				for (; i < man->frees; i++) {
					man->free[i] = man->free[i + 1];
				}
			}
			return a;
		}
	}
	return 0; /* ͺzΈ? */
}

/* ?ϊΈaddr?nIsizeε¬ΰΆ */
int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size) {
	int i, j;
	/* Βn¬rCζQ?ϊΰΆaddrIΚu */
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].addr > addr) {
			break;
		}
	}
	/* free[i - 1].addr < addr < free[i].addr */
	if (i > 0) {
		if (man->free[i - 1].addr + man->free[i - 1].size == addr) { /* Β^OΚΰΆ¬ */
			man->free[i - 1].size += size;
			if (i < man->frees) {	/* ΒO@s¬ */
				if (addr + size == man->free[i].addr) { /* @Κ?ΒΘa@Κ? */
					man->free[i - 1].size += man->free[i].size;
					man->frees--;
					for (; i < man->frees; i++) { // c@ΚLΰΆόOΪ?κ?
						man->free[i] = man->free[i + 1];
					}
				}
			}
			return 0; /* ??¬χ */
		}
	}
	
	if (i < man->frees) { /* Β^@ΚΰΆ¬ */
		if (addr + size == man->free[i].addr) {
			man->free[i].addr = addr;
			man->free[i].size += size;
			return 0;
		}
	}
	
	if (man->frees < MEMMAN_FREES) {/* s\^OΚ¬Cηs\^@Κ¬ ―? ΰΆΗ?ΒΘϊΑ */
		for (j = man->frees; j > i; j--) { // ΈiV@CLΰΆi@ΪκΚ
			man->free[j] = man->free[j - 1];
		}
		man->frees++;
		if (man->maxfrees < man->frees) {
			man->maxfrees = man->frees; /* ϊΑκ’ */
		}
		man->free[i].addr = addr;
		man->free[i].size = size;
		return 0;
	}
	/* ρΎΈ? */
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
