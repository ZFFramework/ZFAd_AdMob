cmake_minimum_required(VERSION 3.16)
project(ZFAd_AdMob)
set(ZF_ROOT_PATH "${PROJECT_SOURCE_DIR}/../../../../../../../ZFFramework")
include("${ZF_ROOT_PATH}/tools/spec/cmake/util.cmake")

include("${PROJECT_SOURCE_DIR}/zfprojConfig.cmake" OPTIONAL)

zfprojSrcFiles(
    ZF_SRC_FILES
    "${CMAKE_BINARY_DIR}/zfgensrc/zfgensrc_ZFAd_AdMob.cpp"
    "${ZF_ROOT_PATH}"
    "${PROJECT_SOURCE_DIR}"
    "${PROJECT_SOURCE_DIR}/../../../.."
    )
if(COMMAND zfprojConfigBefore_ZFAd_AdMob)
    zfprojConfigBefore_ZFAd_AdMob(ZFAd_AdMob ZF_SRC_FILES)
endif()
add_library(ZFAd_AdMob SHARED ${ZF_SRC_FILES})
target_compile_options(ZFAd_AdMob PRIVATE "$<$<CONFIG:DEBUG>:-DDEBUG>")
zfprojStripFILE(ZFAd_AdMob)
set_target_properties(ZFAd_AdMob PROPERTIES LINKER_LANGUAGE CXX)
target_compile_definitions(ZFAd_AdMob PUBLIC ZFLIB_ZFAd_AdMob=ZF_ENV_EXPORT)
if(COMMAND zfprojConfigAfter_ZFAd_AdMob)
    zfprojConfigAfter_ZFAd_AdMob(ZFAd_AdMob)
endif()

target_include_directories(ZFAd_AdMob PRIVATE "${PROJECT_SOURCE_DIR}/../../../../zfsrc")

find_library(log-lib log)
find_library(android-lib android)
target_link_libraries(ZFAd_AdMob PRIVATE ${android-lib} ${log-lib})

function(ZFAddLib ZF_LIB_NAME_)
    target_include_directories(ZFAd_AdMob PRIVATE "${ZF_ROOT_PATH}/_release/Android/all/src/main/cpp/include")
    add_library(${ZF_LIB_NAME_} SHARED IMPORTED)
    set_target_properties(${ZF_LIB_NAME_} PROPERTIES IMPORTED_LOCATION "${ZF_ROOT_PATH}/_release/Android/all/src/main/jniLibs/${ANDROID_ABI}/lib${ZF_LIB_NAME_}.so")
    target_link_libraries(ZFAd_AdMob PRIVATE ${ZF_LIB_NAME_})
endfunction()

ZFAddLib(ZFCore)
ZFAddLib(ZFUtility)
ZFAddLib(ZFAlgorithm)
ZFAddLib(ZFUIKit)
ZFAddLib(ZF_impl)
ZFAddLib(ZFAd)

