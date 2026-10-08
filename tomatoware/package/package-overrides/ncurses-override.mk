# ncurses.mk spells the terminfo location out instead of deriving it from
# the prefix.
NCURSES_CONF_OPTS += \
	--with-default-terminfo-dir=$(TOMATOWARE_PREFIX)/share/terminfo \
	--with-terminfo-dirs=$(TOMATOWARE_PREFIX)/share/terminfo
