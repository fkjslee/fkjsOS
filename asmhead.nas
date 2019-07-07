; fkjs-os boot asm
; TAB=4

[INSTRSET "i486p"]
VBEMODE	EQU		0x105			; 1024 x  768 x 8bitカラー
BOTPAK	EQU		0x00280000		; bootpackのロード先
DSKCAC	EQU		0x00100000		; ディスクキャッシュの場所
DSKCAC0	EQU		0x00008000		; ディスクキャッシュの場所（リアルモード）

; BOOT_INFO関係
CYLS	EQU		0x0ff0			; ブートセクタが設定する
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 色数に関する情報。何ビットカラーか？
SCRNX	EQU		0x0ff4			; 解像度のX
SCRNY	EQU		0x0ff6			; 解像度のY
VRAM	EQU		0x0ff8			; グラフィックバッファの開始番地

		ORG		0xc200			; このプログラムがどこに読み込まれるのか

; ??VBE是否存在

		MOV		AX,0x9000
		MOV		ES,AX
		MOV		DI,0
		MOV		AX,0x4f00
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320		

; ??VBE版本

		MOV		AX,[ES:DI+4]
		CMP		AX,0x0200
		JB		scrn320			; if (AX < 0x0200) goto scrn320
		
; 取得画面模式信息

		MOV		CX,VBEMODE
		MOV		AX,0x4f01
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320
		
; ??画面模式信息

		CMP		BYTE [ES:DI+0x19],8
		JNE		scrn320
		CMP		BYTE [ES:DI+0x1b],4
		JNE		scrn320
		MOV		AX,[ES:DI+0x00]
		AND		AX,0x0080
		JZ		scrn320			; 如果模式属性的Bit7是0 放弃

; 画面模式的切?

		MOV		BX,VBEMODE+0x4000
		MOV		AX,0x4f02
		INT		0x10
		MOV		BYTE [VMODE],8	; ?下画面模式(?似C?言)
		MOV		AX,[ES:DI+0x12]
		MOV		[SCRNX],AX
		MOV		AX,[ES:DI+0x14]
		MOV		[SCRNY],AX
		MOV		EAX,[ES:DI+0x28]
		MOV		[VRAM],EAX
		JMP		keystatus

scrn320:
		MOV		AL,0x13			; VGA?、320x200x8bit彩色
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; ?下画面模式(?似C?言)
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

keystatus:
		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC??一切中断
;	根据AT兼容机的?格，如果要初始化PIC，必?在CLI之前?行，否?有?会挂起
;	随后?行PIC的初始化

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 某些机器不能???行OUT命令
		OUT		0xa1,AL

		CLI						; ?制CPU??的中断

; ?了?CPU能???1MB以上的内存空?，?定A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL			; 空?(?了清空数据接收?冲区中的??数据)

; プロテクトモード移行


		LGDT	[GDTR0]			; ?定??GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; 禁止分?
		OR		EAX,0x00000001	; 切?到保?模式
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  可?写的段32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack的?送
; memcpy(源地址,	目的地址,	?送的数据大小)
; ?似memcpy(bootpack,	BOTPAK,	512*1024/4)
		MOV		ESI,bootpack	; ?送源
		MOV		EDI,BOTPAK		; ?送目的地
		MOV		ECX,512*1024/4
		CALL	memcpy

; 磁?数据最??送到它本来的位置

; ??扇区
; ?似memcpy(0x7c00,	DSKCAC,	512/4)

		MOV		ESI,0x7c00		; ?送源
		MOV		EDI,DSKCAC		; ?送目的地
		MOV		ECX,512/4
		CALL	memcpy

; 剩下的
; ?似memcpy(DSKCAC0+512,	cyls * 512 * 18 * 2 / 4 - 512 / 4)

		MOV		ESI,DSKCAC0+512	; ?送源
		MOV		EDI,DSKCAC+512	; ?送目的地
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从柱面数???字?数/4
		SUB		ECX,512/4		; ?去IPL
		CALL	memcpy

; 必?由asmhead的完成的工作已?完成
; 其他的由bootpack完成

; bootpack??

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 没有要?送的?西?
		MOV		ESI,[EBX+20]	; ?送源
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; ?送目的地
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ?初始?
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; 
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 引き算した結果が0でなければmemcpyへ
		RET
; memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける

		ALIGNB	16
GDT0:
		RESB	8
		DW		0xffff,0x0000,0x9200,0x00cf	; 可?写的段 32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; 可?行的段 32bit

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
