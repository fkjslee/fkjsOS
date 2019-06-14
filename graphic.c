#include "bootpack.h"


void init_palette(void)
{
	static unsigned char table_rgb[16 * 3] = {
		0x00, 0x00, 0x00,	/*  0:麷怓 */
		0xff, 0x00, 0x00,	/*  1:椇?怓 */
		0x00, 0xff, 0x00,	/*  2:椇?怓 */
		0xff, 0xff, 0x00,	/*  3:椇墿怓 */
		0x00, 0x00, 0xff,	/*  4:椇惵怓 */
		0xff, 0x00, 0xff,	/*  5:椇巼怓 */
		0x00, 0xff, 0xff,	/*  6:愺椇? */
		0xff, 0xff, 0xff,	/*  7:敀怓 */
		0xc6, 0xc6, 0xc6,	/*  8:椇奃怓 */
		0x84, 0x00, 0x00,	/*  9:埫?怓 */
		0x00, 0x84, 0x00,	/* 10:埫椢怓 */
		0x84, 0x84, 0x00,	/* 11:埫墿怓 */
		0x00, 0x00, 0x84,	/* 12:埫?怓 */
		0x84, 0x00, 0x84,	/* 13:埫巼怓 */
		0x00, 0x84, 0x84,	/* 14:愺埫? */
		0x84, 0x84, 0x84	/* 15:埫奃怓 */
	};
	set_palette(0, 15, table_rgb);
	return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	eflags = io_load_eflags();	/* ??拞抐?壜?巙 */
	io_cli(); 					/* 嬛巭拞抐 */
	/*	棃帺槹http://community.osdev.info/?VGA
		1. 廀梫?拞抐
		2. 彨憐梫?掕揑?怓斅崋?幨擖0x03c8
		3. 埪R,G,B揑?彉幨擖0x03c9丅擛壥?憐???掕壓堦槩?怓斅丆?徣棯?怓斅崋?丆嵞埪徠RGB揑?彉幨擖0x03c9
		4. 擛壥憐梫摉慜?怓斅忬?丆庱愭梫彨?怓斅揑崋?幨擖0x03c7丆嵞樃0x03c9?庢嶰師暘?惀RGB
	*/
	io_out8(0x03c8, start);
	for (i = start; i <= end; i++) {
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	io_store_eflags(eflags);	/* 夬?拞抐忬? */
	return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
	int x, y;
	for (y = y0; y <= y1; y++) {
		for (x = x0; x <= x1; x++)
			vram[y * xsize + x] = c;
	}
	return;
}

void init_screen8(char *vram, int x, int y)
{
	boxfill8(vram, x, COL8_008484,  0,     0,      x -  1, y - 29); // 所有
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 28, x -  1, y - 28); // 下面的bar的上线
	boxfill8(vram, x, COL8_FFFFFF,  0,     y - 27, x -  1, y - 27); // 下面的bar的上线
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1); // 下面的bar

	boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24); // 下面左边button的上线
	boxfill8(vram, x, COL8_FFFFFF,  2,     y - 24,  2,     y -  4); // 下面左边button的左线
	boxfill8(vram, x, COL8_848484,  3,     y -  4, 59,     y -  4); // 下面左边button的下线(内)
	boxfill8(vram, x, COL8_848484, 59,     y - 23, 59,     y -  5); // 下面左边button的右线(外)
	boxfill8(vram, x, COL8_000000,  2,     y -  3, 59,     y -  3); // 下面左边button的下线(外)
	boxfill8(vram, x, COL8_000000, 60,     y - 24, 60,     y -  3); // 下面左边button的右线(内)

	boxfill8(vram, x, COL8_848484, x - 47, y - 24, x -  4, y - 24); // 下面右边button的上线
	boxfill8(vram, x, COL8_848484, x - 47, y - 23, x - 47, y -  4); // 下面右边button的左线
	boxfill8(vram, x, COL8_FFFFFF, x - 47, y -  3, x -  4, y -  3); // 下面右边button的下线
	boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3); // 下面右边button的右线
	return;
}

void putfont8(char *vram, int xsize, int x, int y, char c, char *font)
{
	int i;
	char *p, d /* data */;
	for (i = 0; i < 16; i++) {
		p = vram + (y + i) * xsize + x;
		d = font[i];
		if ((d & 0x80) != 0) { p[0] = c; }
		if ((d & 0x40) != 0) { p[1] = c; }
		if ((d & 0x20) != 0) { p[2] = c; }
		if ((d & 0x10) != 0) { p[3] = c; }
		if ((d & 0x08) != 0) { p[4] = c; }
		if ((d & 0x04) != 0) { p[5] = c; }
		if ((d & 0x02) != 0) { p[6] = c; }
		if ((d & 0x01) != 0) { p[7] = c; }
	}
	return;
}

void putfonts8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s)
{
	extern char hankaku[4096];
	for (; *s != 0x00; s++) {
		putfont8(vram, xsize, x, y, c, hankaku + *s * 16);
		x += 8;
	}
	return;
}

void init_mouse_cursor8(char *mouse, char bc)
{
	static char cursor[16][16] = {
		"**************..",
		"*OOOOOOOOOOO*...",
		"*OOOOOOOOOO*....",
		"*OOOOOOOOO*.....",
		"*OOOOOOOO*......",
		"*OOOOOOO*.......",
		"*OOOOOOO*.......",
		"*OOOOOOOO*......",
		"*OOOO**OOO*.....",
		"*OOO*..*OOO*....",
		"*OO*....*OOO*...",
		"*O*......*OOO*..",
		"**........*OOO*.",
		"*..........*OOO*",
		"............*OO*",
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
		for (x = 0; x < 16; x++) {
			if (cursor[y][x] == '*') {
				mouse[y * 16 + x] = COL8_000000;
			}
			if (cursor[y][x] == 'O') {
				mouse[y * 16 + x] = COL8_FFFFFF;
			}
			if (cursor[y][x] == '.') {
				mouse[y * 16 + x] = bc;
			}
		}
	}
	return;
}

void putblock8_8(char *vram, int vxsize, int pxsize,
	int pysize, int px0, int py0, char *buf, int bxsize)
{
	int x, y;
	for (y = 0; y < pysize; y++) {
		for (x = 0; x < pxsize; x++) {
			vram[(py0 + y) * vxsize + (px0 + x)] = buf[y * bxsize + x];
		}
	}
	return;
}
