set(version "master")

execute_process(
    COMMAND ${CMAKE_COMMAND} -E make_directory cmake/Modules
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/cmake/Modules/ExternalProject.cmake")
    # 1. 下载源码包 (加入 -f 参数：如果网络返回404等错误，curl会直接返回非0退出码，不生成空文件)
    execute_process(
        COMMAND curl -fSL -A "Mozilla/5.0" https://github.com/Kitware/CMake/archive/refs/heads/${version}.tar.gz -o cmake_repo.tar.gz
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        RESULT_VARIABLE curl_result
    )

    # 2. 检查下载是否成功
    if(NOT curl_result EQUAL 0 OR NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/cmake_repo.tar.gz")
        message(FATAL_ERROR "Failed to download CMake sources from GitHub. curl exit code: ${curl_result}")
    endif()

    # 3. 核心修复：使用绝对路径指定 tar 包，并用 -C 明确指定解压到的目标目录
    # 这样无论 WORKING_DIRECTORY 是什么，tar 都能准确找到文件并解压到正确位置
    execute_process(
        COMMAND tar -xzf ${CMAKE_CURRENT_BINARY_DIR}/cmake_repo.tar.gz -C ${CMAKE_CURRENT_BINARY_DIR}/cmake --wildcards --strip-components=1 "*/Modules"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        RESULT_VARIABLE tar_result
    )

    # 4. 检查解压是否成功
    if(NOT tar_result EQUAL 0)
        message(FATAL_ERROR "Failed to extract CMake sources. tar exit code: ${tar_result}")
    endif()

    # 5. 应用补丁
    execute_process(
        COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/packages/cmake-0001-ExternalProject-changes.patch
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cmake
    )
endif()

include(${CMAKE_CURRENT_BINARY_DIR}/cmake/Modules/ExternalProject.cmake)
