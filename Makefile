# Makefile
# ESP8266 project Makefile.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

# Project definitions.
NAME = hello
VERSION = 0.1.0
PROJECT = $(NAME)-v$(VERSION)
SRC = main.c

# Serial communication.
PORT = /dev/ttyUSB0
BAUDRATE = 9600

# Xtensa compiler flags.
CC = xtensa-lx106-elf-gcc
CFLAGS = -iquote $(SRCDIR)/ -mlongcalls -DICACHE_FLASH
LDLIBS = -nostdlib -Wl,--start-group -lmain -lnet80211 -lwpa -llwip -lpp -lphy -lc -Wl,--end-group -lgcc
LDFLAGS = -Teagle.app.v6.ld
OBJ = $(patsubst %.c,$(OBJDIR)/%.o,$(SRC))

# File directories.
SRCDIR = src
OBJDIR = build
DISTDIR = dist

all: $(DISTDIR)/$(PROJECT)-0x00000.bin

$(DISTDIR)/$(PROJECT)-0x00000.bin: $(OBJDIR)/$(PROJECT).elf
	esptool.py elf2image -o "$(DISTDIR)/$(PROJECT)-" $^

$(OBJDIR)/$(PROJECT).elf: $(OBJ)
	@mkdir -p "$(DISTDIR)"
	$(CC) $(CFLAGS) $(LDFLAGS) $(LDLIBS) -o "$(OBJDIR)/$(PROJECT).elf" $(OBJ)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p "$(OBJDIR)"
	@mkdir -p "$(OBJDIR)/driver"
	$(CC) -c $(CFLAGS) -o $@ $<

flash: $(DISTDIR)/$(PROJECT)-0x00000.bin
	sudo chmod 777 $(PORT)  # Don't look, this is here because I'm lazy right now.
	esptool.py -p $(PORT) write_flash 0x00000 "$(DISTDIR)/$(PROJECT)-0x00000.bin" 0x10000 "$(DISTDIR)/$(PROJECT)-0x10000.bin"

monitor:
	screen -DRSq $(NAME) -t ESP8266 $(PORT) $(BAUDRATE)

clean:
	-screen -d $(NAME)
	rm -rf $(OBJDIR)
	rm -rf $(DISTDIR)

