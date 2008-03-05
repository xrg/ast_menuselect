#
# Asterisk -- A telephony toolkit for Linux.
# 
# Makefile for Menuselect
#
# Copyright (C) 2005-2006, Digium, Inc.
#
# Russell Bryant <russell@digium.com>
#
# This program is free software, distributed under the terms of
# the GNU General Public License
#

# read local makeopts settings
-include makeopts

.PHONY: clean dist-clean distclean test ntest gtest

# Basic set of sources and flags/libraries/includes
OBJS:=menuselect.o strcompat.o
CFLAGS:=-g -c -D_GNU_SOURCE -Wall

# Pick gtk library if available
ifneq ($(GTK2_LIB),)
  G_OBJS += menuselect_gtk.o
  INCLUDE += $(GTK2_INCLUDE)
  G_LIBS += $(GTK2_LIB)
else
  G_OBJS += menuselect_stub.o
endif

# Pick newt if available
ifneq ($(NEWT_LIB),)
  N_OBJS += menuselect_newt.o
  INCLUDE += $(NEWT_INCLUDE)
  N_LIBS += $(NEWT_LIB)
else
  N_OBJS += menuselect_stub.o
endif

# Pick a curses library if available
ifneq ($(NCURSES_LIB),)
  M_OBJS += menuselect_curses.o
  M_LIBS +=$(NCURSES_LIB)
  INCLUDE += $(NCURSES_INCLUDE)
else
  ifneq ($(CURSES_LIB),)
    M_OBJS += menuselect_curses.o
    M_LIBS +=$(CURSES_LIB)
    INCLUDE += $(CURSES_INCLUDE)
  else
    M_OBJS += menuselect_stub.o
  endif
endif

CFLAGS+= $(INCLUDE)
all:
	@$(MAKE) menuselect

$(OBJS) menuselect_gtk.o menuselect_curses.o menuselect_stub.o: autoconfig.h menuselect.h

makeopts autoconfig.h: autoconfig.h.in makeopts.in
	@./configure $(CONFIGURE_SILENT) CC= LD= AR= CFLAGS=

menuselect gmenuselect nmenuselect: mxml/libmxml.a

gmenuselect: $(OBJS) $(G_OBJS)
	$(CC) -o $@ $^ $(G_LIBS)

nmenuselect: $(OBJS) $(N_OBJS)
	$(CC) -o $@ $^ $(N_LIBS)

menuselect: $(OBJS) $(M_OBJS)
	$(CC) -o $@ $^ $(M_LIBS)

mxml/libmxml.a:
	@if test ! -f mxml/Makefile ; then cd mxml && ./configure ; fi
	@$(MAKE) -C mxml libmxml.a

test: menuselect
	(cd test; ../$< menuselect.makeopts)

ntest: nmenuselect
	(cd test; ../$< menuselect.makeopts)

gtest: gmenuselect
	(cd test; ../$< menuselect.makeopts)

clean:
	rm -f menuselect gmenuselect nmenuselect $(OBJS) $(M_OBJS) $(G_OBJS)
	@if test -f mxml/Makefile ; then $(MAKE) -C mxml clean ; fi

dist-clean: distclean

distclean: clean
	@if test -f mxml/Makefile ; then $(MAKE) -C mxml distclean ; fi
	rm -f autoconfig.h config.status config.log makeopts
	rm -rf autom4te.cache
