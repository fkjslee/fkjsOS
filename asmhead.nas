; fkjs-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; bootpack�̃��[�h��
DSKCAC	EQU		0x00100000		; �f�B�X�N�L���b�V���̏ꏊ
DSKCAC0	EQU		0x00008000		; �f�B�X�N�L���b�V���̏ꏊ�i���A�����[�h�j

; BOOT_INFO�֌W
CYLS	EQU		0x0ff0			; �u�[�g�Z�N�^���ݒ肷��
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; �F���Ɋւ�����B���r�b�g�J���[���H
SCRNX	EQU		0x0ff4			; �𑜓x��X
SCRNY	EQU		0x0ff6			; �𑜓x��Y
VRAM	EQU		0x0ff8			; �O���t�B�b�N�o�b�t�@�̊J�n�Ԓn

		ORG		0xc200			; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

; ��ʃ��[�h��ݒ�

		MOV		BX,0x4101		; VBE��640x480x8bit�J���[
		MOV		AX,0x4f02
		INT		0x10
		MOV		BYTE [VMODE],8	; ��ʃ��[�h����������iC���ꂪ�Q�Ƃ���j
		MOV		WORD [SCRNX],640
		MOV		WORD [SCRNY],480
		MOV		DWORD [VRAM],0xe0000000

; �L�[�{�[�h��LED��Ԃ�BIOS�ɋ����Ă��炤

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC??��ؒ��f
;	����AT���e���I?�i�C�@�ʗv���n��PIC�C�K?��CLI�V�O?�s�C��?�L?��k�N
;	���@?�sPIC�I���n��

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; �^������s�\???�sOUT����
		OUT		0xa1,AL

		CLI						; ?��CPU??�I���f

; ?��?CPU�\???1MB�ȏ�I������?�C?��A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL			; ��?(?�����󐔐��ڝ�?�t�撆�I??����)

; �v���e�N�g���[�h�ڍs

[INSTRSET "i486p"]				; �g�p486�͎��C�h�~EAX��͐�label

		LGDT	[GDTR0]			; ?��??GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; �֎~��?
		OR		EAX,0x00000001	; ��?����?�͎�
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  ��?�ʓI�i32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack�I?��
; memcpy(���n��,	�ړI�n��,	?���I�����召)
; ?��memcpy(bootpack,	BOTPAK,	512*1024/4)
		MOV		ESI,bootpack	; ?����
		MOV		EDI,BOTPAK		; ?���ړI�n
		MOV		ECX,512*1024/4
		CALL	memcpy

; ��?������??�������{���I�ʒu

; ??���
; ?��memcpy(0x7c00,	DSKCAC,	512/4)

		MOV		ESI,0x7c00		; ?����
		MOV		EDI,DSKCAC		; ?���ړI�n
		MOV		ECX,512/4
		CALL	memcpy

; �����I
; ?��memcpy(DSKCAC0+512,	cyls * 512 * 18 * 2 / 4 - 512 / 4)

		MOV		ESI,DSKCAC0+512	; ?����
		MOV		EDI,DSKCAC+512	; ?���ړI�n
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; �����ʐ�???��?��/4
		SUB		ECX,512/4		; ?��IPL
		CALL	memcpy

; �K?�Rasmhead�I�����I�H���?����
; �����I�Rbootpack����

; bootpack??

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; �v�L�v?���I?��?
		MOV		ESI,[EBX+20]	; ?����
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; ?���ړI�n
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ?���n?
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
		JNZ		memcpy			; �����Z�������ʂ�0�łȂ����memcpy��
		RET
; memcpy�̓A�h���X�T�C�Y�v���t�B�N�X�����Y��Ȃ���΁A�X�g�����O���߂ł�������

		ALIGNB	16
GDT0:
		RESB	8
		DW		0xffff,0x0000,0x9200,0x00cf	; ��?�ʓI�i 32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; ��?�s�I�i 32bit

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack: