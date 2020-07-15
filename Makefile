#! /usr/bin/make -f

ifeq ($(shell id -u),0)
$(error Do not build caliboat as root. Refer to the build instructions in README.md)
endif

empty :=
space := $(empty) $(empty)
fsspace := $(shell printf '\x1a')
squote := '
dquote := "

quote-spaces = $(subst $(space),$(fsspace),$1)
unquote-spaces = $(subst $(fsspace),$(space),$1)
quote-sh = $(squote)$(subst $(squote),$(squote)$(dquote)$(squote)$(dquote)$(squote),$1)$(squote)

DOCKER_REPO := caliboat
TSFILE := docker-image.ts
SCRIPT := caliboat
VMAP := /tmp/.X11-unix:/tmp/.X11-unix						\
	$(HOME)/.config:/app/.config						\
	$(call quote-spaces,$(HOME)/Calibre Library:/app/Calibre Library)	\
	$(call quote-spaces,$(HOME)/My Kindle Content:/app/My Kindle Content)

UID := $(shell id -u)
GID := $(shell id -g)
DOCKER := docker

all: $(TSFILE) $(SCRIPT)

sudo: DOCKER := sudo $(DOCKER)
sudo: all

$(TSFILE): Makefile Dockerfile
	$(DOCKER) build --build-arg UID=$(UID) --build-arg GID=$(GID) -t $(call quote-sh,$(DOCKER_REPO)) .
	touch $@

$(SCRIPT): Makefile Dockerfile
	echo '#! /bin/bash' >$(call quote-sh,$@)
	echo $(call quote-sh,[ -t 1 ] && ARGS=-it) >>$(call quote-sh,$@)
	echo $(call quote-sh,$(DOCKER) run $$ARGS -e DISPLAY=$$DISPLAY $(call unquote-spaces,$(addprefix -v$(space),$(foreach i,$(VMAP),$(call quote-sh,$i)))) $(call quote-sh,$(DOCKER_REPO)) "$$@") >>$(call quote-sh,$@)
	chmod a+x $(call quote-sh,$@)

clean:
	-rm -f $(TSFILE) $(SCRIPT)

repoclean:
	-$(DOCKER) image rm -f $(call quote-sh,$(DOCKER_REPO))

allclean: clean repoclean
