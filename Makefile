include config.mk

tomatoware:toolchain
	echo 0 > .count
	./scripts/host-tools.sh
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

toolchain:
	./scripts/toolchain.sh

clean:
	rm -rf toolchain
	git clean -fdxq && git reset --hard

toolchain-clean:
	rm -rf toolchain
	rm -rf /opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))
