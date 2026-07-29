#import <UIKit/UIKit.h>

#import "IFLYDemoPrivacyConsentStore.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^IFLYDemoConsentCompletedHandler)(void);
typedef void (^IFLYDemoTerminationHandler)(void);

/// 在隐私同意页与广告 Demo 首页之间装配根页面；不属于 SDK 对外 API。
@interface IFLYDemoRootCoordinator : NSObject

- (instancetype)initWithWindow:(UIWindow *)window
                          store:(IFLYDemoPrivacyConsentStore *)store
        consentCompletedHandler:(nullable IFLYDemoConsentCompletedHandler)consentCompletedHandler
             terminationHandler:(nullable IFLYDemoTerminationHandler)terminationHandler NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, assign, readonly, getter=hasAcceptedPrivacy) BOOL acceptedPrivacy;

- (void)start;

@end

NS_ASSUME_NONNULL_END
