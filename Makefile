override	CPPFLAGS	+= -MMD -MP
override	CPPFLAGS	+= -I./include
override	CPPFLAGS	+= $(shell cat .cxxflags 2> /dev/null | xargs)

ARFLAGS	:= $(ARFLAGS)c

PREFIX	:= $(DESTDIR)/usr/local
INCDIR	:= $(PREFIX)/include
LIBDIR	:= $(PREFIX)/lib

SRCDIR	:= ./src
TEMPDIR	:= temp
DISTDIR	:= out
TARGET	:= libnanovg.a
OUT		:= $(DISTDIR)/$(TARGET)
# SOURCES	:= $(shell find -wholename "$(SRCDIR)/*.c")
SOURCES	:= $(SRCDIR)/nanovg.c
# HEADERS	:= $(shell find -wholename "$(SRCDIR)/*.h")
HEADERS	:= $(SRCDIR)/nanovg.h $(SRCDIR)/nanovg_gl.h
INCLUDE	:= $(HEADERS:$(SRCDIR)/%=$(INCDIR)/%)
INCDIRS	:= $(shell dirname $(INCLUDE))

ifeq ($(strip $(GL)),2)
override SOURCES	+= $(SRCDIR)/nanovg_gl2.c
override INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),3)
override SOURCES	+= $(SRCDIR)/nanovg_gl3.c
override INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),ES2)
override SOURCES	+= $(SRCDIR)/nanovg_gles2.c
override INCLUDE	+= $(INCDIR)/nanovg_full.h
else ifeq ($(strip $(GL)),ES3)
override SOURCES	+= $(SRCDIR)/nanovg_gles3.c
override INCLUDE	+= $(INCDIR)/nanovg_full.h
else
override HEADERS	+= $(SRCDIR)/nanovg_gl.h
override INCLUDE	+= $(INCDIR)/nanovg_full.h
endif

OBJECTS	:= $(SOURCES:$(SRCDIR)/%.c=$(TEMPDIR)/%.o)
OBJDIRS	:= $(shell dirname $(OBJECTS))
DEPENDS	:= $(OBJECTS:.o=.d)

$(OUT): $(OBJECTS) | $(DISTDIR)
	$(AR) $(ARFLAGS) $@ $^

$(TEMPDIR)/%.o: $(SRCDIR)/%.c | $(TEMPDIR)
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $<

$(TEMPDIR):
	@mkdir $@

$(DISTDIR):
	@mkdir $@

clean:
	@rm $(DEPENDS) 2> /dev/null || true
	@rm $(OBJECTS) 2> /dev/null || true
	@rmdir -p $(OBJDIRS) 2> /dev/null || true
	@echo Temporaries cleaned!

distclean: clean
	@rm $(OUT) 2> /dev/null || true
	@rmdir $(DISTDIR) 2> /dev/null || true
	@echo All clean!

install: $(LIBDIR)/$(TARGET) $(INCLUDE)

$(LIBDIR)/$(TARGET): $(OUT) | $(LIBDIR)
	cp $< $@

$(LIBDIR):
	@mkdir $@

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

$(INCDIR)/%.h: $(SRCDIR)/%.h
	@mkdir -p $(@D)
	cp $< $@

uninstall:
	-rm $(INCLUDE)
	@rmdir -p $(INCDIRS) 2> /dev/null || true
	-rm $(LIBDIR)/$(TARGET)
	@rmdir $(LIBDIR) 2> /dev/null || true
	@echo Uninstall complete!

-include $(DEPENDS)

.PRECIOUS : $(OBJECTS)
.PHONY : clean distclean uninstall
