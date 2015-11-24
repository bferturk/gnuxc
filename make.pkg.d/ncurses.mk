ncurses                 := ncurses-6.0-20151121
ncurses_url             := http://invisible-mirror.net/archives/ncurses/current/$(ncurses).tgz

ifeq ($(host),$(build))
export NCURSES_CONFIG   = ncurses6-config
export NCURSESW_CONFIG  = ncursesw6-config
export NCURSEST_CONFIG  = ncursest6-config
export NCURSESTW_CONFIG = ncursestw6-config
else
export NCURSES_CONFIG   = $(host)-ncurses6-config
export NCURSESW_CONFIG  = $(host)-ncursesw6-config
export NCURSEST_CONFIG  = $(host)-ncursest6-config
export NCURSESTW_CONFIG = $(host)-ncursestw6-config
endif

$(call configure-rule,classic pthread widec widec+pthread): configure := $(configure:--docdir%=)
$(call configure-rule,classic pthread widec widec+pthread): configure := $(configure:--localedir%=)
$(call configure-rule,classic pthread widec widec+pthread): private override configuration := --exec-prefix= \
	\
	--disable-relink \
	--disable-rpath \
	--disable-rpath-hack \
	--enable-assertions \
	--enable-colorfgbg \
	--enable-overwrite \
	--enable-pc-files --with-pkg-config-libdir='/usr/lib/pkgconfig' \
	--enable-warnings \
	--with-debug \
	--with-shared --with-cxx-shared \
	--with-termlib \
	--with-ticlib \
	--without-dlsym \
	\
	--without-gpm

$(call configure-rule,classic): $(builddir)/configure
	$(MKDIR) $(builddir)/classic && cd $(builddir)/classic && ../$(configure) $(configuration) \
		--includedir='$${prefix}/include/ncurses'
$(call configure-rule,pthread): $(builddir)/configure
	$(MKDIR) $(builddir)/pthread && cd $(builddir)/pthread && ../$(configure) $(configuration) \
		--includedir='$${prefix}/include/ncursest' \
		--with-pthread
$(call configure-rule,widec): $(builddir)/configure
	$(MKDIR) $(builddir)/widec && cd $(builddir)/widec && ../$(configure) $(configuration) \
		--includedir='$${prefix}/include/ncursesw' \
		--enable-ext-colors \
		--enable-widec
$(call configure-rule,widec+pthread): $(builddir)/configure
	$(MKDIR) $(builddir)/widec+pthread && cd $(builddir)/widec+pthread && ../$(configure) $(configuration) \
		--includedir='$${prefix}/include/ncursestw' \
		--enable-ext-colors \
		--enable-widec \
		--with-pthread

$(configure-rule): $(call configured,classic pthread widec widec+pthread)

$(call build-rule,classic): $(call configured,classic)
	$(MAKE) -C $(builddir)/classic libs
$(call build-rule,pthread): $(call configured,pthread)
	$(MAKE) -C $(builddir)/pthread libs
$(call build-rule,widec): $(call configured,widec)
	$(MAKE) -C $(builddir)/widec libs
$(call build-rule,widec+pthread): $(call configured,widec+pthread)
	$(MAKE) -C $(builddir)/widec+pthread all

$(build-rule): $(call built,classic pthread widec widec+pthread)

$(install-rule): $$(call installed,glibc)
	$(MAKE) -C $(builddir)/classic       install.libs
	$(MAKE) -C $(builddir)/pthread       install.libs
	$(MAKE) -C $(builddir)/widec         install.libs
	$(MAKE) -C $(builddir)/widec+pthread install
