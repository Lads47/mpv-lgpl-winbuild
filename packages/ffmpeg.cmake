ExternalProject_Add(ffmpeg
    DEPENDS
        amf-headers
        avisynth-headers
        nvcodec-headers
        bzip2
        lame
        lcms2
        openssl
        libssh
        libsrt
        libass
        libbluray
        libmodplug
        libpng
        libsoxr
        libbs2b
        libvpx
        libwebp
        libzimg
        libmysofa
        fontconfig
        harfbuzz
        opus
        speex
        vorbis
        libxml2
        libvpl
        libopenmpt
        libjxl
        libplacebo
        libzvbi
        libaribcaption
        # ⚠ x264, x265, libdvdnav et libdvdread ne sont plus construits DU TOUT :
        # ils n'etaient plus lies depuis le passage en LGPL, mais la chaine les
        # compilait quand meme -- des minutes de CI pour du code qu'on refuse.
        aom
        svtav1
        dav1d
        vapoursynth
        ${ffmpeg_uavs3d}
        ${ffmpeg_davs2}
        libva
        openal-soft
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile
        --enable-runtime-cpudetect
        # ═══ SANS LES PARTIES GPL — voir LGPL.md ═══
        #
        # `--enable-gpl` et `--enable-version3` sont retires. Les bibliotheques
        # ci-dessous le sont aussi parce que le configure de FFmpeg les range
        # dans EXTERNAL_LIBRARY_GPL_LIST et refuserait de construire sans
        # `--enable-gpl` : avisynth, libdvdnav, libdvdread, librubberband,
        # libx264, libx265.
        #
        # ⚠ x264 et x265 sont des ENCODEURS. Les decodeurs H.264 et HEVC sont
        # natifs dans libavcodec et LGPL : on ne perd aucune lecture.
        --enable-vapoursynth
        --enable-libass
        --enable-libbluray
        --enable-libfreetype
        --enable-libfribidi
        --enable-libfontconfig
        --enable-libharfbuzz
        --enable-libmodplug
        --enable-libopenmpt
        --enable-libmp3lame
        --enable-lcms2
        --enable-libopus
        --enable-libsoxr
        --enable-libspeex
        --enable-libvorbis
        --enable-libbs2b
        --enable-libvpx
        --enable-libwebp
        --enable-libaom
        --enable-libsvtav1
        --enable-libdav1d
        ${ffmpeg_davs2_cmd}
        ${ffmpeg_uavs3d_cmd}
        --enable-libzimg
        --enable-openssl
        --enable-libxml2
        --enable-libmysofa
        --enable-libssh
        --enable-libsrt
        --enable-libvpl
        --enable-libjxl
        --enable-libplacebo
        --enable-libzvbi
        --enable-libaribcaption
        --enable-cuda-llvm
        --enable-cuvid
        --enable-nvdec
        --enable-nvenc
        --enable-amf
        --enable-openal
        --enable-opengl
        --disable-doc
        --disable-ffplay
        --disable-ffprobe
        --enable-vaapi
        --disable-vdpau
        --disable-videotoolbox
        --disable-decoder=libaom_av1
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'" # -lstdc++ / -lc++ needs by libjxl and shaderc
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
