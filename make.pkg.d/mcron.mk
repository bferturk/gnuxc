mcron                   := mcron-1.0.8
mcron_url               := http://ftpmirror.gnu.org/mcron/$(mcron).tar.gz

$(prepare-rule):
	$(call apply,fix-everything)
	$(RM) $(builddir)/configure

$(configure-rule):
	cd $(builddir) && ./$(configure) \
		--disable-no-vixie-clobber \
		--enable-debug \
		--with-allow-file=/etc/cron.allow \
		--with-deny-file=/etc/cron.deny \
		--with-pid-file=/run/cron.pid \
		--with-socket-file=/run/cron.socket \
		--with-spool-dir=/var/spool/cron \
		--with-tmp-dir=/tmp

$(build-rule):
ifneq ($(host),$(build))
	$(MAKE) -C $(builddir) mcron.c
	$(TOUCH) $(builddir)/mcron.1
endif
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,guile)
	$(MAKE) -C $(builddir) install
	$(INSTALL) -Dpm 644 $(call addon-file,mcron.scm) $(DESTDIR)/etc/dmd.d/mcron.scm
	$(INSTALL) -Dm 644 /dev/null $(DESTDIR)/etc/crontab
	$(INSTALL) -dm 755 $(DESTDIR)/etc/cron.d

# Write inline files.
$(call addon-file,mcron.scm): | $$(@D)
	$(file >$@,$(contents))
$(prepared): $(call addon-file,mcron.scm)


# Provide a system service definition for "mcron".
override define contents
(define mcron-command
  '("/usr/bin/cron"
    "--noetc"))
(make <service>
  #:docstring "The mcron service runs scheduled commands."
  #:provides '(mcron cron crond)
  #:requires '()
  #:start (make-forkexec-constructor mcron-command)
  #:stop (make-kill-destructor))
endef
$(call addon-file,mcron.scm): private override contents := $(value contents)
