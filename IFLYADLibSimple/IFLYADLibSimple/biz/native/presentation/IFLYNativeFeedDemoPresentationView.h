#import <UIKit/UIKit.h>
#import <IFLYADLib/IFLYNativeFeedAd.h>

#import "../demo/IFLYNativeFeedDemoImageLoader.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const IFLYNativeFeedDemoPresentationViewErrorDomain;

typedef NS_ENUM(NSInteger, IFLYNativeFeedDemoPresentationStyle) {
    IFLYNativeFeedDemoPresentationStyleSplash = 0,
    IFLYNativeFeedDemoPresentationStyleInterstitial,
};

typedef NS_ENUM(NSInteger, IFLYNativeFeedDemoInterstitialPresentationMode) {
    IFLYNativeFeedDemoInterstitialPresentationModeHalfScreen = 0,
    IFLYNativeFeedDemoInterstitialPresentationModeFullScreen,
};

typedef NS_ENUM(NSInteger, IFLYNativeFeedDemoInterstitialMaterialOrientation) {
    IFLYNativeFeedDemoInterstitialMaterialOrientationAutomatic = 0,
    IFLYNativeFeedDemoInterstitialMaterialOrientationPortrait,
    IFLYNativeFeedDemoInterstitialMaterialOrientationLandscape,
};

typedef void (^IFLYNativeFeedDemoPresentationReadyHandler)(BOOL ready, NSError *_Nullable error);

/// 媒体自建的开屏/插屏视觉容器。只消费 NativeFeed 公开字段并生成 Binder。
@interface IFLYNativeFeedDemoPresentationView : UIView

@property (nonatomic, assign, readonly) IFLYNativeFeedDemoPresentationStyle presentationStyle;
/// 插屏视觉形态；仅 presentationStyle == Interstitial 时生效，默认 HalfScreen。
@property (nonatomic, assign) IFLYNativeFeedDemoInterstitialPresentationMode interstitialPresentationMode;
/// 插屏素材方向；默认 Automatic，Demo Controller 会按所选竖版/横版插屏广告位显式赋值。
/// @note NativeFeed 公开数据不包含 rendering.screen_orientation，本属性只表达预置广告位配置。
@property (nonatomic, assign) IFLYNativeFeedDemoInterstitialMaterialOrientation interstitialMaterialOrientation;
@property (nonatomic, assign, readonly) IFLYNativeFeedAdMaterialType displayedMaterialType;
@property (nonatomic, assign, readonly) NSUInteger displayedImageCount;
@property (nonatomic, assign, readonly, getter=isContentReady) BOOL contentReady;
@property (nonatomic, assign, readonly, getter=isVideoCoverVisible) BOOL videoCoverVisible;
@property (nonatomic, assign, readonly, getter=isMuted) BOOL muted;
/// 媒体侧静音按钮事件；Demo Controller 用它实时更新 NativeFeed 的 muteOnStart。
@property (nonatomic, copy, nullable) void (^muteToggleHandler)(BOOL muted);
/// 媒体侧“免除广告”按钮事件；NativeFeed 没有对应 SDK 专用回调。
@property (nonatomic, copy, nullable) dispatch_block_t noAdsHandler;
@property (nonatomic, strong, readonly) UIView *mediaView;
@property (nonatomic, strong, readonly) UIView *videoView;
@property (nonatomic, strong, readonly) UIView *closeView;

- (instancetype)initWithFrame:(CGRect)frame
            presentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle;
- (instancetype)initWithFrame:(CGRect)frame
            presentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                  imageLoader:(id<IFLYNativeFeedDemoImageLoading>)imageLoader NS_DESIGNATED_INITIALIZER;

/// 准备媒体 UI。图片素材全部下载成功后才 ready；视频素材可先以封面/占位视图 ready。
- (BOOL)prepareWithAdData:(IFLYNativeFeedAdData *)adData
 headingInteractionEnabled:(BOOL)headingInteractionEnabled
                completion:(IFLYNativeFeedDemoPresentationReadyHandler)completion
                     error:(NSError *_Nullable *_Nullable)error;

- (nullable IFLYNativeFeedAdViewBinder *)makeViewBinder;
- (void)updateSplashCountdown:(NSUInteger)seconds;
- (void)syncMuted:(BOOL)muted;
- (void)showVideoCover;
- (void)hideVideoCover;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
