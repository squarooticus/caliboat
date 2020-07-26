#! /usr/bin/make -f

ifeq ($(shell id -u),0)
$(error Do not build caliboat as root. Refer to the build instructions in README.md)
endif

empty :=
space := $(empty) $(empty)
fsspace := $(shell printf '\x1a')
squote := '
dquote := "

define nl


endef

quote-spaces = $(subst $(space),$(fsspace),$1)
unquote-spaces = $(subst $(fsspace),$(space),$1)

quote-sh = $(squote)$(subst $(squote),$(squote)$(dquote)$(squote)$(dquote)$(squote),$1)$(squote)

needs-quote-sh = $(findstring $(nl),$1)$(shell echo $(call quote-sh,$1) | sed -e 's/[A-Za-z0-9/_:.-]\+//g')
maybe-quote-sh = $(if $(call needs-quote-sh,$1),$(call quote-sh,$1),$1)

DOCKER_REPO := caliboat
TSFILE := docker-image.ts
SCRIPT := caliboat
VMAP := /tmp/.X11-unix:/tmp/.X11-unix						\
	$(HOME)/.config:/app/.config						\
	$(call quote-spaces,$(HOME)/Calibre Library:/app/Calibre Library)	\
	$(call quote-spaces,$(HOME)/My Kindle Content:/app/My Kindle Content)
VMAP_NQ := "$$TMPDIR:$$TMPDIR" "$$XDG_RUNTIME_DIR:$$XDG_RUNTIME_DIR"
ENV_CP := DISPLAY TMPDIR XDG_RUNTIME_DIR
ADD_PACKAGES :=

UID := $(shell id -u)
GID := $(shell id -g)
DOCKER := docker

all: $(TSFILE) $(SCRIPT)

sudo: DOCKER := sudo $(DOCKER)
sudo: all

$(TSFILE): Makefile Dockerfile
	$(DOCKER) build --build-arg UID=$(UID) --build-arg GID=$(GID)	\
		--build-arg ADD_PACKAGES=$(ADD_PACKAGES)		\
		-t $(call maybe-quote-sh,$(DOCKER_REPO)) .
	touch $@

$(SCRIPT): Makefile Dockerfile
	echo '#! /bin/bash' >$(call maybe-quote-sh,$@)
	echo $(call maybe-quote-sh,[ -t 1 ] && ARGS=-it) >>$(call maybe-quote-sh,$@)
	echo $(call maybe-quote-sh,$(DOCKER) run $$ARGS \\$(nl)						\
		$(foreach i,$(ENV_CP),-e $i="$$$i" \\$(nl))						\
		$(foreach i,$(VMAP),-v $(call maybe-quote-sh,$(call unquote-spaces,$i)) \\$(nl))	\
		$(foreach i,$(VMAP_NQ),-v $(call unquote-spaces,$i) \\$(nl))				\
		$(call maybe-quote-sh,$(DOCKER_REPO)) "$$@") >>$(call maybe-quote-sh,$@)
	chmod a+x $(call maybe-quote-sh,$@)

clean:
	-rm -f $(TSFILE) $(SCRIPT)

repoclean:
	-$(DOCKER) image rm -f $(call maybe-quote-sh,$(DOCKER_REPO))

allclean: clean repoclean
