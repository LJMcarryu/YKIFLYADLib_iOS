#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Demo 首次启动隐私同意状态；不属于 SDK 对外 API。
@interface IFLYDemoPrivacyConsentStore : NSObject

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign, readonly, getter=hasAccepted) BOOL accepted;

- (void)markAccepted;

@end

NS_ASSUME_NONNULL_END
