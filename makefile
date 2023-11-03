# makefile for nesdoug example code, for Linux

ifeq ($(OS),Windows_NT)
# Windows
CC65 = ./BIN/cc65.exe
CA65 = ./BIN/ca65.exe
LD65 = ./BIN/ld65.exe
DEL = del
MKDIR = mkdir
else ifeq ($(OS),MSDOS)
# MS-DOS
# add "set OS=MSDOS" to autoexec
# DJGPP, GNU fileutils for DJGPP need to be installed
CC65 = ./BIN/cc65d.exe
CA65 = ./BIN/ca65d.exe
LD65 = ./BIN/ld65d.exe
DEL = del
MKDIR = mkdir
else
# Ubuntu/Debian
CC65 = cc65
CA65 = ca65
LD65 = ld65
DEL = rm
MKDIR = mkdir
endif

define ca65IncDir
-I $(1) --bin-include-dir $(1)
endef
define ld65IncDir
-L $(1) --obj-path $(1)
endef

NAME = famidash
CFG = CONFIG/nrom_32k_vert.cfg
OUTDIR = BUILD
TMPDIR = TMP

.PHONY: default clean

default: $(OUTDIR)/$(NAME).nes


#target: dependencies

MUSIC/EXPORTS/musicDefines.h: MUSIC/EXPORTS/*.inc
ifeq ($(OS),Windows_NT)
else ifeq ($(OS),MSDOS)
else
		python3 MUSIC/parse_inc_files.py
endif

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

$(TMPDIR):
	$(MKDIR) $(TMPDIR)

$(OUTDIR)/$(NAME).nes: $(OUTDIR) $(TMPDIR)/$(NAME).o $(TMPDIR)/crt0.o $(CFG)
	$(LD65) -C $(CFG) -o $(OUTDIR)/$(NAME).nes $(call ld65IncDir,$(TMPDIR)) $(call ld65IncDir,LIB) crt0.o $(NAME).o nes.lib -Ln $(OUTDIR)/labels.txt --dbgfile $(OUTDIR)/dbg.txt
	@echo $(NAME).nes created

$(TMPDIR)/crt0.o: SAUCE/crt0.s GRAPHICS/famidash.chr LIB/*.s MUSIC/EXPORTS/*.s MUSIC/EXPORTS/*.dmc
	$(CA65) SAUCE/crt0.s -I LIB $(call ca65IncDir,MUSIC/EXPORTS) -o $(TMPDIR)/crt0.o

$(TMPDIR)/$(NAME).o: $(TMPDIR)/$(NAME).s
	$(CA65) $(call ca65IncDir,LIB) $(TMPDIR)/$(NAME).s -g

$(TMPDIR)/$(NAME).s: $(TMPDIR) SAUCE/$(NAME).c SAUCE/*.h MUSIC/EXPORTS/musicDefines.h
	$(CC65) -Oirs SAUCE/$(NAME).c --add-source -o $(TMPDIR)/$(NAME).s

clean:
ifeq ($(OS),Windows_NT)
	clean.bat
else ifeq ($(OS),MSDOS)
	rm -rf $(TMPDIR)/*.*
else
	rm -rf $(TMPDIR)
endif
