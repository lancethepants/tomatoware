# Buildroot patches lua's module search root to /usr/. Hooks run after the
# patches, so this has the last word.
define LUA_TOMATOWARE_ROOT
	$(SED) 's|#define LUA_ROOT.*|#define LUA_ROOT "$(TOMATOWARE_PREFIX)/"|' $(@D)/src/luaconf.h
endef
LUA_POST_PATCH_HOOKS += LUA_TOMATOWARE_ROOT
