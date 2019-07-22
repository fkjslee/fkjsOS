TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/fkjs/

MAKE     = $(TOOLPATH)make.exe -r
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

default :
	$(MAKE) fkjs.img
	
	
fkjs.img : fkjs/ipl20.bin fkjs/fkjs.sys Makefile \
		color/color.hrb color2/color2.hrb sosu3/sosu3.hrb \
		sosu2/sosu2.hrb typeipl/typeipl.hrb type/type.hrb \
		notrec/notrec.hrb bball/bball.hrb invader/invader.hrb \
		calc/calc.hrb tview/tview.hrb
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:fkjs/ipl20.bin len:512 from:0 to:0 \
		copy from:fkjs/fkjs.sys to:@: \
		copy from:fkjs/ipl20.nas to:@: \
		copy from:make.bat to:@: \
		copy from:color/color.hrb to:@: \
		copy from:color2/color2.hrb to:@: \
		copy from:sosu3/sosu3.hrb to:@: \
		copy from:invader/invader.hrb to:@: \
		copy from:sosu2/sosu2.hrb to:@: \
		copy from:typeipl/typeipl.hrb to:@: \
		copy from:type/type.hrb to:@: \
		copy from:bball/bball.hrb to:@: \
		copy from:notrec/notrec.hrb to:@: \
		copy from:calc/calc.hrb to:@: \
		copy from:tview/tview.hrb to:@: \
		imgout:fkjs.img

# 一般规则
	
img :
	$(MAKE) fkjs.img
	
run :
	$(MAKE) fkjs.img
	$(COPY) fkjs.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) fkjs.img
	$(IMGTOL) w a: fkjs.img

cls :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) *.map
	-$(DEL) *.bim
	-$(DEL) *.hrb
	-$(DEL) bootpack.nas
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) fkjs.sys
	del fkjs.img

full :
	$(MAKE) -C fkjs
	$(MAKE) -C apilib
	$(MAKE) -C a
	$(MAKE) -C color
	$(MAKE) -C color2
	$(MAKE) -C sosu3
	$(MAKE) -C sosu2
	$(MAKE) -C typeipl
	$(MAKE) -C type
	$(MAKE) -C notrec
	$(MAKE) -C invader
	$(MAKE) -C bball
	$(MAKE) -C calc
	$(MAKE) -C tview
	$(MAKE) fkjs.img

run_full :
	$(MAKE) full
	$(COPY) fkjs.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu
	
install_full :
	$(MAKE) full
	$(IMGTOL) w a: fkjs.img
	
	
run_os :
	$(MAKE) -C fkjs
	$(MAKE) run