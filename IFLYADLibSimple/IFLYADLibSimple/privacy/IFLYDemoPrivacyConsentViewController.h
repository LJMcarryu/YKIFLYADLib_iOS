#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^IFLYDemoPrivacyActionHandler)(void);
typedef BOOL (^IFLYDemoPrivacyURLOpener)(NSURL *URL);

/// Demo 首次启动隐私同意页面；不属于 SDK 对外 API。
@interface IFLYDemoPrivacyConsentViewController : UIViewController

+ (NSString *)consentTitle;
+ (NSString *)consentMessage;
+ (NSURL *)privacyPolicyURL;

- (instancetype)initWithAgreeHandler:(IFLYDemoPrivacyActionHandler)agreeHandler
                       declineHandler:(IFLYDemoPrivacyActionHandler)declineHandler
                            URLOpener:(nullable IFLYDemoPrivacyURLOpener)URLOpener NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                          bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
