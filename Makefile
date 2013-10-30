tomatoware:
	./scripts/toolchain.sh
	./scripts/install.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

clean:
	rm -rf ./opt ./opt.tgz
	find . -iname ".extracted" -exec rm {} \;
