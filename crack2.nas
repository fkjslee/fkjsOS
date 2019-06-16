[INSTRSET "i486p"]
[BITS 32]
		MOV		EAX,1*8			; OSópìIíiçÜ
		MOV		DS,AX			; ë∂ì¸DS
		MOV		BYTE [0x102600],0
		MOV		EDX,4
		INT		0x40
