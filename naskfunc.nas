; �Y���I����
; TAB=4

[FORMAT "WCOFF"]				; ?�o�i��?�u��WCOFF�ȕ֘abootpack.obj?��
[BITS 32]
[INSTRSET "i486p"]				; �\���g�p486�ȏ�CPU�n��C�g��EAX��?���񑶊�
[FILE "naskfunc.nas"]			; �{����

; �����M��(?��.h����?)

		GLOBAL _io_hlt			; ���v?�ړI�������C�K?�pGLOBAL����
		GLOBAL _io_cli
		GLOBAL _io_sti
		GLOBAL _io_stihlt
		GLOBAL _io_in8
		GLOBAL _io_in16
		GLOBAL _io_in32
		GLOBAL _io_out8
		GLOBAL _io_out16
		GLOBAL _io_out32
		GLOBAL _io_load_eflags
		GLOBAL _io_store_eflags
		GLOBAL _load_gdtr
		GLOBAL _load_idtr
		GLOBAL	_memtest_sub
		GLOBAL	_load_cr0, _store_cr0
		GLOBAL	_asm_inthandler20, _asm_inthandler21, _asm_inthandler27, _asm_inthandler2c
		GLOBAL	_load_tr
		GLOBAL	_farjmp, _farcall
		GLOBAL	_asm_cons_putchar
		GLOBAL	_asm_hrb_api, _start_app
		EXTERN	_inthandler20, _inthandler21, _inthandler27, _inthandler2c
		EXTERN	_hrb_api
		
; ??�I����(?��.cpp����?)
[SECTION .text]					; �s?
_io_hlt:	; void io_hlt(void);
		HLT
		RET
		

_io_cli:	; void io_cli(void);
		CLI
		RET

_io_sti:	; void io_sti(void);
		STI
		RET

_io_stihlt:	; void io_stihlt(void);
		STI
		HLT
		RET

_io_in8:	; int io_in8(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AL,DX
		RET

_io_in16:	; int io_in16(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:	; int io_in32(int port);
		MOV		EDX,[ESP+4]		; port
		IN		EAX,DX
		RET

_io_out8:	; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		AL,[ESP+8]		; data
		OUT		DX,AL
		RET

_io_out16:	; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,AX
		RET

_io_out32:	; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,EAX
		RET

_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; �wPUSH EFLAGS push flags double-word
		POP		EAX	; �ԉ�? ?��EAX���I?�A���ԉ�?
		RET

_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; �wPOP EFLAGS
		RET
		
_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET
		
_load_cr0:		; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET

_load_tr:		; void load_tr(int tr);
		LTR		[ESP+4]			; tr
		RET
		
_asm_inthandler20:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
		MOV		EAX,ESP
		PUSH	SS				; �ۑ�SS
		PUSH	EAX				; �ۑ�ESP
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler20
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
; ��?�p����?�����f
		MOV		EAX,1*8
		MOV		DS,AX			; DS��?os
		MOV		ECX,[0xfe4]		; OS�pESP
		ADD		ECX,-8
		MOV		[ECX+4],SS		; �ۑ�SS
		MOV		[ECX  ],ESP		; �ۑ�ESP
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler20
		POP		ECX
		POP		EAX
		MOV		SS,AX			; SS??�p����
		MOV		ESP,ECX			; ESP??�p����
		POPAD
		POP		DS
		POP		ES
		IRETD
		
_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
		MOV		EAX,ESP
		PUSH	SS				
		PUSH	EAX				
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
		MOV		EAX,1*8
		MOV		DS,AX			
		MOV		ECX,[0xfe4]		
		ADD		ECX,-8
		MOV		[ECX+4],SS		
		MOV		[ECX  ],ESP		
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler21
		POP		ECX
		POP		EAX
		MOV		SS,AX			
		MOV		ESP,ECX			
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler27:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
		MOV		EAX,ESP
		PUSH	SS				
		PUSH	EAX				
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler27
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
		MOV		EAX,1*8
		MOV		DS,AX			
		MOV		ECX,[0xfe4]		
		ADD		ECX,-8
		MOV		[ECX+4],SS		
		MOV		[ECX  ],ESP		
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler27
		POP		ECX
		POP		EAX
		MOV		SS,AX		
		MOV		ESP,ECX		
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
		MOV		EAX,ESP
		PUSH	SS				
		PUSH	EAX				
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler2c
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
		MOV		EAX,1*8
		MOV		DS,AX			
		MOV		ECX,[0xfe4]		
		ADD		ECX,-8
		MOV		[ECX+4],SS		
		MOV		[ECX  ],ESP		
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler2c
		POP		ECX
		POP		EAX
		MOV		SS,AX			
		MOV		ESP,ECX			
		POPAD
		POP		DS
		POP		ES
		IRETD
		
_memtest_sub:	; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH	EDI
		PUSH	ESI
		PUSH	EBX
		MOV		ESI,0xaa55aa55			; pat0 = 0xaa55aa55;
		MOV		EDI,0x55aa55aa			; pat1 = 0x55aa55aa;
		MOV		EAX,[ESP+12+4]			; i = start;
mts_loop:
		MOV		EBX,EAX
		ADD		EBX,0xffc				; p = i + 0xffc;
		MOV		EDX,[EBX]				; old = *p;
		MOV		[EBX],ESI				; *p = pat0;
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff;
		CMP		EDI,[EBX]				; if (*p != pat1) goto fin;
		JNE		mts_fin
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff;
		CMP		ESI,[EBX]				; if (*p != pat0) goto fin;
		JNE		mts_fin
		MOV		[EBX],EDX				; *p = old;
		ADD		EAX,0x1000				; i += 0x1000;
		CMP		EAX,[ESP+12+8]			; if (i <= end) goto mts_loop;
		JBE		mts_loop
		POP		EBX
		POP		ESI
		POP		EDI
		RET
mts_fin:
		MOV		[EBX],EDX				; *p = old;
		POP		EBX
		POP		ESI
		POP		EDI
		RET

_farjmp:		; void farjmp(int eip, int cs);
		JMP		FAR	[ESP+4]				; eip, cs
		RET
			
_farcall:		; void farcall(int eip, int cs);
		CALL	FAR	[ESP+4]				; eip, cs
		RET
		

_asm_hrb_api:
		PUSH	DS
		PUSH	ES
		PUSHAD		; �ۑ��p
		MOV		EAX,1*8
		MOV		DS,AX			; DS?os
		MOV		ECX,[0xfe4]		; os�Iesp
		ADD		ECX,-40
		MOV		[ECX+32],ESP	; �ۑ�?�p�����Iesp
		MOV		[ECX+36],SS		; �ۑ�?�p�����ISS

; ��PUSHAD�@�I??�����n??
		MOV		EDX,[ESP   ]
		MOV		EBX,[ESP+ 4]
		MOV		[ECX   ],EDX	; ?hrb_api
		MOV		[ECX+ 4],EBX	; ?hrb_api
		MOV		EDX,[ESP+ 8]
		MOV		EBX,[ESP+12]
		MOV		[ECX+ 8],EDX	; ?hrb_api
		MOV		[ECX+12],EBX	; ?hrb_api
		MOV		EDX,[ESP+16]
		MOV		EBX,[ESP+20]
		MOV		[ECX+16],EDX	; ?hrb_api
		MOV		[ECX+20],EBX	; ?hrb_api
		MOV		EDX,[ESP+24]
		MOV		EBX,[ESP+28]
		MOV		[ECX+24],EDX	; ?hrb_api
		MOV		[ECX+28],EBX	; ?hrb_api

		MOV		ES,AX			; ���]�I�i�񑶊�?os
		MOV		SS,AX
		MOV		ESP,ECX
		STI	

		CALL	_hrb_api

		MOV		ECX,[ESP+32]	; ��oESP
		MOV		EAX,[ESP+36]	; ��oSS
		CLI
		MOV		SS,AX
		MOV		ESP,ECX
		POPAD
		POP		ES
		POP		DS
		IRETD		; ��??�sSTI

_start_app:		; void start_app(int eip, int cs, int esp, int ds);
		PUSHAD		; �ۑ�32�ʊ񑶊�
		MOV		EAX,[ESP+36]	; ?�p����EIP
		MOV		ECX,[ESP+40]	; ?�p����CS
		MOV		EDX,[ESP+44]	; ?�p����ESP
		MOV		EBX,[ESP+48]	; ?�p����DS/SS
		MOV		[0xfe4],ESP		; OS�pESP
		CLI		
		MOV		ES,BX
		MOV		SS,BX
		MOV		DS,BX
		MOV		FS,BX
		MOV		GS,BX
		MOV		ESP,EDX
		STI		
		PUSH	ECX				; �p��far-CALL�IPUSH�ics�j
		PUSH	EAX				; �p��far-CALL�IPUSH�ieip�j
		CALL	FAR [ESP]		; ?�p?�p����

;	?�p�����ԉ�

		MOV		EAX,1*8			; OS�pDS/SS
		CLI		
		MOV		ES,AX
		MOV		SS,AX
		MOV		DS,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		ESP,[0xfe4]
		STI		
		POPAD	; ��?�ۑ��I�񑶊�?
		RET
