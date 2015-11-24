xcb-util-keysyms        := xcb-util-keysyms-0.4.0
xcb-util-keysyms_url    := http://xcb.freedesktop.org/dist/$(xcb-util-keysyms).tar.bz2

$(configure-rule):
	cd $(builddir) && ./$(configure) \
		--disable-silent-rules \
		--enable-strict-compilation

$(build-rule):
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,libxcb)
	$(MAKE) -C $(builddir) install
