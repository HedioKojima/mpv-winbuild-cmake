set_property(DIRECTORY PROPERTY EP_STEP_TARGETS download patch configure build install)
include(${PROJECT_SOURCE_DIR}/cmake/packages_check.cmake)
list(APPEND ep
    xz
    uchardet
    zlib
    zstd
    libjpeg
    lcms2
    libpng
    libiconv
    meson-wrap
    luajit
    fribidi
    libxml2
    brotli
    harfbuzz_init
    freetype2
    libudfread
    libbluray
    graphite2
    harfbuzz
    graphengine
    libzimg
    libunibreak
    libass
    nvcodec-headers
    xxhash
    dav1d
    libwebp
    openssl
    libarchive
    highway
    libjxl
    spirv-headers
    spirv-tools
    spirv-cross
    glslang
    vulkan-header
    vulkan
    shaderc
    glad
    fast_float
    svtav1
    libplacebo
    fdk-aac
    ngtcp2
    nghttp3
    nghttp2
    c-ares
    libpsl
    curl
    ffmpeg
    mpv
    sqlite
    mimalloc
)
foreach(package IN LISTS ep)
    if(NOT ${SINGLE_SOURCE_LOCATION} STREQUAL "")
        set(SOURCE_LOCATION "${SINGLE_SOURCE_LOCATION}/${package}")
    endif()
    include(${CMAKE_CURRENT_SOURCE_DIR}/${package}.cmake)
    set(SOURCE_LOCATION "")

    get_property(_git_repository TARGET ${package} PROPERTY _EP_GIT_REPOSITORY)
    if(_git_repository)
        list(APPEND repo ${package})
    endif()
endforeach()
list(LENGTH ep ep_length)
message(STATUS "Parsing ${ep_length} packages")

# Exclude packages which dont depend on mpv when update
list(APPEND removed "libvpx" "vvenc")
list(REMOVE_ITEM repo ${removed})
list(REMOVE_ITEM ep ${removed})
list(TRANSFORM repo APPEND "-force-update" OUTPUT_VARIABLE update)
list(TRANSFORM ep APPEND "-download" OUTPUT_VARIABLE download)
list(TRANSFORM ep APPEND "-patch" OUTPUT_VARIABLE patch)
list(TRANSFORM ep APPEND "-fullclean" OUTPUT_VARIABLE fullclean)

add_custom_target(update
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${update}
    COMMENT "Updating git repo"
)

add_custom_target(download
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${download}
)

add_custom_target(patch
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${patch}
)

add_custom_target(fullclean
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${fullclean}
    COMMENT "Remove all build and stamp files, reset git HEAD"
)

add_custom_target(ccache-recomp
    COMMAND ${EXEC} ccache -X 22
    USES_TERMINAL
)

add_dependencies(update download)
add_dependencies(patch download)
