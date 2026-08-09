//  基于 NativeFeed 公开数据演示媒体自建的开屏/插屏视觉容器。
//  该页面不复用 IFLYSplashAd / IFLYInterstitialAd 的内置渲染或生命周期语义。

#import "IFLYNativeFeedPresentationDemoViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

typedef void (^IFLYNativeFeedPresentationHostDidAppearHandler)(UIViewController *host);
static NSTimeInterval const IFLYNativeFeedPresentationAppearTimeout = 1.0;

@interface IFLYNativeFeedPresentationHostViewController : UIViewController
@property (nonatomic, assign) IFLYNativeFeedDemoPresentationStyle presentationStyle;
@property (nonatomic, assign) IFLYNativeFeedDemoInterstitialPresentationMode interstitialPresentationMode;
@property (nonatomic, strong) IFLYNativeFeedDemoPresentationView *contentView;
@property (nonatomic, copy) IFLYNativeFeedPresentationHostDidAppearHandler didAppearHandler;
@property (nonatomic, copy) dispatch_block_t didDisappearHandler;
@property (nonatomic, assign) BOOL didNotifyAppearance;
@property (nonatomic, assign) BOOL didNotifyDisappearance;
- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                              contentView:(IFLYNativeFeedDemoPresentationView *)contentView;
@end

@implementation IFLYNativeFeedPresentationHostViewController

- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                              contentView:(IFLYNativeFeedDemoPresentationView *)contentView {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _presentationStyle = presentationStyle;
        _contentView = contentView;
        _interstitialPresentationMode = contentView.interstitialPresentationMode;
        BOOL fullScreenInterstitial =
            presentationStyle == IFLYNativeFeedDemoPresentationStyleInterstitial &&
            _interstitialPresentationMode ==
                IFLYNativeFeedDemoInterstitialPresentationModeFullScreen;
        self.modalPresentationStyle =
            presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash ||
                    fullScreenInterstitial
                ? UIModalPresentationFullScreen
                : UIModalPresentationOverFullScreen;
        if (presentationStyle == IFLYNativeFeedDemoPresentationStyleInterstitial) {
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 与 SDK 模版宿主保持一致：开屏为白底；插屏遮罩由内容 View 自己提供，
    // 避免 Host 与内容分别叠加一层黑色导致实际透明度偏深。
    self.view.backgroundColor =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash
            ? UIColor.whiteColor
            : UIColor.clearColor;
    self.contentView.accessibilityIdentifier = @"nativeFeed.presentation.content";
    [self.view addSubview:self.contentView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Host 只负责全屏呈现与遮罩；卡片尺寸、横竖屏和 iPad 适配由内容 View
    // 在完整可用区域内统一计算，避免两层居中约束导致横屏卡片被重复压缩。
    self.contentView.frame = self.view.bounds;
}

- (BOOL)prefersStatusBarHidden {
    return self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.didNotifyAppearance) {
        return;
    }
    self.didNotifyAppearance = YES;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    if (self.didAppearHandler) {
        self.didAppearHandler(self);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.didNotifyDisappearance ||
        !(self.isBeingDismissed || self.presentingViewController == nil)) {
        return;
    }
    self.didNotifyDisappearance = YES;
    if (self.didDisappearHandler) {
        self.didDisappearHandler();
    }
}

@end

@interface IFLYNativeFeedPresentationDemoViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, assign, readwrite) IFLYNativeFeedDemoPresentationStyle presentationStyle;
@property (nonatomic, copy) IFLYNativeFeedPresentationDemoAdFactory adFactory;
@property (nonatomic, strong) IFLYNativeFeedAd *nativeFeedAd;
@property (nonatomic, strong) IFLYNativeFeedDemoPresentationView *presentationView;
@property (nonatomic, strong) IFLYNativeFeedPresentationHostViewController *presentationHost;
@property (nonatomic, weak) UIView *attachedContainerView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UISegmentedControl *interstitialOrientationControl;
@property (nonatomic, strong) UISegmentedControl *interstitialModeControl;
@property (nonatomic, assign) IFLYNativeFeedDemoInterstitialMaterialOrientation requestedInterstitialOrientation;
@property (nonatomic, assign) IFLYNativeFeedAdMaterialType requestedMaterialType;
@property (nonatomic, strong) NSTimer *splashTimer;
@property (nonatomic, assign) NSUInteger splashCountdown;
@property (nonatomic, assign) NSUInteger lifecycleGeneration;
@property (nonatomic, assign) BOOL preparingContent;
@property (nonatomic, assign) BOOL attemptedBind;
@property (nonatomic, assign) BOOL bound;
@property (nonatomic, assign) BOOL cleaningUp;
@property (nonatomic, assign) BOOL splashCountdownPausedForInteraction;
@property (nonatomic, assign) BOOL splashCountdownWaitingForApplicationReturn;
@end

@implementation IFLYNativeFeedPresentationDemoViewController

- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle {
    return [self initWithPresentationStyle:presentationStyle
                                 adFactory:^IFLYNativeFeedAd *(NSString *adUnitId) {
                                     return [[IFLYNativeFeedAd alloc] initWithAdUnitId:adUnitId];
                                 }];
}

- (instancetype)initWithPresentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                                adFactory:(IFLYNativeFeedPresentationDemoAdFactory)adFactory {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _presentationStyle = presentationStyle;
        _adFactory = [adFactory copy];
        if (!_adFactory) {
            _adFactory = ^IFLYNativeFeedAd *(NSString *adUnitId) {
                return [[IFLYNativeFeedAd alloc] initWithAdUnitId:adUnitId];
            };
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash
            ? @"自渲染开屏视觉示例"
            : @"自渲染插屏视觉示例";
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationDidBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
    NSString *formatName =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash ? @"开屏" : @"插屏";
    [self updateStatus:[NSString stringWithFormat:@"请选择%@图片或视频广告位", formatName]
                 color:UIColor.systemBlueColor];
    [self log:[NSString stringWithFormat:
                            @"页面初始化完成：使用%@广告位，通过 NativeFeed 公开数据完成媒体自渲染",
                            formatName]];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.splashTimer invalidate];
    IFLYNativeFeedAd *ad = self.nativeFeedAd;
    if (ad) {
        UIView *containerView = self.attachedContainerView;
        if (containerView) {
            [IFLYNativeFeedAd detachAdFromContainerView:containerView];
        }
        ad.delegate = nil;
        ad.currentViewController = nil;
        // 一次性视觉 Demo 离开页面时主动提前终止；媒体正常释放最后一个强引用即可。
        [ad destroy];
    }
}

#pragma mark - UI

- (void)setupUI {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat margin = 20.0;
    CGFloat contentWidth = width - margin * 2.0;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    CGFloat y = 110.0;
    NSString *styleText =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash
            ? @"复刻 SDK 模版开屏样式"
            : @"复刻 SDK 模版插屏样式";
    UILabel *description = [IFLYADUtil
        createSectionTitleWithText:
            [NSString stringWithFormat:
                          @"%@：使用 IFLYNativeFeedAd 公开数据，由媒体自建 UI；不是 SDK 内置广告格式。",
                          styleText]
                           frame:CGRectMake(margin, y, contentWidth, 42.0)];
    description.numberOfLines = 0;
    description.textColor = UIColor.systemOrangeColor;
    [scrollView addSubview:description];
    y += 58.0;

    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleInterstitial) {
        UILabel *orientationTitle =
            [IFLYADUtil createSectionTitleWithText:@"插屏素材方向"
                                            frame:CGRectMake(margin, y, contentWidth, 18.0)];
        [scrollView addSubview:orientationTitle];
        y += 24.0;

        self.interstitialOrientationControl =
            [[UISegmentedControl alloc] initWithItems:@[ @"竖版", @"横版" ]];
        self.interstitialOrientationControl.frame =
            CGRectMake(margin, y, contentWidth, 32.0);
        self.interstitialOrientationControl.selectedSegmentIndex = 0;
        self.interstitialOrientationControl.accessibilityIdentifier =
            @"nativeFeed.presentation.interstitialOrientation";
        [scrollView addSubview:self.interstitialOrientationControl];
        y += 48.0;

        UILabel *modeTitle =
            [IFLYADUtil createSectionTitleWithText:@"插屏展示形态"
                                            frame:CGRectMake(margin, y, contentWidth, 18.0)];
        [scrollView addSubview:modeTitle];
        y += 24.0;

        self.interstitialModeControl =
            [[UISegmentedControl alloc] initWithItems:@[ @"半屏", @"全屏" ]];
        self.interstitialModeControl.frame =
            CGRectMake(margin, y, contentWidth, 32.0);
        self.interstitialModeControl.selectedSegmentIndex = 0;
        self.interstitialModeControl.accessibilityIdentifier =
            @"nativeFeed.presentation.interstitialMode";
        [scrollView addSubview:self.interstitialModeControl];
        y += 48.0;
    }

    NSString *formatName =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash ? @"开屏" : @"插屏";
    NSArray<NSDictionary<NSString *, NSString *> *> *buttons = @[
        @{
            @"title" : [NSString stringWithFormat:@"加载图片%@广告位", formatName],
            @"identifier" : @"nativeFeed.presentation.loadSingle",
            @"selector" : NSStringFromSelector(@selector(loadSingleImageAd)),
        },
        @{
            @"title" : [NSString stringWithFormat:@"加载视频%@广告位", formatName],
            @"identifier" : @"nativeFeed.presentation.loadVideo",
            @"selector" : NSStringFromSelector(@selector(loadVideoAd)),
        },
    ];
    for (NSDictionary<NSString *, NSString *> *configuration in buttons) {
        UIButton *button =
            [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin, y, contentWidth, 48.0)
                                              title:configuration[@"title"]
                                             target:self
                                             action:NSSelectorFromString(configuration[@"selector"])];
        button.accessibilityIdentifier = configuration[@"identifier"];
        [scrollView addSubview:button];
        y += 60.0;
    }

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, contentWidth, 42.0)];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    self.statusLabel.accessibilityIdentifier = @"nativeFeed.presentation.status";
    [scrollView addSubview:self.statusLabel];
    y += 54.0;

    UILabel *flow = [IFLYADUtil
        createSectionTitleWithText:
            @"流程：Load → didLoad → 媒体准备 UI → present → 入窗布局 → Binder 绑定"
                           frame:CGRectMake(margin, y, contentWidth, 40.0)];
    flow.numberOfLines = 0;
    [scrollView addSubview:flow];
    y += 50.0;

    UILabel *logTitle =
        [IFLYADUtil createSectionTitleWithText:@"状态与回调日志"
                                        frame:CGRectMake(margin, y, contentWidth, 20.0)];
    [scrollView addSubview:logTitle];
    y += 26.0;
    self.logView =
        [IFLYADUtil createLogTextViewWithFrame:CGRectMake(margin, y, contentWidth, 240.0)];
    self.logView.accessibilityIdentifier = @"nativeFeed.presentation.log";
    [scrollView addSubview:self.logView];
    scrollView.contentSize = CGSizeMake(width, y + 260.0);
}

#pragma mark - Load

- (void)loadSingleImageAd {
    NSString *unitId = nil;
    NSString *materialName = nil;
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash) {
        unitId = __SPLASH_NATIVE_AD_UNIT_ID__;
        materialName = @"图片开屏";
    } else {
        BOOL landscape = self.interstitialOrientationControl.selectedSegmentIndex == 1;
        self.requestedInterstitialOrientation =
            landscape
                ? IFLYNativeFeedDemoInterstitialMaterialOrientationLandscape
                : IFLYNativeFeedDemoInterstitialMaterialOrientationPortrait;
        unitId = landscape ? __INTERSTITIAL_LANDSCAPE_IMAGE_AD_UNIT_ID__
                           : __INTERSTITIAL_AD_UNIT_ID__;
        materialName = landscape ? @"横版图片插屏" : @"竖版图片插屏";
    }
    [self loadAdWithUnitId:unitId
              materialName:materialName
      expectedMaterialType:IFLYNativeFeedAdMaterialTypeSingleImage];
}

- (void)loadVideoAd {
    NSString *unitId = nil;
    NSString *materialName = nil;
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash) {
        unitId = __SPLASH_VIDEO_AD_UNIT_ID__;
        materialName = @"视频开屏";
    } else {
        BOOL landscape = self.interstitialOrientationControl.selectedSegmentIndex == 1;
        self.requestedInterstitialOrientation =
            landscape
                ? IFLYNativeFeedDemoInterstitialMaterialOrientationLandscape
                : IFLYNativeFeedDemoInterstitialMaterialOrientationPortrait;
        unitId = landscape ? __INTERSTITIAL_LANDSCAPE_VIDEO_AD_UNIT_ID__
                           : __INTERSTITIAL_PORTRAIT_VIDEO_AD_UNIT_ID__;
        materialName = landscape ? @"横版视频插屏" : @"竖版视频插屏";
    }
    [self loadAdWithUnitId:unitId
              materialName:materialName
      expectedMaterialType:IFLYNativeFeedAdMaterialTypeVideo];
}

- (void)loadAdWithUnitId:(NSString *)unitId
            materialName:(NSString *)materialName
    expectedMaterialType:(IFLYNativeFeedAdMaterialType)expectedMaterialType {
    if (self.cleaningUp || self.presentationHost) {
        [self log:@"Load ignored：当前展示或关闭流程尚未结束"];
        return;
    }
    if (unitId.length == 0) {
        [self updateStatus:@"广告位为空，无法请求" color:UIColor.systemRedColor];
        [self log:[NSString stringWithFormat:@"%@ NativeFeed 广告位为空", materialName]];
        return;
    }

    self.lifecycleGeneration += 1;
    [self dismissPresentedHostImmediately];
    [self cleanupCurrentAdResetPresentation:YES];
    self.requestedMaterialType = expectedMaterialType;

    IFLYNativeFeedAd *ad = self.adFactory(unitId);
    if (!ad) {
        [self updateStatus:@"广告实例创建失败" color:UIColor.systemRedColor];
        [self log:@"广告工厂返回 nil"];
        return;
    }
    ad.delegate = self;
    ad.headingInteractionEnabled = NO;
    ad.muteOnStart = YES;
    self.nativeFeedAd = ad;
    [self updateStatus:[NSString stringWithFormat:@"正在加载 %@ NativeFeed ...", materialName]
                 color:UIColor.systemBlueColor];
    [self log:[NSString stringWithFormat:@">>> Load %@ NativeFeed，adUnitId=%@",
                                         materialName,
                                         unitId]];
    IFLYAdRequestConfig *requestConfig = [IFLYADUtil mediaSampleRequestConfig];
    [ad loadAdWithRequestConfig:requestConfig];
}

- (void)handleLoadedAd:(IFLYNativeFeedAd *)ad {
    if (![self isCurrentAd:ad] || self.preparingContent || self.presentationHost ||
        self.attemptedBind) {
        [self log:@"忽略旧实例或重复 didLoad"];
        return;
    }
    if (self.requestedMaterialType == IFLYNativeFeedAdMaterialTypeUnknown ||
        ad.materialType != self.requestedMaterialType) {
        NSString *message =
            [NSString stringWithFormat:
                          @"广告位素材类型不匹配：期望 %@，实际 materialType=%ld；"
                           "自渲染开屏/插屏仅支持单图和视频",
                          self.requestedMaterialType ==
                                  IFLYNativeFeedAdMaterialTypeVideo
                              ? @"视频"
                              : @"单图",
                          (long)ad.materialType];
        [self failCurrentAdWithMessage:message];
        return;
    }

    self.preparingContent = YES;
    NSUInteger generation = self.lifecycleGeneration;
    IFLYNativeFeedDemoPresentationView *presentationView =
        [[IFLYNativeFeedDemoPresentationView alloc]
            initWithFrame:CGRectZero
        presentationStyle:self.presentationStyle];
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleInterstitial) {
        presentationView.interstitialPresentationMode =
            self.interstitialModeControl.selectedSegmentIndex == 1
                ? IFLYNativeFeedDemoInterstitialPresentationModeFullScreen
                : IFLYNativeFeedDemoInterstitialPresentationModeHalfScreen;
        presentationView.interstitialMaterialOrientation =
            self.requestedInterstitialOrientation;
    }
    __weak typeof(self) weakSelfForControls = self;
    __weak IFLYNativeFeedAd *weakAdForControls = ad;
    presentationView.muteToggleHandler = ^(BOOL muted) {
        __strong typeof(weakSelfForControls) self = weakSelfForControls;
        IFLYNativeFeedAd *strongAd = weakAdForControls;
        if (!self || !strongAd || strongAd != self.nativeFeedAd) {
            return;
        }
        strongAd.muteOnStart = muted;
        [self log:[NSString stringWithFormat:@"媒体模版静音按钮：%@",
                                             muted ? @"静音" : @"有声"]];
    };
    presentationView.noAdsHandler = ^{
        __strong typeof(weakSelfForControls) self = weakSelfForControls;
        IFLYNativeFeedAd *strongAd = weakAdForControls;
        if (!self || !strongAd || strongAd != self.nativeFeedAd) {
            return;
        }
        [self log:@"媒体模版“免除广告”按钮点击（NativeFeed 无对应 SDK 专用回调）"];
    };
    presentationView.accessibilityIdentifier = @"nativeFeed.presentation.content";
    self.presentationView = presentationView;
    [self updateStatus:@"加载成功，媒体正在准备自渲染 UI ..."
                 color:[IFLYADUtil demoIndigoColor]];
    [self log:[NSString
                  stringWithFormat:
                      @"didLoad：creativeId=%@ appName=%@ templateId=%ld materialType=%ld price=%@ dealId=%@",
                      ad.adData.creativeId ?: @"无",
                      ad.adData.appName ?: @"无",
                      (long)ad.adData.templateId,
                      (long)ad.adData.materialType,
                      ad.bidInfo.price ?: @"无",
                      ad.bidInfo.dealId ?: @"无"]];

    __weak typeof(self) weakSelf = self;
    __weak IFLYNativeFeedAd *weakAd = ad;
    __weak IFLYNativeFeedDemoPresentationView *weakPresentationView = presentationView;
    NSError *prepareError = nil;
    BOOL accepted =
        [presentationView prepareWithAdData:ad.adData
                 headingInteractionEnabled:ad.headingInteractionEnabled
                                completion:^(BOOL ready, NSError *error) {
                                    void (^finish)(void) = ^{
                                        __strong typeof(weakSelf) self = weakSelf;
                                        IFLYNativeFeedAd *strongAd = weakAd;
                                        IFLYNativeFeedDemoPresentationView *strongView =
                                            weakPresentationView;
                                        if (!self || !strongAd || !strongView) {
                                            return;
                                        }
                                        [self handlePresentationReady:ready
                                                                error:error
                                                                   ad:strongAd
                                                                 view:strongView
                                                           generation:generation];
                                    };
                                    if (NSThread.isMainThread) {
                                        finish();
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), finish);
                                    }
                                }
                                     error:&prepareError];
    if (!accepted && [self isCurrentGeneration:generation ad:ad view:presentationView]) {
        self.preparingContent = NO;
        [self failCurrentAdWithMessage:
                  [NSString stringWithFormat:@"媒体渲染准备失败：%@",
                                             prepareError.localizedDescription ?: @"未知错误"]];
    }
}

- (void)handlePresentationReady:(BOOL)ready
                          error:(NSError *)error
                             ad:(IFLYNativeFeedAd *)ad
                           view:(IFLYNativeFeedDemoPresentationView *)presentationView
                     generation:(NSUInteger)generation {
    if (![self isCurrentGeneration:generation ad:ad view:presentationView]) {
        [presentationView reset];
        return;
    }
    self.preparingContent = NO;
    if (!ready) {
        [self failCurrentAdWithMessage:
                  [NSString stringWithFormat:@"媒体素材准备失败：%@",
                                             error.localizedDescription ?: @"未知错误"]];
        return;
    }

    if (!self.viewIfLoaded.window || self.presentedViewController ||
        self.isBeingDismissed || self.isMovingFromParentViewController) {
        [self failCurrentAdWithMessage:@"当前页面不具备 modal 呈现条件，已清理本次广告"];
        return;
    }

    [self updateStatus:@"媒体 UI 已就绪，准备 present ..."
                 color:[IFLYADUtil demoIndigoColor]];
    [self log:@"媒体 UI ready，创建媒体自有 modal host"];
    IFLYNativeFeedPresentationHostViewController *host =
        [[IFLYNativeFeedPresentationHostViewController alloc]
            initWithPresentationStyle:self.presentationStyle
                          contentView:presentationView];
    self.presentationHost = host;
    __weak typeof(self) weakSelf = self;
    __weak IFLYNativeFeedAd *weakAd = ad;
    __weak IFLYNativeFeedPresentationHostViewController *weakHost = host;
    host.didAppearHandler = ^(UIViewController *appearedHost) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        [self bindAd:weakAd
              inHost:weakHost
                view:presentationView
          generation:generation];
    };
    host.didDisappearHandler = ^{
        __strong typeof(weakSelf) self = weakSelf;
        IFLYNativeFeedAd *strongAd = weakAd;
        IFLYNativeFeedPresentationHostViewController *strongHost = weakHost;
        if (!self || !strongAd || !strongHost ||
            ![self isCurrentGeneration:generation ad:strongAd view:presentationView] ||
            strongHost != self.presentationHost) {
            return;
        }
        [self cleanupAfterUnexpectedHostDisappearance:
                  @"展示容器意外关闭，已清理本次广告"];
    };
    [self presentViewController:host animated:NO completion:nil];
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(IFLYNativeFeedPresentationAppearTimeout * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            IFLYNativeFeedAd *strongAd = weakAd;
            IFLYNativeFeedPresentationHostViewController *strongHost = weakHost;
            if (!self || !strongAd || !strongHost || self.attemptedBind ||
                ![self isCurrentGeneration:generation ad:strongAd view:presentationView] ||
                strongHost != self.presentationHost) {
                return;
            }
            [self failCurrentAdWithMessage:@"modal host 未在限定时间内入窗，已清理本次广告"];
        });
}

- (void)bindAd:(IFLYNativeFeedAd *)ad
        inHost:(IFLYNativeFeedPresentationHostViewController *)host
          view:(IFLYNativeFeedDemoPresentationView *)presentationView
    generation:(NSUInteger)generation {
    if (![self isCurrentGeneration:generation ad:ad view:presentationView] ||
        host != self.presentationHost || self.attemptedBind) {
        return;
    }
    if (!host.view.window) {
        [self failCurrentAdWithMessage:@"展示容器尚未入窗，取消绑定"];
        return;
    }

    self.attemptedBind = YES;
    ad.currentViewController = host;
    IFLYNativeFeedAdViewBinder *binder = [presentationView makeViewBinder];
    IFLYAdError *bindError = nil;
    BOOL didBind = binder && [ad attachWithViewBinder:binder error:&bindError];
    if (![self isCurrentGeneration:generation ad:ad view:presentationView]) {
        if (didBind && binder.containerView) {
            [IFLYNativeFeedAd detachAdFromContainerView:binder.containerView];
        }
        return;
    }
    if (!didBind) {
        [self failCurrentAdWithMessage:
                  [NSString stringWithFormat:@"Binder 绑定失败：%@",
                                             bindError.errorDescription ?: @"未知错误"]];
        return;
    }

    self.bound = YES;
    self.attachedContainerView = binder.containerView;
    [self updateStatus:@"已入窗并绑定，等待曝光/点击回调" color:UIColor.systemGreenColor];
    [self log:[NSString stringWithFormat:
                   @"host 入窗并完成布局：设置 currentViewController 后 Ad 级托管挂载成功，templateId=%ld materialType=%ld",
                   (long)ad.adData.templateId,
                   (long)ad.adData.materialType]];
    if (ad.hasVideoTemplate) {
        [ad startPlay];
    }
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash) {
        [self startSplashCountdown];
    }
}

#pragma mark - Close and cleanup

- (void)startSplashCountdown {
    [self.splashTimer invalidate];
    self.splashTimer = nil;
    self.splashCountdown = 5;
    self.splashCountdownPausedForInteraction = NO;
    self.splashCountdownWaitingForApplicationReturn = NO;
    [self.presentationView updateSplashCountdown:self.splashCountdown];
    [self scheduleSplashCountdownIfNeeded];
    [self log:@"开屏媒体倒计时开始：5 秒后主动关闭"];
}

- (void)scheduleSplashCountdownIfNeeded {
    if (self.presentationStyle != IFLYNativeFeedDemoPresentationStyleSplash ||
        self.splashTimer || self.splashCountdown == 0 || !self.nativeFeedAd ||
        !self.bound || self.cleaningUp || self.splashCountdownPausedForInteraction) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                           repeats:YES
                                             block:^(NSTimer *timer) {
                                                 [weakSelf handleSplashCountdownTick];
                                             }];
    self.splashTimer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)pauseSplashCountdownForInteraction {
    if (self.presentationStyle != IFLYNativeFeedDemoPresentationStyleSplash ||
        self.splashCountdown == 0) {
        return;
    }
    self.splashCountdownPausedForInteraction = YES;
    [self.splashTimer invalidate];
    self.splashTimer = nil;
}

- (void)resumeSplashCountdownAfterInteraction {
    if (self.presentationStyle != IFLYNativeFeedDemoPresentationStyleSplash) {
        return;
    }
    self.splashCountdownPausedForInteraction = NO;
    self.splashCountdownWaitingForApplicationReturn = NO;
    [self scheduleSplashCountdownIfNeeded];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    (void)notification;
    if (!self.splashCountdownWaitingForApplicationReturn) {
        return;
    }
    [self resumeSplashCountdownAfterInteraction];
}

- (void)handleSplashCountdownTick {
    if (self.presentationStyle != IFLYNativeFeedDemoPresentationStyleSplash ||
        !self.nativeFeedAd || self.cleaningUp) {
        return;
    }
    if (self.splashCountdown > 0) {
        self.splashCountdown -= 1;
    }
    [self.presentationView updateSplashCountdown:self.splashCountdown];
    if (self.splashCountdown == 0) {
        [self log:@"开屏媒体倒计时结束：主动 dismiss，不伪造 SDK close 回调"];
        [self closeCurrentPresentationWithStatus:@"开屏视觉示例已由媒体倒计时关闭"
                                           color:[IFLYADUtil demoTealColor]];
    }
}

- (void)advanceSplashCountdownForTesting {
    if (self.splashTimer) {
        [self handleSplashCountdownTick];
    }
}

- (NSUInteger)splashCountdownForTesting {
    return self.splashCountdown;
}

- (BOOL)isSplashCountdownScheduledForTesting {
    return self.splashTimer != nil;
}

- (void)closeCurrentPresentationWithStatus:(NSString *)status color:(UIColor *)color {
    if (self.cleaningUp || !self.nativeFeedAd) {
        return;
    }
    self.cleaningUp = YES;
    [self.splashTimer invalidate];
    self.splashTimer = nil;
    self.lifecycleGeneration += 1;
    IFLYNativeFeedAd *ad = self.nativeFeedAd;
    IFLYNativeFeedPresentationHostViewController *host = self.presentationHost;
    UIView *attachedContainerView = self.attachedContainerView;
    __weak typeof(self) weakSelf = self;
    __weak IFLYNativeFeedPresentationHostViewController *weakHost = host;
    __block BOOL didFinish = NO;
    void (^finishOnce)(void) = ^{
        if (didFinish) {
            return;
        }
        didFinish = YES;
        __strong typeof(weakSelf) self = weakSelf;
        weakHost.didDisappearHandler = nil;
        if (!self) {
            if (attachedContainerView) {
                [IFLYNativeFeedAd detachAdFromContainerView:attachedContainerView];
            }
            ad.delegate = nil;
            ad.currentViewController = nil;
            // 一次性视觉 Demo 已无宿主，主动提前终止残留广告。
            [ad destroy];
            return;
        }
        [self cleanupAd:ad resetPresentation:YES];
        self.presentationHost = nil;
        self.cleaningUp = NO;
        [self updateStatus:status color:color];
    };
    host.didDisappearHandler = finishOnce;
    UIViewController *presenter = host.presentingViewController;
    if (presenter) {
        [presenter dismissViewControllerAnimated:NO completion:finishOnce];
        dispatch_async(dispatch_get_main_queue(), ^{
            IFLYNativeFeedPresentationHostViewController *strongHost = weakHost;
            if (!strongHost || (!strongHost.presentingViewController && !strongHost.view.window)) {
                finishOnce();
            }
        });
    } else {
        finishOnce();
    }
}

- (void)failCurrentAdWithMessage:(NSString *)message {
    if (self.cleaningUp || !self.nativeFeedAd) {
        return;
    }
    [self log:message];
    [self updateStatus:message color:UIColor.systemRedColor];
    if (self.presentationHost) {
        [self closeCurrentPresentationWithStatus:message color:UIColor.systemRedColor];
    } else {
        self.lifecycleGeneration += 1;
        [self cleanupCurrentAdResetPresentation:YES];
        [self updateStatus:message color:UIColor.systemRedColor];
    }
}

- (void)cleanupAfterUnexpectedHostDisappearance:(NSString *)message {
    if (self.cleaningUp || !self.nativeFeedAd) {
        return;
    }
    self.cleaningUp = YES;
    self.lifecycleGeneration += 1;
    [self log:@"modal host 意外离窗：直接解绑并销毁，不重复触发 dismiss"];
    self.presentationHost.didAppearHandler = nil;
    self.presentationHost.didDisappearHandler = nil;
    self.presentationHost = nil;
    [self cleanupCurrentAdResetPresentation:YES];
    self.cleaningUp = NO;
    [self updateStatus:message color:UIColor.systemRedColor];
}

- (void)dismissPresentedHostImmediately {
    IFLYNativeFeedPresentationHostViewController *host = self.presentationHost;
    self.presentationHost = nil;
    host.didAppearHandler = nil;
    host.didDisappearHandler = nil;
    if (host.presentingViewController) {
        [host dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)cleanupCurrentAdResetPresentation:(BOOL)resetPresentation {
    [self.splashTimer invalidate];
    self.splashTimer = nil;
    [self cleanupAd:self.nativeFeedAd resetPresentation:resetPresentation];
}

- (void)cleanupAd:(IFLYNativeFeedAd *)ad resetPresentation:(BOOL)resetPresentation {
    if (ad) {
        if (ad == self.nativeFeedAd) {
            UIView *containerView = self.attachedContainerView;
            if (containerView) {
                [IFLYNativeFeedAd detachAdFromContainerView:containerView];
            }
            self.attachedContainerView = nil;
        }
        ad.delegate = nil;
        ad.currentViewController = nil;
        // 该视觉 Demo 需要立即终止一次性展示；正常列表释放最后一个 Ad 引用即可。
        [ad destroy];
        if (ad == self.nativeFeedAd) {
            self.nativeFeedAd = nil;
        }
    }
    if (resetPresentation) {
        [self.presentationView reset];
        self.presentationView = nil;
    }
    self.preparingContent = NO;
    self.attemptedBind = NO;
    self.bound = NO;
    self.splashCountdown = 0;
    self.splashCountdownPausedForInteraction = NO;
    self.splashCountdownWaitingForApplicationReturn = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed ||
        self.navigationController.isBeingDismissed) {
        self.lifecycleGeneration += 1;
        [self.splashTimer invalidate];
        [self dismissPresentedHostImmediately];
        [self cleanupCurrentAdResetPresentation:YES];
    }
}

#pragma mark - IFLYNativeFeedAdDelegate

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    [self handleLoadedAd:ad];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error {
    if (![self isCurrentAd:ad]) {
        return;
    }
    [self failCurrentAdWithMessage:
              [NSString stringWithFormat:@"请求失败 (%d)：%@",
                                         error.errorCode,
                                         error.errorDescription ?: @"未知错误"]];
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self log:@"nativeFeedAdDidRender：SDK 已完成 Binder 渲染"];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad
    didFailToRenderWithError:(IFLYAdError *)error {
    if (![self isCurrentAd:ad]) {
        return;
    }
    [self failCurrentAdWithMessage:
              [NSString stringWithFormat:@"渲染失败 (%d)：%@",
                                         error.errorCode,
                                         error.errorDescription ?: @"未知错误"]];
}

- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self updateStatus:@"已曝光，SDK 已完成曝光监测" color:UIColor.systemGreenColor];
        [self log:@"nativeFeedAdDidExpose"];
    }
}

- (void)nativeFeedAdDidClick:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self pauseSplashCountdownForInteraction];
        [self updateStatus:@"广告已点击，展示保持到明确关闭" color:UIColor.systemOrangeColor];
        [self log:@"nativeFeedAdDidClick：开屏倒计时暂停，避免误关落地页"];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didJumpWithSuccess:(BOOL)success {
    if ([self isCurrentAd:ad]) {
        if (!success) {
            [self resumeSplashCountdownAfterInteraction];
        }
        [self log:[NSString stringWithFormat:@"didJumpWithSuccess=%@",
                                             success ? @"YES" : @"NO"]];
    }
}

- (void)nativeFeedAdWillDismissLandingPage:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self log:@"落地页即将关闭；保留广告展示实例"];
    }
}

- (void)nativeFeedAdDidDismissLandingPage:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self resumeSplashCountdownAfterInteraction];
        [self updateStatus:@"落地页已回流，广告展示保持"
                     color:[IFLYADUtil demoTealColor]];
        [self log:@"落地页回流：不清理 NativeFeed 展示，恢复剩余倒计时"];
    }
}

- (void)nativeFeedAdDidDismissStore:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self resumeSplashCountdownAfterInteraction];
        [self log:@"App Store 页面已关闭；保留广告展示实例并恢复剩余倒计时"];
    }
}

- (void)nativeFeedAdDidLeaveApplication:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self pauseSplashCountdownForInteraction];
        self.splashCountdownWaitingForApplicationReturn =
            self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
        [self log:@"广告跳转离开应用；回到前台后恢复剩余倒计时"];
    }
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    if (![self isCurrentAd:ad]) {
        return;
    }
    [self log:@"nativeFeedAdDidClose：先 dismiss，再按容器 detach 并释放 Demo 持有的 Ad"];
    [self closeCurrentPresentationWithStatus:@"广告已通过 SDK 关闭回调清理"
                                       color:[IFLYADUtil demoTealColor]];
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self.presentationView hideVideoCover];
        [self updateStatus:@"视频播放中" color:UIColor.systemGreenColor];
        [self log:@"nativeFeedAdDidStartPlay：隐藏封面"];
    }
}

- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self updateStatus:@"视频已暂停" color:UIColor.systemOrangeColor];
        [self log:@"nativeFeedAdDidPausePlay：保留播放器当前帧，与模版一致"];
    }
}

- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad {
    if ([self isCurrentAd:ad]) {
        [self.presentationView hideVideoCover];
        [self updateStatus:@"视频继续播放" color:UIColor.systemGreenColor];
        [self log:@"nativeFeedAdDidResumePlay：隐藏封面"];
    }
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    if (![self isCurrentAd:ad]) {
        return;
    }
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash) {
        [self log:@"nativeFeedAdDidPlayFinish：按模版开屏语义关闭"];
        [self closeCurrentPresentationWithStatus:@"开屏视频播放完成，已按模版样式关闭"
                                           color:[IFLYADUtil demoTealColor]];
    } else {
        [self.presentationView showVideoCover];
        [self updateStatus:@"插屏视频播放完成，显示伴随图片"
                     color:[IFLYADUtil demoTealColor]];
        [self log:@"nativeFeedAdDidPlayFinish：按模版插屏显示伴随图片"];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailToPlayWithError:(IFLYAdError *)error {
    if (![self isCurrentAd:ad]) {
        return;
    }
    [self log:[NSString stringWithFormat:@"didFailToPlayWithError (%d)：%@",
                                         error.errorCode,
                                         error.errorDescription ?: @"未知错误"]];
    [self closeCurrentPresentationWithStatus:@"视频播放失败，已按模版语义关闭"
                                       color:UIColor.systemRedColor];
}

#pragma mark - Helpers

- (BOOL)isCurrentAd:(IFLYNativeFeedAd *)ad {
    return ad != nil && ad == self.nativeFeedAd;
}

- (BOOL)isCurrentGeneration:(NSUInteger)generation
                         ad:(IFLYNativeFeedAd *)ad
                       view:(IFLYNativeFeedDemoPresentationView *)presentationView {
    return generation == self.lifecycleGeneration && [self isCurrentAd:ad] &&
           presentationView == self.presentationView && !self.cleaningUp;
}

- (void)updateStatus:(NSString *)text color:(UIColor *)color {
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
}

- (void)log:(NSString *)text {
    IFLYSampleLogInfo(@"NativeFeed视觉示例", @"%@", text);
    [IFLYADUtil appendLog:text toTextView:self.logView];
}

@end
