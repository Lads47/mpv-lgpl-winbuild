ExternalProject_Add(mingw-w64
    GIT_REPOSITORY https://github.com/mingw-w64/mingw-w64.git
    # ⛔ FIGE AU 20/10/2026 (EVA Pilot, 24/10). Le commit 4b51967147 du 22/10
    # (« crt: Define FE_DFL_ENV next to _fpreset ») casse l'edition des liens de
    # toute DLL C++ : « libmingwex.a(fesetenv.o): undefined reference to
    # __mingw_fe_dfl_env » (shaderc / SPIRV-Tools). L'amont n'a plus publie
    # depuis le 21/10. A relacher quand mingw-w64 l'aura corrige.
    GIT_TAG a9d9717d10341f18cfbf8752e100deaab0f1aa1a
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1
)

force_rebuild_git(mingw-w64)
get_property(MINGW_SRC TARGET mingw-w64 PROPERTY _EP_SOURCE_DIR)
