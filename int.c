#include "bootpack.h"
#include <stdio.h>
#define PORT_KEYDAT		0x0060

/* PIC0惀庡PIC丆PIC1惀樃PIC丆PIC1揑揑拞抐捠?IRQ2(11111011)?憲?PIC0嵞?CPU */
void init_pic(void)
/* PIC弶巒壔 */
{
	io_out8(PIC0_IMR,  0xff  ); /* 嬛巭強桳拞抐 */
	io_out8(PIC1_IMR,  0xff  ); /* 嬛巭強桳拞抐 */

	io_out8(PIC0_ICW1, 0x11  ); /* ?増怗?柾幃 */
	io_out8(PIC0_ICW2, 0x20  ); /* IRQ0-7桼INT20-27愙庴 */
	io_out8(PIC0_ICW3, 1 << 2); /* PIC1桼IRQ2愙庴 */
	io_out8(PIC0_ICW4, 0x01  ); /* 澷?檛嬫柾幃 */

	io_out8(PIC1_ICW1, 0x11  ); /* ?増怗?柾幃 */
	io_out8(PIC1_ICW2, 0x28  ); /* IRQ8-15桼INT28-2f愙庴 */
	io_out8(PIC1_ICW3, 2     ); /* PIC1桼IRQ2愙庴 */
	io_out8(PIC1_ICW4, 0x01  ); /* 澷?檛嬫柾幃 */

	io_out8(PIC0_IMR,  0xfb  ); /* 11111011 PIC1埲奜慡晹嬛巭 */
	io_out8(PIC1_IMR,  0xff  ); /* 11111111 嬛巭強桳拞抐 */

	return;
}

void inthandler27(int *esp)
{
	io_out8(PIC0_OCW2, 0x67); /* IRQ-07受付完了をPICに通知(7-1参照) */
	return;
}