CPPSTD :=
SRCDIR	:= ./src
SRCEXT	:= .c
TARGET	:= libnanovg.a
SOURCES	:= $(SRCDIR)/nanovg.c
HEADERS	:= $(SRCDIR)/nanovg.h $(SRCDIR)/nanovg_gl.h
ifeq ($(strip $(GL)),2)
SOURCES	+= $(SRCDIR)/nanovg_gl2.c
INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),3)
SOURCES	+= $(SRCDIR)/nanovg_gl3.c
INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),ES2)
SOURCES	+= $(SRCDIR)/nanovg_gles2.c
INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),ES3)
SOURCES	+= $(SRCDIR)/nanovg_gles3.c
INCLUDE	+= $(INCDIR)/nanovg_full.h
else
HEADERS	+= $(SRCDIR)/nanovg_gl.h
INCLUDE	+= $(INCDIR)/nanovg_full.h
endif


LOCAL_MAKE_INCLUDE := include
override TEMPLATE := make_templates/static_lib
override LOCAL_TEMPLATE := $(LOCAL_MAKE_INCLUDE)/$(TEMPLATE)

ifneq ($(shell cat $(LOCAL_TEMPLATE) 2> /dev/null),)
include $(LOCAL_TEMPLATE)
else
include $(TEMPLATE)
endif

ifeq ($(strip $(GL)),2)
$(INCDIR)/nanovg_full.h: $(SRCDIR)/nanovg_gl2.h
	@mkdir -p $(@D)
	cp $< $@
else ifeq ($(strip $(GL)),3)
$(INCDIR)/nanovg_full.h: $(SRCDIR)/nanovg_gl3.h
	@mkdir -p $(@D)
	cp $< $@
else ifeq ($(strip $(GL)),ES2)
$(INCDIR)/nanovg_full.h: $(SRCDIR)/nanovg_gles2.h
	@mkdir -p $(@D)
	cp $< $@
else ifeq ($(strip $(GL)),ES3)
$(INCDIR)/nanovg_full.h: $(SRCDIR)/nanovg_gles3.h
	@mkdir -p $(@D)
	cp $< $@
endif
