#!/usr/bin/make -f
# Copyright (C) 2013,2014,2015 David Michael <fedora.dm0@gmail.com>
#
# This file is part of gnuxc.
#
# gnuxc is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# gnuxc is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# gnuxc.  If not, see <http://www.gnu.org/licenses/>.

# Locate build system components.
makefile := $(lastword $(MAKEFILE_LIST))
pkgdir   := $(dir $(makefile))make.pkg.d
patchdir := $(dir $(makefile))patches

# Determine the cross-compilation system types.
arch  := i686
build := $(MAKE_HOST)
host  := $(arch)-pc-gnu
ifneq ($(host),$(build))
sysroot = /usr/$(host)/sys-root
export CONFIG_SITE = $(sysroot)/usr/share/config.site
export .LIBPATTERNS = $(sysroot)/usr/lib/lib%.so $(sysroot)/usr/lib/lib%.a
endif

# Customize these settings on the command-line, if desired.
export DESTDIR := $(CURDIR)/gnu-root
export CFLAGS   = -O2 -g -pipe -Wall -Werror=format-security \
	-Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong \
	--param=ssp-buffer-size=4 -grecord-gcc-switches
export CXXFLAGS = $(CFLAGS)
export LDFLAGS  = -Wl,-z,relro

# Set up GNU extensions, and don't pass command-line variables to the projects.
override MAKEOVERRIDES :=
override SHELL := /bin/bash
override .SHELLFLAGS := --posix -c
.SECONDEXPANSION:

# Configure external commands and their default behavior.
AUTOGEN  := autoreconf --force --install
CONVERT  := convert
COPY     := cp --force
CVS      := cvs
DOWNLOAD := wget --content-on-error --output-document=-
ECHO     := echo
EDIT     := sed --in-place
GIT      := git -c user.name='GNU Hacker' -c user.email='root@localhost'
INSTALL  := install
LINK     := ln --force
MKDIR    := mkdir --parents
MOVE     := mv --force
PATCH    := patch --force --fuzz=0 --strip=0
SYMLINK  := ln --force --no-dereference --symbolic
RM       := rm --force
RMDIR    := rmdir
TAR      := tar --no-same-owner --numeric-owner --overwrite --owner=0 --group=0
TOUCH    := touch
UNZIP    := unzip -q

# Define the template for configuring packages.
configure = configure \
	--build=$(build) --host=$(host) --target=$(host) \
	--program-prefix= \
	--prefix=/usr \
	--exec-prefix='$${prefix}' \
	--bindir='$${exec_prefix}/bin' \
	--datadir='$${datarootdir}' \
	--datarootdir='$${prefix}/share' \
	--docdir='$${datarootdir}/doc/$${PACKAGE_TARNAME}' \
	--includedir='$${prefix}/include' \
	--infodir='$${datarootdir}/info' \
	--libdir='$${exec_prefix}/lib' \
	--libexecdir='$${exec_prefix}/libexec' \
	--localedir='$${datarootdir}/locale' \
	--localstatedir=/var \
	--mandir='$${datarootdir}/man' \
	--oldincludedir='$${includedir}' \
	--sbindir='$${exec_prefix}/sbin' \
	--sharedstatedir='$${localstatedir}/lib' \
	--sysconfdir=/etc

# Manually decompress source archives on the fly to save disk space.
targ_bz2  := --bzip2
targ_gz   := --gzip
targ_lz   := --lzip
targ_lzma := --lzma
targ_tgz  := $(targ_gz)
targ_xz   := --xz

# Declare generic targets for the user interface.
packages := $(patsubst $(pkgdir)/%.mk,%,$(wildcard $(pkgdir)/*.mk))
packages-requested := $(filter-out $(subst *,%,$(exclude)),$(packages))

.PHONY: all $(packages) \
    prepare $(packages:%=prepare-%) \
  configure $(packages:%=configure-%) \
      build $(packages:%=build-%) \
    install $(packages:%=install-%) \
      clean $(packages:%=clean-%)

all: $(packages-requested)
prepare: $(packages-requested:%=prepare-%)
configure: $(packages-requested:%=configure-%)
build: $(packages-requested:%=build-%)
install: $(packages-requested:%=install-%)
clean: $(packages-requested:%=clean-%)

# Include some common build system shortcuts.
self = $(basename $(notdir $(lastword $(MAKEFILE_LIST))))
builddir = $(firstword $(subst /, ,$(or $@,$($(self)))))
addon-file = $(1:%=$(builddir)/.gnuxc/%)
apply = $(1:%=$(PATCH) --directory=$(builddir) \
	< $(patchdir)/$(builddir)-%.patch &&) :
drop-rpath = $(EDIT) 's/\(need_relink\)=yes/\1=no/' $(2:%=$(builddir)/%) && \
	$(EDIT) $(1:%=$(builddir)/%) -e 's/\(hardcode_into_libs\)=yes/\1=no/' \
	-e 's/\(hardcode_libdir_flag_spec[A-Za-z_]*\)=.*/\1=-D__BAD_LIBTOOL__/'

# Declare variables to abstract packages' build states/timestamps.
prepare-rule   = $(or $(1:%=$($(self))/.gnuxc/prepare-%-rule),\
	$($(self))/.gnuxc/prepare-rule)
configure-rule = $(or $(1:%=$($(self))/.gnuxc/configure-%-rule),\
	$($(self))/.gnuxc/configure-rule)
build-rule     = $(or $(1:%=$($(self))/.gnuxc/build-%-rule),\
	$($(self))/.gnuxc/build-rule)
install-rule   = $(or $(1:%=$($(self))/.gnuxc/install-%-rule),\
	$($(self))/.gnuxc/install-rule)
prepared   = $(foreach p,$(or $(1:%=-%-),-),$($(self))/.gnuxc/prepare$pstamp)
configured = $(foreach p,$(or $(1:%=-%-),-),$($(self))/.gnuxc/configure$pstamp)
built      = $(foreach p,$(or $(1:%=-%-),-),$($(self))/.gnuxc/build$pstamp)
installed  = $(foreach p,$(or $1,$(self)),$($p)/.gnuxc/install-stamp)
%-stamp: %-rule
	$(TOUCH) $(@D)/$(<F) && $(LINK) $(@D)/$(<F) $@

# Define the skeleton targets for each package's build phases.
define init-package-rules =
$$($1):
ifeq ($$(firstword $$(subst ://, ,$$($1_url))),git)
	$$(GIT) clone $$($1_branch:%=--branch=%) -n '$$($1_url)' $$@
	$$(GIT) -C $$@ reset --hard $$($1_snap)
else ifeq ($$(firstword $$(subst ://, ,$$($1_url))),cvs)
	$$(CVS) -d'$$($1_url:cvs://%=:pserver:%)' export \
		-D$$($1_snap) -d$$@ -kv $$(or $$($1_branch),$1)
else ifneq ($$(filter tar tgz,$$(subst ., ,$$($1_url))),)
	$$(DOWNLOAD) '$$($1_url)' | \
	$$(TAR) $$($1_branch:%=--transform='s,^/*%/*,$$@/,') \
		$$(targ_$$(lastword $$(subst ., ,$$($1_url)))) -x
else ifeq ($$(lastword $$(subst ., ,$$($1_url))),zip)
	$$(MKDIR) $$@/.gnuxc
	$$(DOWNLOAD) '$$($1_url)' > $$@/.gnuxc/$$@.zip
	$$(UNZIP) $$@/.gnuxc/$$@.zip
else
	$$(MKDIR) $$@
endif
$$($1)/.gnuxc: | $$($1)
	$$(MKDIR) $$@
$$($1)/configure: $$($1)/.gnuxc/prepare-stamp
	test -x $$@ || \
	( test -f $$@.ac -o -f $$@.in && $$(AUTOGEN) $$(@D) ) ; \
	$$(TOUCH) $$@

$$($1)/.gnuxc/prepare-rule: | $$($1)/.gnuxc
$$($1)/.gnuxc/configure-rule: $$($1)/configure
$$($1)/.gnuxc/build-rule: $$($1)/.gnuxc/configure-stamp
$$($1)/.gnuxc/install-rule: $$($1)/.gnuxc/build-stamp

prepare-$1: $$($1)/configure
configure-$1: $$($1)/.gnuxc/configure-stamp
build-$1 $1: $$($1)/.gnuxc/build-stamp
install-$1: $$($1)/.gnuxc/install-stamp
clean-$1:
	$$(RM) --recursive $$($1)
endef

# Declare the package rules.
include $(pkgdir)/*.mk
$(foreach package,$(packages),$(eval $(call init-package-rules,$(package))))
