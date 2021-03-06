bc                      := bc-1.07.1
bc_key                  := 00E426232F384BF6D32D8B1881C24FF12FB7B14B
bc_url                  := http://ftpmirror.gnu.org/bc/$(bc).tar.gz

ifneq ($(host),$(build))
$(call configure-rule,native): $(builddir)/configure
	cd $(builddir) && $(native) ./configure
$(call build-rule,native): $(call configured,native)
	$(MAKE) -C $(builddir)/lib all
	$(MAKE) -C $(builddir)/bc libmath.h
	$(MAKE) -C $(builddir) clean
	$(EDIT) '/^libmath.h:/s/:.*/:/' $(builddir)/bc/Makefile.in
$(configure-rule): $(call built,native)
endif

$(configure-rule):
	cd $(builddir) && ./$(configure) \
		--with-readline

$(build-rule):
	$(MAKE) -C $(builddir)/lib all # Run this first for parallel builds.
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,readline)
	$(MAKE) -C $(builddir) install
