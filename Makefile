###################################################################
#		主控自动化编译配置文件 Makefile			  #
#				彭东  ＠ 2012.08.13.23.50	  #
###################################################################

MAKEFLAGS = -sR

MKDIR = mkdir
RMDIR = rmdir
CP = cp
CD = cd
DD = dd
RM = rm
LKIMG = ./lmoskrlimg -m k
VM = qemu-system-x86_64 #qemu-system-i386 qemu-x86_64
DBUGVM = bochs -q
IMGTOVDI = qemu-img convert -f raw -O vdi
IMGTOVMDK = qemu-img convert -f raw -O vmdk
MAKE = make
X86BARD = -f ./Makefile.x86
PREMENTMFLGS = -C $(BUILD_PATH) -f pretreatment.mk
X86ARCHMFLGS = -C $(BUILD_PATH) -f x86arch.mk
X86BOOTMFLGS = -C $(BUILD_PATH) -f x86boot.mk
X86_64BOOTMFLGS = -C $(BUILD_PATH) -f x86_64boot.mk
X86_64ARCHMFLGS = -C $(BUILD_PATH) -f x86_64arch.mk
X86LINKMFLGS = -C $(BUILD_PATH) -f krnllink.mk
DRIVERSMFLGS = -C $(BUILD_PATH) -f drivers.mk
INTMGRMFLGS = -C $(BUILD_PATH) -f intmgr.mk
DEVMGRMFLGS = -C $(BUILD_PATH) -f devmgr.mk
IFEMGRMFLGS = -C $(BUILD_PATH) -f ifemgr.mk
MEMMGRMFLGS = -C $(BUILD_PATH) -f memmgr.mk
KOBMGRMFLGS = -C $(BUILD_PATH) -f kobmgr.mk
KVMRLMOSFLGS = -C $(BUILD_PATH) -f kvmrlmos.mk
VVMRLMOSFLGS = -C $(BUILD_PATH) -f vbox.mkf
X86_64LINKMFLGS = -C $(BUILD_PATH) -f x86_64krnllink.mk
KERNELMFLGS = -C $(BUILD_PATH) -f kernel.mk
MMMFLGS	= -C $(BUILD_PATH) -f mm.mk
LIBMFLGS = -C $(BUILD_PATH) -f lib.mk
INITSHELLMFLGS = -C $(BUILD_PATH) -f initshell.mk
LINKINITSHELLMFLGS = -C $(BUILD_PATH) -f linkinitshell.mk
FSMFLGS	= -C $(BUILD_PATH) -f krnlfs.mk
VBOXVMFLGS = -C $(VM_PATH) -f vbox.mkf
CPFLAGES =
DDFLAGS =
VMFLAGES = -smp 4 -hda $(DSKIMG) -enable-kvm
READSECTOR = 520
SHELLREADSECTOR = 20
SHELLSTARTSECTOR = 600
DSKIMG =hd10g.img #hd50m.img PDOS.vhd
IMGSECTNR = 204800
PHYDSK = /dev/sdb
VDIFNAME = lmos.vdi
VMDKFNAME = lmos.vmdk
UMBREXCIMG = u.mbr
BOOTEXCIMG = #lmhdboot.bin
KRNLEXCIMG = lmosemkrnl.bin
LDEREXCIMG = #lmosldr.bin
SHELEXCIMG = #lmosinitshell.bin #LMOSBKDG1.bmp LMOSBKDG2.bmp LMOSBKDG3.bmp LMOSBKDG5.bmp LMOSBKDG6.bmp
LOGOFILE = LMOSEMLOGOX.bmp 22.bmp #LMOSBKDG4.bmp DIPDRV.bmp
GIFFILE = #./lmosbitmap/mn/*.bmp
GIFFILE2 = #./lmosbitmap/星空/*.bmp
FONTFILE = lmos.fnt
BUILD_PATH = ./build
EXKNL_PATH = ./exckrnl
VM_PATH = ./vm
DSTPATH = ../exckrnl
RELEDSTPATH = ../release
LMINITLDR_PATH =./lminitldr/
LMILDR_BUILD_PATH =./lminitldr/build/
CPLILDR_PATH =./release/
INSTALL_PATH =/boot/
INSTALLSRCFILE_PATH =./release/lmosemkrnl.eki
SRCFILE = $(BOOTEXCIMG) $(KRNLEXCIMG) $(LDEREXCIMG) $(SHELEXCIMG)
RSRCFILE = $(BOOTEXCIMG) $(KRNLEXCIMG) $(LDEREXCIMG) $(SHELEXCIMG) #$(VDIFNAME) $(VMDKFNAME)

LMOSLDRIMH = lmldrimh.bin
LMOSLDRKRL = lmldrkrl.bin
LMOSLDRSVE = lmldrsve.bin

CPLILDRSRC= $(LMILDR_BUILD_PATH)$(LMOSLDRSVE) $(LMILDR_BUILD_PATH)$(LMOSLDRKRL) $(LMILDR_BUILD_PATH)$(LMOSLDRIMH)

LKIMG_INFILE = $(LMOSLDRSVE) $(LMOSLDRKRL) $(KRNLEXCIMG) $(SHELEXCIMG) $(FONTFILE) $(LOGOFILE) $(GIFFILE) $(GIFFILE2)
.PHONY : install x32 build print clean all krnlexc cpkrnl wrimg phymod exc vdi vdiexc cprelease release createimg

build: clean print all

all:
	$(MAKE) $(X86BARD)
	@echo '恭喜我，系统编译构建完成！ ^_^'
clean:
	$(CD) $(BUILD_PATH); $(RM) -f *.o *.bin *.i *.krnl *.s *.map *.lib *.btoj *.vdi *vmdk krnlobjs.mh
	$(CD) $(EXKNL_PATH); $(RM) -f *.o *.bin *.i *.krnl *.s *.map *.lib *.btoj *.vdi *vmdk krnlobjs.mh
	$(CD) $(CPLILDR_PATH); $(RM) -f *.o *.bin *.i *.krnl *.s *.eki *.map *.lib *.btoj *.vdi *vmdk krnlobjs.mh
	@echo '清理全部已构建文件... ^_^'

print:
	@echo '*********正在开始编译构建系统*************'


krnlexc: cpkrnl wrimg exc
dbugkrnl: cpkrnl wrimg dbugexc
vdiexc:  vdi
	$(MAKE) $(VBOXVMFLGS)
vdi:cpkrnl wrimg
	$(CD) $(EXKNL_PATH) && $(IMGTOVDI) $(DSKIMG) $(VDIFNAME)
	$(CD) $(EXKNL_PATH) && $(IMGTOVMDK) $(DSKIMG) $(VMDKFNAME)
cplmildr:
	$(CP) $(CPFLAGES) $(CPLILDRSRC) $(CPLILDR_PATH)

cpkrnl:
	$(CD) $(BUILD_PATH) && $(CP) $(CPFLAGES) $(SRCFILE) $(DSTPATH)
cprelease:
	$(CD) $(EXKNL_PATH) && $(CP) $(CPFLAGES) $(RSRCFILE) $(RELEDSTPATH)
wrimg:
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(UMBREXCIMG) of=$(DSKIMG) count=1 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(BOOTEXCIMG) of=$(DSKIMG) seek\=63 count=1 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(LDEREXCIMG) of=$(DSKIMG) seek\=68 count=9 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(KRNLEXCIMG) of=$(DSKIMG) seek\=80 count=$(READSECTOR) conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(SHELEXCIMG) of=$(DSKIMG) seek\=$(SHELLSTARTSECTOR) count=$(SHELLREADSECTOR) conv\=notrunc

phymod: cpkrnl
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(UMBREXCIMG) of=$(PHYDSK) count=1 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(BOOTEXCIMG) of=$(PHYDSK) seek\=63 count=1 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(LDEREXCIMG) of=$(PHYDSK) seek\=68 count=9 conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(KRNLEXCIMG) of=$(PHYDSK) seek\=80 count=$(READSECTOR) conv\=notrunc
	$(CD) $(EXKNL_PATH) && $(DD) bs=512 if=$(SHELEXCIMG) of=$(PHYDSK) seek\=$(SHELLSTARTSECTOR) count=$(SHELLREADSECTOR) conv\=notrunc

exc:
	$(CD) $(EXKNL_PATH) && $(VM) $(VMFLAGES)
dbugexc:
	$(CD) $(EXKNL_PATH) && $(DBUGVM)

KIMG:
	@echo '正在生成LMOS内核映像文件，请稍后……'
	$(CD) $(CPLILDR_PATH) && $(LKIMG) -lhf $(LMOSLDRIMH) -o lmosemkrnl.eki -f $(LKIMG_INFILE)

KVMRUN:
	$(MAKE) $(KVMRLMOSFLGS)

VBOXRUN:
	$(MAKE) $(VVMRLMOSFLGS)

#cpkrnl cprelease
release: clean all cplmildr cpkrnl cprelease KIMG 

kvmtest: release KVMRUN

vboxtest: release VBOXRUN


createimg:
	$(DD) bs=512 if=/dev/zero of=$(DSKIMG) count=$(IMGSECTNR)

install:
	@echo '下面将开始安装LMOS内核，请确认……'
	sudo $(CP) $(CPFLAGES) $(INSTALLSRCFILE_PATH) $(INSTALL_PATH)
	@echo 'LMOS内核已经安装完成，请重启计算机……'
