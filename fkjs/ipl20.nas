; fkjs-os
; TAB=4

; �̶�д��
		ORG		0x7c00			; ��ʼװ�ص�ַ org��origin
		JMP		entry
		DB		0x90
		DB		"haribote"			; ����������
		DW		512				; ������С
		DB		1				; �ش�С
		DW		1				; FAT��ʼ��ַ��һ����1
		DB		2				; FAT����
		DW		224				; ��Ŀ¼��С��һ��224
		DW		2880			; ���̴�С��һ��2880
		DB		0xf0			; �������࣬����f0
		DW		9				; FAT���ȣ�����9
		DW		18				; 1���ŵ��ж��ٸ�����������18
		DW		2				; ��ͷ��������2
		DD		0				; ��ʹ�÷���������0
		DD		2880			; ��дһ�δ��̴�С
		DB		0,0,0x29		; �������̶�
		DD		0xffffffff		; ����
		DB		"FKJSOS"		; ��������
		DB		"FAT12   "		; ���̸�ʽ
		RESB	18				; ��18�ֽ�

; �������

entry: ;��ʼ���Ĵ���
		MOV		AX,0			; ����3��������AX ����ֱ����0
		MOV		SS,AX			; ջ�μĴ���(stack segment)
		MOV		SP,0x7c00		; stack point
		MOV		DS,AX			; data segment
		MOV		ES,AX			; extra segment
		
		;������

		MOV		AX,0x0820
		MOV		ES,AX			; �����ַ �������϶�����������װ���ڴ��е�λ��0x8200-0x83ff
		MOV		CH,0			; ����0
		MOV		DH,0			; ��ͷ0
		MOV		CL,2			; ����2

		; INT 0x13�ı�׼
		; AH=0x02; ����
		; AH=0x03; д��
		; AH=0x04; У��
		; AH=0x0c; Ѱ��
		; AL=�����������
		; CH=����� &0xff
		; CL=������
		; DH=��ͷ��
		; DL=��������
		; ES:BX=�����ַ ES*16+BX
		; ����ֵ FLAG.CF == 0 ���޴�
		; �ܹ�ʹ�üĴ��� C D A B  

readloop:		
		MOV		SI,0			; ʧ�ܴ�������
retry:
		MOV		AH,0x02			; ����
		MOV		AL,1			; ����һ������ Ҳ����200B
		MOV		BX,0			; 0x8200 + 0
		MOV		DL,0x00			; ������0
		INT		0x13			; ����BIOS 13
		JNC		next			; JNC: jump not carry   ���������ȷ ����fin��
		ADD		SI,1
		CMP		SI,5
		JAE		error			; if SI >= 5 jump to error
		MOV		AH,0x00
		MOV		DL,0x00
		INT		0x13			; ����������
		JMP		retry
next:
		MOV		AX,ES			; ES += 0x0020  ES����ֱ�Ӽ� 0x0020 * 16 = 0x0200 = 512B
		ADD		AX,0x0020
		MOV		ES,AX
		ADD		CL,1
		CMP		CL,18
		JBE		readloop		; if CL <= 18 jump to readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; if DH < 2 ... ͬʱ��ԭCL
		MOV		DH,0
		ADD		CH,1
		CMP		CH,10
		JB		readloop		; if CH < 10 ... ͬʱ��ԭCL DH

		MOV		[0x0ff0],CH		; ���ѡ��һ��û�õĵ�ַ
		JMP		0xc200			; fkjs.img����ʼ��ַ
		
fin:
		HLT						; halt
		JMP		fin				; ѭ��
		
error:
; ��������ʾhello world
		MOV		SI,msg			; Դ��ַ�Ĵ���(source index)
putloop:
		MOV		AL,[SI]
		ADD		SI,1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; http://community.osdev.info/?(AT)BIOS ����int 10(�����Կ�BIOS) ��ʾһ���ַ���AH=0x0e,AL=character code,BH=0,BL=color code ����ֵ����
		MOV		BX,15			; color code
		INT		0x10
		JMP		putloop

msg:
		DB		0x0a, 0x0a		; \n��2  \n��ascall��10
		DB		"load error"
		DB		0x0a			; \n��1
		DB		0

; ��֪��������ɶ��
		
		RESB	0x7dfe-$		; ��дdfe-$��0   $����˼�ǵ��˴������ֽ���

		DB		0x55, 0xaa
