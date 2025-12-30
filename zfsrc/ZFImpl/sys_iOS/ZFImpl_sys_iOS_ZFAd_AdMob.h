#ifndef _ZFI_ZFImpl_sys_iOS_ZFAd_AdMob_h_
#define _ZFI_ZFImpl_sys_iOS_ZFAd_AdMob_h_

#include "../ZFImpl_ZFAd_AdMob.h"

#include "ZFImpl/sys_iOS/ZFImpl_sys_iOS_ZF_impl.h"

#if ZF_ENV_sys_iOS

#include <UIKit/UIKit.h>
#include "ZFCore.h"
#include "ZFImpl/sys_iOS/ZFMainEntry_sys_iOS.h"
#include "ZFImpl/sys_iOS/ZFImpl_sys_iOS_ZFUIKit_impl.h"

ZF_NAMESPACE_GLOBAL_BEGIN

/**
 * @brief update app id, assert fail if alreay set a different one
 *
 * callback's param0 is a #v_zfbool indicates whether success,
 * param1 is a #v_zfstring indicates error hint (or empty string if success)
 *
 * see: https://developers.google.com/admob/ios/quick-start
 */
extern ZFLIB_ZFAd_AdMob zfautoT<ZFTaskId> ZFImpl_sys_iOS_ZFAd_appIdUpdate(
        ZF_IN const zfstring &appId
        , ZF_IN_OPT const ZFListener &callback = zfnull
        );

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS
#endif // #ifndef _ZFI_ZFImpl_sys_iOS_ZFAd_AdMob_h_

