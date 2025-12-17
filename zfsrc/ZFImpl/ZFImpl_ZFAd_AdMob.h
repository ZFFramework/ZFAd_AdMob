/**
 * @file ZFImpl_ZFAd_AdMob.h
 * @brief global header for ZFAd_AdMob module
 */

#ifndef _ZFI_ZFImpl_ZFAd_AdMob_h_
#define _ZFI_ZFImpl_ZFAd_AdMob_h_

#include "ZFImpl/ZFImpl_ZF_impl.h"

ZF_NAMESPACE_GLOBAL_BEGIN

/** @brief used to export symbols */
#ifndef ZFLIB_ZFAd_AdMob
    #define ZFLIB_ZFAd_AdMob ZF_ENV_IMPORT
#endif
// export a dummy class to ensure the lib really "contains" something
zfclassNotPOD ZFLIB_ZFAd_AdMob _ZFP_ZFLIB_ZFAd_AdMob {};

ZF_NAMESPACE_GLOBAL_END
#endif // #ifndef _ZFI_ZFImpl_ZFAd_AdMob_h_

