#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"-.jiaowu";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "DefaultAvatar" asset catalog image resource.
static NSString * const ACImageNameDefaultAvatar AC_SWIFT_PRIVATE = @"DefaultAvatar";

/// The "LoginLogo" asset catalog image resource.
static NSString * const ACImageNameLoginLogo AC_SWIFT_PRIVATE = @"LoginLogo";

#undef AC_SWIFT_PRIVATE
