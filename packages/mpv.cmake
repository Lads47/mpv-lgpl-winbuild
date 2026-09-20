ExternalProject_Add(mpv
    DEPENDS
        angle-headers
        ffmpeg
        fribidi
        lcms2
        libarchive
        libass
        libdvdread
        libiconv
        libjpeg
        libpng
        luajit
        uchardet
        openal-soft
        vulkan
        shaderc
        libplacebo
        spirv-cross
        vapoursynth
        libsdl2
        libsixel
    GIT_REPOSITORY https://github.com/mpv-player/mpv.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 meson setup <BINARY_DIR> <SOURCE_DIR>
        --prefix=${MINGW_INSTALL_PREFIX}
        --libdir=${MINGW_INSTALL_PREFIX}/lib
        --cross-file=${MESON_CROSS}
        --default-library=shared
        --prefer-static
        -Ddebug=true
        -Db_ndebug=true
        -Doptimization=3
        -Db_lto=true
        ${mpv_lto_mode}
        -Dlibmpv=true
        # ═══ BUILD LGPL — voir LGPL.md ═══
        #
        # -Dgpl=false est l'option officielle de mpv : « GPL (version 2 or
        # later) build », vraie par defaut. A false, libmpv est LGPLv2.1+.
        # Meson ecarte alors de lui-meme les fonctions GPL (cdda, dvbin, dvda,
        # dvdnav, jack, oss, caca, direct3d, x11) ; sur Windows la seule qui
        # nous concerne est vo_direct3d, et EVA Pilot rend en OpenGL.
        -Dgpl=false
        # Et deux bibliotheques que meson ne surveille PAS, mais dont la
        # licence ne convient pas a un logiciel proprietaire :
        #   mujs        AGPLv3 (ou commerciale) — pire que la GPL ici
        #   rubberband  GPLv2+ (ou commerciale) — sert au son en vitesse
        #               variable, qu'EVA Pilot n'utilise pas
        -Djavascript=disabled
        -Drubberband=disabled
        -Ddvdnav=disabled
        # ⚠ subrandr rend les sous-titres SRV3 et WebVTT -- ceux de YouTube.
        # EVA Pilot n'affiche aucun sous-titre. Et il est ecrit en Rust : le
        # desactiver retire toute une chaine d'outils de plus (le 5e passage
        # est tombe la-dessus, « cargo: 127 », faute de rustup dans le fork).
        -Dsubrandr=disabled
        -Dpdf-build=enabled
        -Dlua=enabled
        -Dsdl2-gamepad=enabled
        -Dlibarchive=enabled
        -Dlibbluray=enabled
        -Duchardet=enabled
        -Dlcms2=enabled
        -Dopenal=enabled
        -Dspirv-cross=enabled
        -Dvulkan=enabled
        -Dvapoursynth=enabled
        -Dsubrandr=enabled
        -Dsixel=enabled
        ${mpv_gl}
        # ⚠ CURL S'EN VA, ET AVEC LUI ngtcp2 : c'est lui qui a fait tomber le
        # premier passage (« Performing configure step for ngtcp2 » -> FAILED).
        # EVA Pilot lit des fichiers LOCAUX ; mpv n'a aucun usage du reseau ici.
        -Dlibcurl=disabled
        -Dc_args='-Wno-error=int-conversion'
    BUILD_COMMAND ${EXEC} LTO_JOB=1 PDB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(mpv strip-binary
    DEPENDEES build
    ${mpv_add_debuglink}
    COMMENT "Stripping mpv binaries"
)

ExternalProject_Add_Step(mpv copy-binary
    DEPENDEES strip-binary
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/mpv.exe                           ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv.exe
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/mpv.com                           ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv.com
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/etc/mpv-register.bat              ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv-register.bat
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/etc/mpv-unregister.bat            ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv-unregister.bat
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/mpv.pdf                           ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/doc/manual.pdf
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/etc/fonts/fonts.conf   ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv/fonts.conf
    ${mpv_copy_debug}
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv-2.dll          ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/libmpv-2.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv.dll.a          ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/libmpv.dll.a
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/client.h       ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/include/mpv/client.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/stream_cb.h    ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/include/mpv/stream_cb.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render.h       ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/include/mpv/render.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render_gl.h    ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev/include/mpv/render_gl.h
    COMMENT "Copying mpv binaries and manual"
)

set(RENAME ${CMAKE_CURRENT_BINARY_DIR}/mpv-prefix/src/rename.sh)
file(WRITE ${RENAME}
"#!/bin/bash
cd $1
GIT=$(git rev-parse --short=10 HEAD)
mv $2 $2-git-\${GIT}")

ExternalProject_Add_Step(mpv copy-package-dir
    DEPENDEES copy-binary
    COMMAND chmod 755 ${RENAME}
    COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/mpv-package ${CMAKE_BINARY_DIR}/mpv-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_BINARY_DIR}/mpv-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}

    COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/mpv-debug ${CMAKE_BINARY_DIR}/mpv-debug-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_BINARY_DIR}/mpv-debug-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}

    COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/mpv-dev ${CMAKE_BINARY_DIR}/mpv-dev-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_BINARY_DIR}/mpv-dev-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMENT "Moving mpv package folder"
    LOG 1
)

force_rebuild_git(mpv)
force_meson_configure(mpv)
cleanup(mpv copy-package-dir)
