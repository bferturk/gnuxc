libXdamage              := libXdamage-1.1.4
libXdamage_url          := http://xorg.freedesktop.org/releases/individual/lib/$(libXdamage).tar.bz2

$(configure-rule):
	cd $(builddir) && ./$(configure) \
		--disable-silent-rules \
		--enable-strict-compilation

$(build-rule):
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,damageproto libXfixes)
	$(MAKE) -C $(builddir) install
