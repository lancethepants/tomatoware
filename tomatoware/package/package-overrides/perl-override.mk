# perl.mk passes --prefix=/usr to perl-cross itself, and perl-cross keeps
# the first --prefix it sees, so appending is not enough: take it out.
$(eval PERL_CONF_OPTS_BUILDROOT = $(value PERL_CONF_OPTS))
PERL_CONF_OPTS = \
	$(filter-out --prefix=/usr,$(PERL_CONF_OPTS_BUILDROOT)) \
	--prefix=$(TOMATOWARE_PREFIX) \
	-Dlibpth=$(TOMATOWARE_PREFIX)/lib

# perl has to know how the C library formats setlocale(LC_ALL, NULL) when
# the categories differ. That is found by running a test program, which
# perl-cross can't do, so it assumes glibc's "LC_CTYPE=a;LC_NUMERIC=b" form.
# musl returns the bare names in category order, "a;b;c;d;e;f", and perl
# panics on it as soon as any category is not "C" (musl's own default for
# LC_CTYPE is C.UTF-8). The positions are musl's LC_* values, LC_CTYPE
# through LC_MESSAGES.
PERL_CONF_OPTS += \
	-Dd_perl_lc_all_uses_name_value_pairs=undef \
	-Dd_perl_lc_all_separator=define \
	-Dperl_lc_all_separator='";"' \
	-Dd_perl_lc_all_category_positions_init=define \
	-Dperl_lc_all_category_positions_init='{ 0, 1, 2, 3, 4, 5 }'
