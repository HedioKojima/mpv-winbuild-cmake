ExternalProject_Add(ffmpeg
    DEPENDS
        nvcodec-headers
        lcms2
        openssl
        libass
        libbluray
        libpng
        libwebp
        libzimg
        harfbuzz
        libxml2
        libjxl
        libplacebo
        svtav1
        dav1d
        fdk-aac
        vulkan
        xz
        curl
        freetype2
        fribidi
    GIT_REPOSITORY https://github.com/Andarwinux/FFmpeg.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--depth=1 --sparse --filter=tree:0"
    GIT_PROGRESS TRUE
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    UPDATE_COMMAND ""
    CONFIGURE_ENVIRONMENT_MODIFICATION
        _IS_CONFIGURE=set:1
    CONFIGURE_COMMAND ${EXEC} <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw64
        --pkg-config-flags=--static
        --disable-autodetect
        --disable-decoder=libaom_av1,aac_fixed,ac3_fixed,mp1,mp2,mp3,mp3adu,mp3on4
        --disable-doc
        --disable-encoders
        --enable-encoder=libjxl
        --enable-encoder=libsvtav1
        --enable-encoder=libwebp
        --enable-encoder=png
        --enable-encoder=mjpeg
        --disable-ffplay
        --disable-inline-asm
        --disable-schannel
        --disable-stripping
        --disable-symver
        --enable-cross-compile
        --enable-cuda-llvm
        --enable-d3d11va
        --enable-d3d12va
        --enable-ffnvcodec
        --enable-gpl
        --enable-hardcoded-tables
        --enable-iconv
        --enable-lcms2
        --enable-libass
        --enable-libbluray
        --enable-libcurl
        --enable-libdav1d
        --enable-libfdk-aac
        --enable-libfreetype
        --enable-libfribidi
        --enable-libharfbuzz
        --enable-libjxl
        --enable-libplacebo
        --enable-libsvtav1
        --enable-libwebp
        --enable-libxml2
        --enable-libzimg
        --enable-lzma
        --enable-nonfree
        --enable-nvdec
        --enable-nvenc
        --enable-openssl
        --enable-response-files
        --enable-runtime-cpudetect
        --enable-version3
        --enable-vulkan
        --enable-w32threads
        --enable-zlib
        --extra-libs=-lc++
        --host-cc=clang
        --nvcc=nvcc
    ${trim_path} <BINARY_DIR>/config.h
    BUILD_ENVIRONMENT_MODIFICATION
        _PACKAGE_NAME=set:${package}
        _BINARY_DIR=set:<BINARY_DIR>
        _IS_EXCEPTIONS_ALLOWED=set:1
        _FULL_DEBUGINFO=set:1
    BUILD_COMMAND ""
          #${ffmpeg_nosse2avx}
          COMMAND ${MAKE} ffmpeg.exe ffprobe.exe
    INSTALL_COMMAND ${MAKE} install-headers install-libs install-progs
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)
force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
