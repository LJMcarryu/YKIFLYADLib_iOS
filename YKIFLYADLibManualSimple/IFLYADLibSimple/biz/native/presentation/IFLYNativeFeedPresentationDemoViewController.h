// 使用 IFLYNativeFeedAd + Binder 演示媒体自渲染的开屏/插屏视觉形态。
// 它不改变 IFLYSplashAd / IFLYInterstitialAd 的 SDK 内置渲染和公开数据边界。

#import <UIKit/UIKit.h>

#import "IFLYNativeFeedDemoPresentationView.h"

@class IFLYNativeFeedAd;

NS_ASSUME_NONNULL_BEGIN

typedef IFLYNativeFeedAd *_Nonnull (^IFLYNativeFeedPresentationDemoAdFactory)(NSString *adUnitId);

@interface IFLYNativeFeedPresentationDemoViewController : UIViewController

@property (nonatomic, assign, readonly) IFLYNativeFeedDemoPresentationStyle presentationStyle;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle;
- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                                adFactory:(IFLYNativeFeedPresentationDemoAdFactory)adFactory;

@end

NS_ASSUME_NONNULL_END
