#! /usr/bin/make -f

empty :=
space := $(empty) $(empty)
fsspace := $(shell printf '\x1a')
squote := '
dquote := "

quote-spaces = $(subst $(space),$(fsspace),$1)
unquote-spaces = $(subst $(fsspace),$(space),$1)
quote-sh = $(squote)$(subst $(squote),$(squote)$(dquote)$(squote)$(dquote)$(squote),$1)$(squote)

DOCKERIMG := caliboat
TSFILE := docker-image.ts
SCRIPT := caliboat
VMAP := /tmp/.X11-unix:/tmp/.X11-unix						\
	$(HOME)/.config:/app/.config						\
	$(call quote-spaces,$(HOME)/Calibre Library:/app/Calibre Library)	\
	$(call quote-spaces,$(HOME)/My Kindle Content:/app/My Kindle Content)

UID := $(shell id -u)
GID := $(shell id -g)
SUDO :=

all: $(TSFILE) $(SCRIPT)

sudo: SUDO := sudo
sudo: all

$(TSFILE): Makefile Dockerfile
	$(SUDO) docker build --build-arg UID=$(UID) --build-arg GID=$(GID) -t $(call quote-sh,$(DOCKERIMG)) .
	touch $@

$(SCRIPT): Makefile Dockerfile
	echo '#! /bin/bash' >$(call quote-sh,$@)
	echo $(call quote-sh,$(SUDO) docker run -it -e DISPLAY=$$DISPLAY $(call unquote-spaces,$(addprefix -v$(space),$(foreach i,$(VMAP),$(call quote-sh,$i)))) $(call quote-sh,$(DOCKERIMG)) "$$@") >>$(call quote-sh,$@)
	chmod a+x $(call quote-sh,$@)

clean:
	-rm -f $(call quote-sh,$(TSFILE)) $(call quote-sh,$(SCRIPT))

repoclean:
	-$(SUDO) docker image rm -f $(call quote-sh,$(DOCKERIMG))

allclean: clean repoclean
