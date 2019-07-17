TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/fkjs/

MAKE     = $(TOOLPATH)make.exe -r
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

default :
	$(MAKE) fkjs.img
	
	
fkjs.img : fkjs/ipl10.bin fkjs/fkjs.sys Makefile\
		color/color.hrb color2/color2.hrb
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:fkjs/ipl10.bin len:512 from:0 to:0 \
		copy from:fkjs/fkjs.sys to:@: \
		copy from:fkjs/ipl10.nas to:@: \
		copy from:make.bat to:@: \
		copy from:color/color.hrb to:@: \
		copy from:color2/color2.hrb to:@: \
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