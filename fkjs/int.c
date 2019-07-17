#include "bootpack.h"
#include <stdio.h>
#define PORT_KEYDAT		0x0060

/* PIC0����PIC�CPIC1����PIC�CPIC1�I�I���f��?IRQ2(11111011)?��?PIC0��?CPU */
void init_pic(void)
/* PIC���n�� */
{
	io_out8(PIC0_IMR,  0xff  ); /* �֎~���L���f */
	io_out8(PIC1_IMR,  0xff  ); /* �֎~���L���f */

	io_out8(PIC0_ICW1, 0x11  ); /* ?���G?�͎� */
	io_out8(PIC0_ICW2, 0x20  ); /* IRQ0-7�RINT20-27�ڎ� */
	io_out8(PIC0_ICW3, 1 << 2); /* PIC1�RIRQ2�ڎ� */
	io_out8(PIC0_ICW4, 0x01  ); /* ��?�t��͎� */

	io_out8(PIC1_ICW1, 0x11  ); /* ?���G?�͎� */
	io_out8(PIC1_ICW2, 0x28  ); /* IRQ8-15�RINT28-2f�ڎ� */
	io_out8(PIC1_ICW3, 2     ); /* PIC1�RIRQ2�ڎ� */
	io_out8(PIC1_ICW4, 0x01  ); /* ��?�t��͎� */

	io_out8(PIC0_IMR,  0xfb  ); /* 11111011 PIC1�ȊO�S���֎~ */
	io_out8(PIC1_IMR,  0xff  ); /* 11111111 �֎~���L���f */

	return;
}

void inthandler27(int *esp)
{
	io_out8(PIC0_OCW2, 0x67); /* IRQ-07�ܸ����ˤ�PIC��֪ͨ(7-1����) */
	return;
}