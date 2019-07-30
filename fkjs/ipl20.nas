; fkjs-os
; TAB=4

; 固定写法
		ORG		0x7c00			; 起始装载地址 org即origin
		JMP		entry
		DB		0x90
		DB		"haribote"			; 启动区名称
		DW		512				; 扇区大小
		DB		1				; 簇大小
		DW		1				; FAT起始地址，一般是1
		DB		2				; FAT个数
		DW		224				; 根目录大小，一般224
		DW		2880			; 磁盘大小，一般2880
		DB		0xf0			; 磁盘种类，必须f0
		DW		9				; FAT长度，必须9
		DW		18				; 1个磁道有多少个扇区，必须18
		DW		2				; 磁头数，必须2
		DD		0				; 不使用分区，必须0
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 不明，固定
		DD		0xffffffff		; 不明
		DB		"FKJSOS"		; 磁盘名称
		DB		"FAT12   "		; 磁盘格式
		RESB	18				; 空18字节

; 程序核心

entry: ;初始化寄存器
		MOV		AX,0			; 下面3个必须用AX 不能直接用0
		MOV		SS,AX			; 栈段寄存器(stack segment)
		MOV		SP,0x7c00		; stack point
		MOV		DS,AX			; data segment
		MOV		ES,AX			; extra segment
		
		;读磁盘

		MOV		AX,0x0820
		MOV		ES,AX			; 缓冲地址 从软盘上读出来的内容装到内存中的位置0x8200-0x83ff
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2

		; INT 0x13的标准
		; AH=0x02; 读盘
		; AH=0x03; 写盘
		; AH=0x04; 校验
		; AH=0x0c; 寻道
		; AL=处理的扇区数
		; CH=柱面号 &0xff
		; CL=扇区号
		; DH=磁头号
		; DL=驱动器号
		; ES:BX=缓冲地址 ES*16+BX
		; 返回值 FLAG.CF == 0 则无错
		; 总共使用寄存器 C D A B  

readloop:		
		MOV		SI,0			; 失败次数计数
retry:
		MOV		AH,0x02			; 读盘
		MOV		AL,1			; 处理一个扇区 也就是200B
		MOV		BX,0			; 0x8200 + 0
		MOV		DL,0x00			; 驱动器0
		INT		0x13			; 调用BIOS 13
		JNC		next			; JNC: jump not carry   如果磁盘正确 跳到fin处
		ADD		SI,1
		CMP		SI,5
		JAE		error			; if SI >= 5 jump to error
		MOV		AH,0x00
		MOV		DL,0x00
		INT		0x13			; 重置驱动器
		JMP		retry
next:
		MOV		AX,ES			; ES += 0x0020  ES不能直接加 0x0020 * 16 = 0x0200 = 512B
		ADD		AX,0x0020
		MOV		ES,AX
		ADD		CL,1
		CMP		CL,18
		JBE		readloop		; if CL <= 18 jump to readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; if DH < 2 ... 同时还原CL
		MOV		DH,0
		ADD		CH,1
		CMP		CH,10
		JB		readloop		; if CH < 10 ... 同时还原CL DH

		MOV		[0x0ff0],CH		; 随便选的一块没用的地址
		JMP		0xc200			; fkjs.img的起始地址
		
fin:
		HLT						; halt
		JMP		fin				; 循环
		
error:
; 下面是显示hello world
		MOV		SI,msg			; 源地址寄存器(source index)
putloop:
		MOV		AL,[SI]
		ADD		SI,1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; http://community.osdev.info/?(AT)BIOS 启动int 10(调用显卡BIOS) 显示一个字符，AH=0x0e,AL=character code,BH=0,BL=color code 返回值：无
		MOV		BX,15			; color code
		INT		0x10
		JMP		putloop

msg:
		DB		0x0a, 0x0a		; \n×2  \n的ascall是10
		DB		"load error"
		DB		0x0a			; \n×1
		DB		0

; 不知道下面有啥用
		
		RESB	0x7dfe-$		; 填写dfe-$个0   $的意思是到此处所用字节数

		DB		0x55, 0xaa
