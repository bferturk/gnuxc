libXdamage              := libXdamage-1.1.4
libXdamage_sha1         := c3fc0f4b02dce2239bf46c82a5f06b06585720ae
libXdamage_url          := http://xorg.freedesktop.org/releases/individual/lib/$(libXdamage).tar.bz2

$(configure-rule):
	cd $(builddir) && ./$(configure) \
		--enable-strict-compilation

$(build-rule):
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,damageproto libXfixes)
	$(MAKE) -C $(builddir) install
