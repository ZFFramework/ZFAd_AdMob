cmake_minimum_required(VERSION 3.16)
project(ZFAd_AdMob)
set(ZF_ROOT_PATH "${PROJECT_SOURCE_DIR}/../../../../../../ZFFramework")
include("${ZF_ROOT_PATH}/tools/spec/cmake/util.cmake")
add_compile_options("$<$<CONFIG:DEBUG>:-DDEBUG>")

include("${PROJECT_SOURCE_DIR}/zfprojConfig.cmake" OPTIONAL)

zfprojSrcFiles(
    ZF_SRC_FILES
    "${CMAKE_BINARY_DIR}/zfgensrc_ZFAd_AdMob.cpp"
    "${ZF_ROOT_PATH}"
    "${PROJECT_SOURCE_DIR}"
    "${PROJECT_SOURCE_DIR}/../../.."
    )
if(COMMAND zfprojConfigBefore_ZFAd_AdMob)
    zfprojConfigBefore_ZFAd_AdMob(ZFAd_AdMob ZF_SRC_FILES)
endif()
add_library(ZFAd_AdMob SHARED ${ZF_SRC_FILES})
zfprojStripFILE(ZFAd_AdMob)
set_target_properties(ZFAd_AdMob PROPERTIES LINKER_LANGUAGE CXX)
target_compile_definitions(ZFAd_AdMob PUBLIC ZFLIB_ZFAd_AdMob=ZF_ENV_EXPORT)
if(COMMAND zfprojConfigAfter_ZFAd_AdMob)
    zfprojConfigAfter_ZFAd_AdMob(ZFAd_AdMob)
endif()

target_include_directories(ZFAd_AdMob PRIVATE "${PROJECT_SOURCE_DIR}/../../../zfsrc")

function(ZFAddLib ZF_LIB_NAME_)
    target_include_directories(ZFAd_AdMob PRIVATE "${ZF_ROOT_PATH}/_release/cmake/all/include")
    target_link_directories(ZFAd_AdMob PUBLIC "${ZF_ROOT_PATH}/_release/cmake/module/${ZF_LIB_NAME_}/lib")
    target_link_libraries(ZFAd_AdMob PRIVATE ${ZF_LIB_NAME_})
endfunction()

ZFAddLib(ZFCore)
ZFAddLib(ZFUtility)
ZFAddLib(ZFAlgorithm)
ZFAddLib(ZFUIKit)
ZFAddLib(ZF_impl)
ZFAddLib(ZFAd)

install(
    DIRECTORY "${PROJECT_SOURCE_DIR}/../../../zfsrc/"
    DESTINATION "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/include"
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
    )
install(
    TARGETS ZFAd_AdMob
    DESTINATION "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/lib"
    )
install(
    DIRECTORY "${PROJECT_SOURCE_DIR}/../../../zfres/"
    DESTINATION "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/zfres"
    PATTERN "ZF_PUT_RES_FILES_HERE" EXCLUDE
    )

install(
    DIRECTORY "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/"
    DESTINATION "${ZF_ROOT_PATH}/_release/cmake/all"
    )

