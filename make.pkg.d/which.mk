which                   := which-2.21
which_url               := http://ftpmirror.gnu.org/which/$(which).tar.gz

$(configure-rule):
	cd $(builddir) && ./$(configure)

$(build-rule):
	$(MAKE) -C $(builddir) all

$(install-rule): $$(call installed,glibc)
	$(MAKE) -C $(builddir) install
	$(INSTALL) -Dpm 644 $(call addon-file,bashrc.sh) $(DESTDIR)/etc/bashrc.d/which.sh

# Write inline files.
$(call addon-file,bashrc.sh): | $$(@D)
	$(file >$@,$(contents))
$(prepared): $(call addon-file,bashrc.sh)


# Provide a bash alias that executes a more functional "which" command.
override define contents
alias which='( alias ; declare -f ) | which --tty-only --read-alias --read-functions --show-tilde --show-dot'
endef
$(call addon-file,bashrc.sh): private override contents := $(value contents)
