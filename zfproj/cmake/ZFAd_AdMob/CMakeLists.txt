cmake_minimum_required(VERSION 3.16)
project(ZFAd_AdMob)
set(ZF_ROOT_PATH "${PROJECT_SOURCE_DIR}/../../../../../../ZFFramework")
include("${ZF_ROOT_PATH}/tools/spec/cmake/util.cmake")
add_compile_options("$<$<CONFIG:DEBUG>:-DDEBUG>")

include("${PROJECT_SOURCE_DIR}/zfprojConfig.cmake" OPTIONAL)

file(GLOB_RECURSE ZF_SRC_FILES RELATIVE "${PROJECT_SOURCE_DIR}"
    "${PROJECT_SOURCE_DIR}/../../../zfsrc/*.c"
    "${PROJECT_SOURCE_DIR}/../../../zfsrc/*.cpp"
    "${PROJECT_SOURCE_DIR}/../../../zfsrc_ext/*.c"
    "${PROJECT_SOURCE_DIR}/../../../zfsrc_ext/*.cpp"
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
    target_link_libraries(ZFAd_AdMob ${ZF_LIB_NAME_})
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
if(WIN32)
    execute_process(COMMAND "${ZF_ROOT_PATH}\\tools\\util\\copy_res.bat" "${PROJECT_SOURCE_DIR}\\..\\..\\..\\zfres\\" "${ZF_ROOT_PATH}\\_release\\cmake\\module\\ZFAd_AdMob\\zfres")
else()
    execute_process(COMMAND sh "${ZF_ROOT_PATH}/tools/util/copy_res.sh" "${PROJECT_SOURCE_DIR}/../../../zfres/" "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/zfres")
endif()

install(
    DIRECTORY "${ZF_ROOT_PATH}/_release/cmake/module/ZFAd_AdMob/"
    DESTINATION "${ZF_ROOT_PATH}/_release/cmake/all"
    )

