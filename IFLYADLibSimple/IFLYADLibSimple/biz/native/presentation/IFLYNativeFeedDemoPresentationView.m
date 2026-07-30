#import "IFLYNativeFeedDemoPresentationView.h"

#import <ImageIO/ImageIO.h>

NSString *const IFLYNativeFeedDemoPresentationViewErrorDomain =
    @"IFLYNativeFeedDemoPresentationViewErrorDomain";

typedef NS_ENUM(NSInteger, IFLYNativeFeedDemoPresentationViewErrorCode) {
    IFLYNativeFeedDemoPresentationViewErrorCodeMaterialInvalid = 1,
    IFLYNativeFeedDemoPresentationViewErrorCodeImageLoadFailed = 2,
};

static CGFloat const kIFLYNativeFeedTemplateOverlayRed = 0.3;
static CGFloat const kIFLYNativeFeedTemplateOverlayGreen = 0.3;
static CGFloat const kIFLYNativeFeedTemplateOverlayBlue = 0.3;
static CGFloat const kIFLYNativeFeedTemplateOverlayAlpha = 0.4;

static UIColor *IFLYNativeFeedTemplateOverlayColor(void) {
    return [UIColor colorWithRed:kIFLYNativeFeedTemplateOverlayRed
                           green:kIFLYNativeFeedTemplateOverlayGreen
                            blue:kIFLYNativeFeedTemplateOverlayBlue
                           alpha:kIFLYNativeFeedTemplateOverlayAlpha];
}

static BOOL IFLYNativeFeedTemplateValidSize(CGSize size) {
    return isfinite(size.width) && isfinite(size.height) &&
           size.width > 0.0 && size.height > 0.0;
}

static UIImage *IFLYNativeFeedTemplateAnimatedGIFAtPath(NSString *path) {
    if (path.length == 0) {
        return nil;
    }
    NSURL *URL = [NSURL fileURLWithPath:path];
    CGImageSourceRef source =
        CGImageSourceCreateWithURL((__bridge CFURLRef)URL, NULL);
    if (!source) {
        return nil;
    }

    size_t count = CGImageSourceGetCount(source);
    NSMutableArray<UIImage *> *frames =
        [NSMutableArray arrayWithCapacity:count];
    NSTimeInterval totalDuration = 0.0;
    for (size_t index = 0; index < count; index++) {
        CGImageRef CGImage =
            CGImageSourceCreateImageAtIndex(source, index, NULL);
        if (!CGImage) {
            continue;
        }
        NSDictionary *properties =
            CFBridgingRelease(
                CGImageSourceCopyPropertiesAtIndex(source, index, NULL));
        NSDictionary *GIFProperties =
            properties[(NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *delay =
            GIFProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime]
                ?: GIFProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        NSTimeInterval frameDuration = delay.doubleValue;
        if (frameDuration < 0.02) {
            frameDuration = 0.1;
        }
        totalDuration += frameDuration;
        [frames addObject:[UIImage imageWithCGImage:CGImage]];
        CGImageRelease(CGImage);
    }
    CFRelease(source);

    if (frames.count == 0) {
        return nil;
    }
    if (frames.count == 1) {
        return frames.firstObject;
    }
    if (totalDuration <= 0.0) {
        totalDuration = frames.count * 0.1;
    }
    return [UIImage animatedImageWithImages:frames duration:totalDuration];
}

static UIImage *IFLYNativeFeedTemplateResourceImage(NSString *name,
                                                     NSString *extension) {
    if (name.length == 0) {
        return nil;
    }

    NSArray<NSBundle *> *candidateBundles = @[
        NSBundle.mainBundle,
        [NSBundle bundleForClass:IFLYNativeFeedDemoPresentationView.class],
    ];
    for (NSBundle *bundle in candidateBundles) {
        NSString *nestedBundlePath =
            [bundle pathForResource:@"IFLYPlayer" ofType:@"bundle"];
        NSBundle *resourceBundle =
            nestedBundlePath.length > 0
                ? [NSBundle bundleWithPath:nestedBundlePath]
                : nil;
        NSString *path =
            [resourceBundle pathForResource:name ofType:extension];
        if (path.length == 0) {
            path = [bundle pathForResource:name ofType:extension];
        }
        UIImage *image = nil;
        if ([extension.lowercaseString isEqualToString:@"gif"]) {
            image = IFLYNativeFeedTemplateAnimatedGIFAtPath(path);
        } else if (path.length > 0) {
            image = [UIImage imageWithContentsOfFile:path];
        }
        if (image) {
            return image;
        }
    }
    return nil;
}

static NSAttributedString *IFLYNativeFeedTemplateInlineImageText(
    NSString *text,
    UIImage *image,
    BOOL prependImage) {
    NSMutableAttributedString *result =
        [[NSMutableAttributedString alloc] initWithString:text ?: @""];
    if (!image) {
        return result;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0.0, -2.0, 16.0, 16.0);
    NSAttributedString *imageText =
        [NSAttributedString attributedStringWithAttachment:attachment];
    if (prependImage) {
        [result insertAttributedString:imageText atIndex:0];
    } else {
        [result appendAttributedString:imageText];
    }
    return result;
}

static UIImage *IFLYNativeFeedTemplateMuteIcon(BOOL muted) {
    CGSize size = CGSizeMake(24.0, 24.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [UIColor.whiteColor setFill];
    [UIColor.whiteColor setStroke];

    UIBezierPath *speaker = [UIBezierPath bezierPath];
    [speaker moveToPoint:CGPointMake(4.0, 9.0)];
    [speaker addLineToPoint:CGPointMake(8.0, 9.0)];
    [speaker addLineToPoint:CGPointMake(13.0, 5.5)];
    [speaker addLineToPoint:CGPointMake(13.0, 18.5)];
    [speaker addLineToPoint:CGPointMake(8.0, 15.0)];
    [speaker addLineToPoint:CGPointMake(4.0, 15.0)];
    [speaker closePath];
    [speaker fill];

    if (muted) {
        UIBezierPath *muteMark = [UIBezierPath bezierPath];
        muteMark.lineWidth = 1.9;
        muteMark.lineCapStyle = kCGLineCapRound;
        [muteMark moveToPoint:CGPointMake(16.0, 9.0)];
        [muteMark addLineToPoint:CGPointMake(20.0, 15.0)];
        [muteMark moveToPoint:CGPointMake(20.0, 9.0)];
        [muteMark addLineToPoint:CGPointMake(16.0, 15.0)];
        [muteMark stroke];
    } else {
        UIBezierPath *smallWave =
            [UIBezierPath bezierPathWithArcCenter:CGPointMake(13.0, 12.0)
                                           radius:4.0
                                       startAngle:-0.62
                                         endAngle:0.62
                                        clockwise:YES];
        smallWave.lineWidth = 1.9;
        smallWave.lineCapStyle = kCGLineCapRound;
        [smallWave stroke];

        UIBezierPath *largeWave =
            [UIBezierPath bezierPathWithArcCenter:CGPointMake(13.0, 12.0)
                                           radius:7.0
                                       startAngle:-0.58
                                         endAngle:0.58
                                        clockwise:YES];
        largeWave.lineWidth = 1.9;
        largeWave.lineCapStyle = kCGLineCapRound;
        [largeWave stroke];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@interface IFLYNativeFeedDemoPresentationView ()
@property (nonatomic, strong) id<IFLYNativeFeedDemoImageLoading> imageLoader;
@property (nonatomic, strong) NSMutableArray<id<IFLYNativeFeedDemoImageRequest>> *imageRequests;
@property (nonatomic, strong, nullable) IFLYNativeFeedAdData *adData;
@property (nonatomic, copy, nullable) IFLYNativeFeedDemoPresentationReadyHandler readyHandler;
@property (nonatomic, assign) NSUInteger renderGeneration;
@property (nonatomic, assign) NSUInteger pendingRequiredImageCount;
@property (nonatomic, assign) BOOL preparationActive;
@property (nonatomic, assign) CGSize materialSize;
@property (nonatomic, assign) BOOL headingInteractionEnabled;
@property (nonatomic, assign) BOOL usesTallSplashCTA;
@property (nonatomic, assign) BOOL badgeReservesIconSpace;

@property (nonatomic, assign, readwrite) IFLYNativeFeedDemoPresentationStyle presentationStyle;
@property (nonatomic, assign, readwrite) IFLYNativeFeedAdMaterialType displayedMaterialType;
@property (nonatomic, assign, readwrite) NSUInteger displayedImageCount;
@property (nonatomic, assign, readwrite, getter=isContentReady) BOOL contentReady;
@property (nonatomic, assign, readwrite, getter=isVideoCoverVisible) BOOL videoCoverVisible;
@property (nonatomic, assign, readwrite, getter=isMuted) BOOL muted;
@property (nonatomic, strong, readwrite) UIView *mediaView;
@property (nonatomic, strong, readwrite) UIView *videoView;
@property (nonatomic, strong, readwrite) UIView *closeView;

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *surfaceView;
@property (nonatomic, strong) UIView *splashBottomView;
@property (nonatomic, strong) UIImageView *singleImageView;
@property (nonatomic, strong) UIView *multipleImageContainer;
@property (nonatomic, copy) NSArray<UIImageView *> *multipleImageViews;
@property (nonatomic, strong) UIView *videoCoverView;
@property (nonatomic, strong) UIImageView *videoCoverImageView;
@property (nonatomic, strong) UILabel *videoPlaceholderLabel;

@property (nonatomic, strong) UIView *adSourceBadgeView;
@property (nonatomic, strong) UIImageView *adSourceIconView;
@property (nonatomic, strong) UILabel *adSourceLabel;
// 保留这三个属性供既有 Demo 测试取证；模版样式不展示标题、描述和独立交互提示。
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *interactionHintLabel;

@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UILabel *ctaTitleLabel;
@property (nonatomic, strong) UILabel *ctaSubtitleLabel;
@property (nonatomic, strong) UIImageView *ctaIconView;
@property (nonatomic, strong) UIImageView *interactionGIFView;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *noAdsButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CALayer *closeVisibleBackgroundLayer;
@property (nonatomic, strong) CAShapeLayer *closeIconLayer;
@end

@implementation IFLYNativeFeedDemoPresentationView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame
             presentationStyle:IFLYNativeFeedDemoPresentationStyleInterstitial];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithFrame:CGRectZero
             presentationStyle:IFLYNativeFeedDemoPresentationStyleInterstitial];
}

- (instancetype)initWithFrame:(CGRect)frame
            presentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle {
    return [self initWithFrame:frame
             presentationStyle:presentationStyle
                   imageLoader:[[IFLYNativeFeedDemoImageLoader alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)frame
            presentationStyle:(IFLYNativeFeedDemoPresentationStyle)presentationStyle
                  imageLoader:(id<IFLYNativeFeedDemoImageLoading>)imageLoader {
    self = [super initWithFrame:frame];
    if (self) {
        _presentationStyle = presentationStyle;
        _interstitialPresentationMode =
            IFLYNativeFeedDemoInterstitialPresentationModeHalfScreen;
        _interstitialMaterialOrientation =
            IFLYNativeFeedDemoInterstitialMaterialOrientationAutomatic;
        _imageLoader = imageLoader ?: [[IFLYNativeFeedDemoImageLoader alloc] init];
        _imageRequests = [NSMutableArray array];
        _displayedMaterialType = IFLYNativeFeedAdMaterialTypeUnknown;
        _muted = YES;
        self.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.accessibilityIdentifier = @"nativeFeed.demo.presentation";
        [self buildViewTree];
        [self reset];
    }
    return self;
}

- (void)buildViewTree {
    self.dimmingView = [[UIView alloc] init];
    self.dimmingView.userInteractionEnabled = NO;
    self.dimmingView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.dimming";
    [self addSubview:self.dimmingView];

    self.surfaceView = [[UIView alloc] init];
    self.surfaceView.clipsToBounds = YES;
    self.surfaceView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.surface";
    [self addSubview:self.surfaceView];

    self.splashBottomView = [[UIView alloc] init];
    self.splashBottomView.backgroundColor = UIColor.cyanColor;
    self.splashBottomView.userInteractionEnabled = NO;
    self.splashBottomView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.splashBottom";
    [self.surfaceView addSubview:self.splashBottomView];

    self.mediaView = [[UIView alloc] init];
    self.mediaView.clipsToBounds = YES;
    self.mediaView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.media";
    [self.surfaceView addSubview:self.mediaView];

    self.singleImageView = [self creativeImageView];
    [self.mediaView addSubview:self.singleImageView];

    self.multipleImageContainer = [[UIView alloc] init];
    self.multipleImageContainer.clipsToBounds = YES;
    NSMutableArray<UIImageView *> *multipleImageViews =
        [NSMutableArray arrayWithCapacity:3];
    for (NSUInteger index = 0; index < 3; index++) {
        UIImageView *imageView = [self creativeImageView];
        [self.multipleImageContainer addSubview:imageView];
        [multipleImageViews addObject:imageView];
    }
    self.multipleImageViews = multipleImageViews.copy;
    [self.mediaView addSubview:self.multipleImageContainer];

    self.videoView = [[UIView alloc] init];
    self.videoView.backgroundColor = UIColor.blackColor;
    self.videoView.clipsToBounds = YES;
    self.videoView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.video";
    [self.mediaView addSubview:self.videoView];

    self.videoCoverView = [[UIView alloc] init];
    self.videoCoverView.backgroundColor = UIColor.blackColor;
    self.videoCoverView.userInteractionEnabled = NO;
    [self.videoView addSubview:self.videoCoverView];

    self.videoCoverImageView = [self creativeImageView];
    self.videoCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.videoCoverView addSubview:self.videoCoverImageView];

    self.videoPlaceholderLabel = [[UILabel alloc] init];
    self.videoPlaceholderLabel.text = @"视频准备中";
    self.videoPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
    self.videoPlaceholderLabel.font =
        [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    self.videoPlaceholderLabel.textColor = UIColor.whiteColor;
    [self.videoCoverView addSubview:self.videoPlaceholderLabel];

    self.adSourceBadgeView = [[UIView alloc] init];
    self.adSourceBadgeView.backgroundColor = IFLYNativeFeedTemplateOverlayColor();
    self.adSourceBadgeView.layer.cornerRadius = 4.0;
    self.adSourceBadgeView.clipsToBounds = YES;
    self.adSourceBadgeView.userInteractionEnabled = NO;
    self.adSourceBadgeView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.adSourceBadge";
    [self.surfaceView addSubview:self.adSourceBadgeView];

    self.adSourceIconView = [[UIImageView alloc] init];
    self.adSourceIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.adSourceIconView.clipsToBounds = YES;
    [self.adSourceBadgeView addSubview:self.adSourceIconView];

    self.adSourceLabel = [[UILabel alloc] init];
    self.adSourceLabel.text = @"广告";
    self.adSourceLabel.textColor = UIColor.whiteColor;
    self.adSourceLabel.textAlignment = NSTextAlignmentCenter;
    self.adSourceLabel.adjustsFontSizeToFitWidth = YES;
    self.adSourceLabel.minimumScaleFactor = 0.75;
    [self.adSourceBadgeView addSubview:self.adSourceLabel];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.hidden = YES;
    [self.surfaceView addSubview:self.titleLabel];

    self.descLabel = [[UILabel alloc] init];
    self.descLabel.hidden = YES;
    [self.surfaceView addSubview:self.descLabel];

    self.interactionHintLabel = [[UILabel alloc] init];
    self.interactionHintLabel.hidden = YES;
    [self.surfaceView addSubview:self.interactionHintLabel];

    self.ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ctaButton.backgroundColor = IFLYNativeFeedTemplateOverlayColor();
    self.ctaButton.clipsToBounds = YES;
    self.ctaButton.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.cta";
    [self.ctaButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    [self.surfaceView addSubview:self.ctaButton];

    self.ctaTitleLabel = [[UILabel alloc] init];
    self.ctaTitleLabel.textColor = UIColor.whiteColor;
    self.ctaTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.ctaTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.ctaTitleLabel.minimumScaleFactor = 0.75;
    self.ctaTitleLabel.userInteractionEnabled = NO;
    [self.ctaButton addSubview:self.ctaTitleLabel];

    self.ctaSubtitleLabel = [[UILabel alloc] init];
    self.ctaSubtitleLabel.textColor = UIColor.whiteColor;
    self.ctaSubtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.ctaSubtitleLabel.font = [UIFont systemFontOfSize:13.0];
    self.ctaSubtitleLabel.userInteractionEnabled = NO;
    [self.ctaButton addSubview:self.ctaSubtitleLabel];

    self.ctaIconView = [[UIImageView alloc] init];
    self.ctaIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.ctaIconView.userInteractionEnabled = NO;
    [self.ctaButton addSubview:self.ctaIconView];

    self.interactionGIFView = [[UIImageView alloc] init];
    self.interactionGIFView.backgroundColor = IFLYNativeFeedTemplateOverlayColor();
    self.interactionGIFView.contentMode = UIViewContentModeScaleAspectFit;
    self.interactionGIFView.clipsToBounds = YES;
    self.interactionGIFView.layer.cornerRadius = 32.0;
    self.interactionGIFView.userInteractionEnabled = NO;
    self.interactionGIFView.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.interactionGIF";
    [self.surfaceView addSubview:self.interactionGIFView];

    self.muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.muteButton.backgroundColor = IFLYNativeFeedTemplateOverlayColor();
    self.muteButton.clipsToBounds = YES;
    self.muteButton.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.mute";
    [self.muteButton setImage:IFLYNativeFeedTemplateMuteIcon(YES)
                     forState:UIControlStateNormal];
    [self.muteButton setImage:IFLYNativeFeedTemplateMuteIcon(NO)
                     forState:UIControlStateSelected];
    [self.muteButton addTarget:self
                        action:@selector(handleMuteButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    [self.surfaceView addSubview:self.muteButton];

    self.noAdsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noAdsButton.backgroundColor = IFLYNativeFeedTemplateOverlayColor();
    self.noAdsButton.clipsToBounds = YES;
    self.noAdsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.noAdsButton setTitle:@"免除广告" forState:UIControlStateNormal];
    [self.noAdsButton setTitleColor:UIColor.whiteColor
                          forState:UIControlStateNormal];
    self.noAdsButton.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.noAds";
    [self.noAdsButton addTarget:self
                         action:@selector(handleNoAdsButtonTap)
               forControlEvents:UIControlEventTouchUpInside];
    [self.surfaceView addSubview:self.noAdsButton];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.backgroundColor = UIColor.clearColor;
    self.closeButton.clipsToBounds = NO;
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
    [self.closeButton setTitleColor:UIColor.whiteColor
                          forState:UIControlStateNormal];
    self.closeButton.accessibilityIdentifier =
        @"nativeFeed.demo.presentation.close";

    self.closeVisibleBackgroundLayer = [CALayer layer];
    self.closeVisibleBackgroundLayer.backgroundColor =
        IFLYNativeFeedTemplateOverlayColor().CGColor;
    [self.closeButton.layer insertSublayer:self.closeVisibleBackgroundLayer
                                  atIndex:0];

    self.closeIconLayer = [CAShapeLayer layer];
    self.closeIconLayer.fillColor = UIColor.clearColor.CGColor;
    self.closeIconLayer.strokeColor = UIColor.whiteColor.CGColor;
    self.closeIconLayer.lineWidth = 2.4;
    self.closeIconLayer.lineCap = kCALineCapRound;
    self.closeIconLayer.lineJoin = kCALineJoinRound;
    self.closeIconLayer.contentsScale = UIScreen.mainScreen.scale;
    [self.closeButton.layer addSublayer:self.closeIconLayer];
    [self.surfaceView addSubview:self.closeButton];
    self.closeView = self.closeButton;
}

- (UIImageView *)creativeImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    // 与 SDK 模版一致，图片视图本身透明；底色由开屏媒体区或插屏内容区提供。
    imageView.backgroundColor = UIColor.clearColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    return imageView;
}

- (void)setInterstitialPresentationMode:
    (IFLYNativeFeedDemoInterstitialPresentationMode)interstitialPresentationMode {
    if (_interstitialPresentationMode == interstitialPresentationMode) {
        return;
    }
    _interstitialPresentationMode = interstitialPresentationMode;
    [self applyTemplateAppearance];
    [self setNeedsLayout];
}

- (void)setInterstitialMaterialOrientation:
    (IFLYNativeFeedDemoInterstitialMaterialOrientation)interstitialMaterialOrientation {
    if (_interstitialMaterialOrientation == interstitialMaterialOrientation) {
        return;
    }
    _interstitialMaterialOrientation = interstitialMaterialOrientation;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self applyTemplateAppearance];

    self.dimmingView.frame = self.bounds;
    if (self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash) {
        [self layoutSplashTemplate];
    } else {
        [self layoutInterstitialTemplate];
    }
    [self layoutMediaSubviews];
    [self layoutBadgeContents];
    [self layoutCTAContents];
    self.muteButton.layer.cornerRadius =
        MIN(CGRectGetWidth(self.muteButton.bounds),
            CGRectGetHeight(self.muteButton.bounds)) * 0.5;
    [self layoutCloseButtonLayers];
}

- (void)applyTemplateAppearance {
    BOOL splash =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
    BOOL fullInterstitial =
        !splash &&
        self.interstitialPresentationMode ==
            IFLYNativeFeedDemoInterstitialPresentationModeFullScreen;

    self.backgroundColor = splash ? UIColor.whiteColor : UIColor.clearColor;
    self.opaque = splash;
    self.dimmingView.hidden = splash;
    self.dimmingView.backgroundColor =
        fullInterstitial
            ? UIColor.blackColor
            : [UIColor colorWithWhite:0.0 alpha:0.45];
    self.dimmingView.opaque = fullInterstitial;

    self.surfaceView.backgroundColor =
        splash
            ? UIColor.whiteColor
            : (fullInterstitial
                   ? UIColor.blackColor
                   : [UIColor colorWithWhite:0.0 alpha:0.35]);
    self.surfaceView.opaque = splash || fullInterstitial;
    self.surfaceView.layer.cornerRadius =
        (!splash && !fullInterstitial) ? 8.0 : 0.0;
    self.splashBottomView.hidden = !splash;

    UIColor *mediaBackground =
        splash
            ? UIColor.whiteColor
            : (fullInterstitial
                   ? UIColor.blackColor
                   : [UIColor colorWithWhite:0.0 alpha:0.35]);
    self.mediaView.backgroundColor = mediaBackground;
    self.multipleImageContainer.backgroundColor = mediaBackground;

    UIViewContentMode imageContentMode =
        splash ? UIViewContentModeScaleToFill
               : UIViewContentModeScaleAspectFit;
    self.singleImageView.contentMode = imageContentMode;
    self.singleImageView.backgroundColor = UIColor.clearColor;
    for (UIImageView *imageView in self.multipleImageViews) {
        imageView.contentMode = imageContentMode;
        imageView.backgroundColor = UIColor.clearColor;
    }
    self.videoCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.videoCoverImageView.backgroundColor = UIColor.clearColor;

    self.titleLabel.hidden = YES;
    self.descLabel.hidden = YES;
    self.interactionHintLabel.hidden = YES;
    self.noAdsButton.hidden = !splash;
    self.interactionGIFView.hidden =
        !splash || !self.interactionGIFView.image ||
        !self.usesTallSplashCTA;
}

- (BOOL)isNotchedDisplay {
    UIEdgeInsets insets = self.safeAreaInsets;
    return insets.top > 20.0 || insets.bottom > 0.0;
}

- (void)layoutSplashTemplate {
    CGFloat width = MAX(0.0, CGRectGetWidth(self.bounds));
    CGFloat height = MAX(0.0, CGRectGetHeight(self.bounds));
    CGFloat mediaHeight = MAX(0.0, height - 100.0);
    self.surfaceView.frame = self.bounds;
    self.mediaView.frame = CGRectMake(0.0, 0.0, width, mediaHeight);
    self.splashBottomView.frame =
        CGRectMake(0.0, mediaHeight, width, height - mediaHeight);

    BOOL notched = [self isNotchedDisplay];
    CGFloat badgeY = notched ? 44.0 : 20.0;
    CGFloat badgeMaxWidth = MAX(0.0, width - 26.0);
    CGFloat badgeWidth = [self preferredBadgeWidthConstrainedToWidth:badgeMaxWidth];
    self.adSourceBadgeView.frame =
        CGRectMake(13.0, badgeY, badgeWidth, 20.0);

    self.closeButton.frame =
        CGRectMake(width - 80.0, notched ? 64.0 : 40.0, 70.0, 35.0);
    self.noAdsButton.frame = CGRectMake(0.0, 0.0, 60.0, 26.0);
    self.noAdsButton.center =
        CGPointMake(width - 45.0, notched ? 124.0 : 100.0);

    CGFloat leadingSafeInset = MAX(0.0, self.safeAreaInsets.left);
    CGFloat bottomSafeInset =
        notched ? MAX(34.0, self.safeAreaInsets.bottom)
                : MAX(0.0, self.safeAreaInsets.bottom);
    CGFloat muteY =
        mediaHeight - bottomSafeInset - 13.0 - 35.0;
    muteY = MAX(badgeY, muteY);
    self.muteButton.frame =
        CGRectMake(leadingSafeInset + 13.0, muteY, 44.0, 35.0);

    CGFloat ctaHeight = self.usesTallSplashCTA ? 80.0 : 60.0;
    CGFloat ctaWidth = MIN(300.0, MAX(0.0, width - 20.0));
    self.ctaButton.frame =
        CGRectMake(0.0, 0.0, ctaWidth, ctaHeight);
    self.ctaButton.center =
        CGPointMake(CGRectGetMidX(self.mediaView.frame),
                    CGRectGetMidY(self.mediaView.frame) +
                        120.0 + ctaHeight);
    self.ctaButton.layer.cornerRadius = ctaHeight * 0.5;

    self.interactionGIFView.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
    self.interactionGIFView.center =
        CGPointMake(CGRectGetMidX(self.mediaView.frame),
                    CGRectGetMidY(self.mediaView.frame) + 100.0);
    self.interactionGIFView.layer.cornerRadius = 32.0;
}

- (void)layoutInterstitialTemplate {
    BOOL full =
        self.interstitialPresentationMode ==
        IFLYNativeFeedDemoInterstitialPresentationModeFullScreen;
    CGRect contentFrame =
        full ? self.bounds : [self halfScreenContentFrame];
    self.surfaceView.frame = contentFrame;
    self.mediaView.frame = self.surfaceView.bounds;
    self.splashBottomView.frame = CGRectZero;

    CGFloat surfaceWidth = CGRectGetWidth(self.surfaceView.bounds);
    CGFloat surfaceHeight = CGRectGetHeight(self.surfaceView.bounds);
    UIEdgeInsets safeInsets = full ? self.safeAreaInsets : UIEdgeInsetsZero;
    CGFloat top = full ? MAX(10.0, safeInsets.top + 8.0) : 0.0;
    CGFloat right =
        full ? surfaceWidth - safeInsets.right - 12.0 : surfaceWidth;
    CGFloat left = full ? safeInsets.left + 12.0 : 0.0;
    CGFloat bottom =
        full ? surfaceHeight - safeInsets.bottom - 24.0 : surfaceHeight;

    self.closeButton.frame =
        CGRectMake(right - 52.0, top, 52.0, 52.0);

    CGFloat badgeX = left + 8.0;
    CGFloat badgeY = top + 8.0;
    CGFloat badgeMaxWidth =
        MAX(36.0, right - badgeX - 52.0 - 12.0);
    CGFloat badgeWidth =
        [self preferredBadgeWidthConstrainedToWidth:badgeMaxWidth];
    self.adSourceBadgeView.frame =
        CGRectMake(badgeX, badgeY, badgeWidth, 22.0);

    CGFloat ctaMaxAvailableWidth = MAX(0.0, surfaceWidth - 20.0);
    CGFloat ctaWidth =
        MIN(300.0, MAX(240.0, surfaceWidth * 0.9));
    ctaWidth = MIN(ctaWidth, ctaMaxAvailableWidth);
    CGFloat ctaHeight =
        MIN(60.0, MAX(48.0, surfaceHeight * 0.32));
    self.ctaButton.frame =
        CGRectMake(surfaceWidth * 0.5 - ctaWidth * 0.5,
                   bottom - ctaHeight - 18.0,
                   ctaWidth,
                   ctaHeight);
    self.ctaButton.layer.cornerRadius = ctaHeight * 0.5;

    CGFloat muteY =
        CGRectGetMinY(self.ctaButton.frame) - 35.0 - 8.0;
    muteY = MAX(top + 22.0 + 14.0, muteY);
    self.muteButton.frame =
        CGRectMake(left + 8.0, muteY, 44.0, 35.0);
}

- (CGRect)halfScreenContentFrame {
    CGRect safeBounds = UIEdgeInsetsInsetRect(self.bounds, self.safeAreaInsets);
    if (CGRectGetWidth(safeBounds) <= 0.0 ||
        CGRectGetHeight(safeBounds) <= 0.0) {
        safeBounds = self.bounds;
    }

    BOOL automatic =
        self.interstitialMaterialOrientation ==
        IFLYNativeFeedDemoInterstitialMaterialOrientationAutomatic;
    BOOL landscape =
        automatic
            ? (IFLYNativeFeedTemplateValidSize(self.materialSize)
                   ? self.materialSize.width > self.materialSize.height
                   : CGRectGetWidth(safeBounds) > CGRectGetHeight(safeBounds))
            : self.interstitialMaterialOrientation ==
                  IFLYNativeFeedDemoInterstitialMaterialOrientationLandscape;
    CGSize effectiveSize = self.materialSize;
    if (!IFLYNativeFeedTemplateValidSize(effectiveSize)) {
        effectiveSize =
            landscape ? CGSizeMake(16.0, 9.0)
                      : CGSizeMake(9.0, 16.0);
    } else {
        BOOL materialIsLandscape =
            effectiveSize.width > effectiveSize.height;
        if (materialIsLandscape != landscape) {
            effectiveSize =
                CGSizeMake(effectiveSize.height, effectiveSize.width);
        }
    }

    CGFloat maxWidth = MAX(80.0, CGRectGetWidth(safeBounds) - 40.0);
    CGFloat maxHeight = MAX(80.0, CGRectGetHeight(safeBounds) - 40.0);
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if (landscape) {
        height = maxHeight;
        width = ceil(height * effectiveSize.width / effectiveSize.height);
        if (width > maxWidth) {
            width = maxWidth;
            height = ceil(width * effectiveSize.height / effectiveSize.width);
        }
    } else {
        width = maxWidth;
        height = ceil(width * effectiveSize.height / effectiveSize.width);
        if (height > maxHeight) {
            height = maxHeight;
            width = ceil(height * effectiveSize.width / effectiveSize.height);
        }
    }

    return CGRectMake(CGRectGetMidX(safeBounds) - width * 0.5,
                      CGRectGetMidY(safeBounds) - height * 0.5,
                      width,
                      height);
}

- (void)layoutMediaSubviews {
    CGRect bounds = self.mediaView.bounds;
    self.singleImageView.frame = bounds;
    self.multipleImageContainer.frame = bounds;
    self.videoView.frame = bounds;
    self.videoCoverView.frame = self.videoView.bounds;
    self.videoCoverImageView.frame = self.videoCoverView.bounds;
    self.videoPlaceholderLabel.frame =
        CGRectInset(self.videoCoverView.bounds, 16.0, 16.0);

    NSUInteger imageCount =
        self.displayedMaterialType ==
                IFLYNativeFeedAdMaterialTypeMultipleImages
            ? MIN(self.displayedImageCount, self.multipleImageViews.count)
            : 0;
    CGFloat gap = 4.0;
    CGFloat totalGap = imageCount > 0 ? gap * (imageCount - 1) : 0.0;
    CGFloat itemWidth =
        imageCount > 0
            ? MAX(0.0, (CGRectGetWidth(bounds) - totalGap) / imageCount)
            : 0.0;
    for (NSUInteger index = 0; index < self.multipleImageViews.count;
         index++) {
        UIImageView *imageView = self.multipleImageViews[index];
        BOOL shouldDisplay = index < imageCount;
        imageView.hidden = !shouldDisplay;
        if (shouldDisplay) {
            imageView.frame =
                CGRectMake((itemWidth + gap) * index,
                           0.0,
                           itemWidth,
                           CGRectGetHeight(bounds));
        }
    }
}

- (CGFloat)preferredBadgeWidthConstrainedToWidth:(CGFloat)maxWidth {
    BOOL splash =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
    CGFloat height = splash ? 20.0 : 22.0;
    CGFloat iconSide = splash ? 12.0 : 18.0;
    CGFloat minWidth =
        self.badgeReservesIconSpace
            ? (splash ? 55.0 : 64.0)
            : (splash ? 40.0 : 36.0);
    CGFloat effectiveMaxWidth = MIN(105.0, MAX(0.0, maxWidth));
    CGFloat textMaxWidth =
        MAX(0.0, effectiveMaxWidth - 12.0 -
                     (self.badgeReservesIconSpace ? iconSide + 4.0 : 0.0));
    CGRect textRect =
        [self.adSourceLabel.text ?: @"广告"
            boundingRectWithSize:CGSizeMake(textMaxWidth, height)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName :
                              self.adSourceLabel.font ?:
                                  [UIFont systemFontOfSize:(splash ? 10.0 : 11.0)]
                      }
                         context:nil];
    CGFloat width = 12.0 + ceil(CGRectGetWidth(textRect)) + 2.0;
    if (self.badgeReservesIconSpace) {
        width += iconSide + 4.0;
    }
    return MIN(effectiveMaxWidth, MAX(minWidth, width));
}

- (void)layoutBadgeContents {
    BOOL splash =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
    CGFloat height = CGRectGetHeight(self.adSourceBadgeView.bounds);
    CGFloat iconSide = splash ? 12.0 : 18.0;
    self.adSourceLabel.font =
        [UIFont systemFontOfSize:(splash ? 10.0 : 11.0)
                         weight:UIFontWeightRegular];
    self.adSourceIconView.hidden = !self.badgeReservesIconSpace;
    if (self.badgeReservesIconSpace) {
        self.adSourceIconView.frame =
            CGRectMake(6.0,
                       floor((height - iconSide) * 0.5),
                       iconSide,
                       iconSide);
        CGFloat textX = CGRectGetMaxX(self.adSourceIconView.frame) + 4.0;
        self.adSourceLabel.frame =
            CGRectMake(textX,
                       0.0,
                       MAX(0.0,
                           CGRectGetWidth(self.adSourceBadgeView.bounds) -
                               textX - 6.0),
                       height);
    } else {
        self.adSourceIconView.frame = CGRectZero;
        self.adSourceLabel.frame = self.adSourceBadgeView.bounds;
    }
}

- (void)layoutCTAContents {
    CGRect bounds = self.ctaButton.bounds;
    BOOL splash =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
    if (!splash) {
        self.ctaTitleLabel.font =
            [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        self.ctaTitleLabel.frame = CGRectInset(bounds, 14.0, 0.0);
        self.ctaSubtitleLabel.frame = CGRectZero;
        self.ctaIconView.frame = CGRectZero;
        return;
    }

    self.ctaTitleLabel.font = [UIFont systemFontOfSize:16.0];
    if (self.usesTallSplashCTA) {
        self.ctaTitleLabel.frame =
            CGRectMake(0.0, 15.0,
                       CGRectGetWidth(bounds),
                       MAX(0.0, CGRectGetHeight(bounds) - 50.0));
        self.ctaSubtitleLabel.frame =
            CGRectMake(0.0,
                       MAX(0.0, CGRectGetHeight(bounds) - 35.0),
                       CGRectGetWidth(bounds),
                       20.0);
        self.ctaIconView.frame = CGRectZero;
    } else {
        self.ctaTitleLabel.frame =
            CGRectMake(0.0, 0.0,
                       CGRectGetWidth(bounds),
                       CGRectGetHeight(bounds));
        self.ctaSubtitleLabel.frame = CGRectZero;
        self.ctaIconView.frame = CGRectZero;
    }
}

- (void)layoutCloseButtonLayers {
    BOOL splash =
        self.presentationStyle == IFLYNativeFeedDemoPresentationStyleSplash;
    if (splash) {
        self.closeVisibleBackgroundLayer.hidden = NO;
        self.closeVisibleBackgroundLayer.frame =
            CGRectMake(5.0, 2.5, 60.0, 30.0);
        self.closeVisibleBackgroundLayer.cornerRadius = 15.0;
        self.closeIconLayer.hidden = YES;
        return;
    }

    self.closeVisibleBackgroundLayer.hidden = NO;
    self.closeVisibleBackgroundLayer.frame =
        CGRectMake(12.0, 12.0, 28.0, 28.0);
    self.closeVisibleBackgroundLayer.cornerRadius = 14.0;
    self.closeIconLayer.hidden = NO;
    self.closeIconLayer.frame = CGRectMake(14.0, 14.0, 24.0, 24.0);
    CGFloat inset = floor(24.0 * 0.30);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(inset, inset)];
    [path addLineToPoint:CGPointMake(24.0 - inset, 24.0 - inset)];
    [path moveToPoint:CGPointMake(24.0 - inset, inset)];
    [path addLineToPoint:CGPointMake(inset, 24.0 - inset)];
    self.closeIconLayer.path = path.CGPath;
}

- (BOOL)prepareWithAdData:(IFLYNativeFeedAdData *)adData
 headingInteractionEnabled:(BOOL)headingInteractionEnabled
                completion:(IFLYNativeFeedDemoPresentationReadyHandler)completion
                     error:(NSError **)error {
    [self reset];
    if (error) {
        *error = nil;
    }
    if (!adData || !adData.isMaterialComplete ||
        ![self canRenderAdData:adData]) {
        NSError *materialError =
            [self errorWithCode:
                      IFLYNativeFeedDemoPresentationViewErrorCodeMaterialInvalid
                   description:@"自渲染开屏/插屏素材不完整或类型不受支持"];
        if (error) {
            *error = materialError;
        }
        return NO;
    }

    self.adData = adData;
    self.displayedMaterialType = adData.materialType;
    self.headingInteractionEnabled = headingInteractionEnabled;
    self.materialSize =
        IFLYNativeFeedTemplateValidSize(adData.videoSize)
            ? adData.videoSize
            : adData.imageSize;
    self.readyHandler = completion;
    self.preparationActive = YES;
    NSUInteger generation = self.renderGeneration;
    [self configureTemplateControlsWithAdData:adData];
    [self beginOptionalAdSourceIconWithURL:adData.adSourceIconURL
                                generation:generation];

    switch (adData.materialType) {
        case IFLYNativeFeedAdMaterialTypeSingleImage:
            self.displayedImageCount = 1;
            self.singleImageView.hidden = NO;
            self.multipleImageContainer.hidden = YES;
            self.videoView.hidden = YES;
            [self beginRequiredImages:@[ adData.imageURLs.firstObject ]
                           imageViews:@[ self.singleImageView ]
                           generation:generation];
            break;
        case IFLYNativeFeedAdMaterialTypeMultipleImages: {
            NSUInteger imageCount =
                MIN(MIN(adData.imageList.count, adData.imageURLs.count),
                    self.multipleImageViews.count);
            self.displayedImageCount = imageCount;
            self.singleImageView.hidden = YES;
            self.multipleImageContainer.hidden = NO;
            self.videoView.hidden = YES;
            NSArray<NSString *> *imageURLs =
                [adData.imageURLs
                    subarrayWithRange:NSMakeRange(0, imageCount)];
            NSArray<UIImageView *> *imageViews =
                [self.multipleImageViews
                    subarrayWithRange:NSMakeRange(0, imageCount)];
            [self beginRequiredImages:imageURLs
                           imageViews:imageViews
                           generation:generation];
            break;
        }
        case IFLYNativeFeedAdMaterialTypeVideo: {
            NSString *coverURL =
                adData.videoCoverURL ?: adData.mainImage.url;
            self.displayedImageCount = coverURL.length > 0 ? 1 : 0;
            self.singleImageView.hidden = YES;
            self.multipleImageContainer.hidden = YES;
            self.videoView.hidden = NO;
            self.muteButton.hidden = NO;
            [self showVideoCover];
            [self beginOptionalVideoCoverWithURL:coverURL
                                      generation:generation];
            [self finishPreparationForGeneration:generation];
            break;
        }
        default:
            return NO;
    }
    [self setNeedsLayout];
    return YES;
}

- (BOOL)canRenderAdData:(IFLYNativeFeedAdData *)adData {
    switch (adData.materialType) {
        case IFLYNativeFeedAdMaterialTypeSingleImage:
            return adData.imageURLs.count > 0;
        case IFLYNativeFeedAdMaterialTypeMultipleImages:
            return adData.imageList.count >= 2;
        case IFLYNativeFeedAdMaterialTypeVideo:
            return adData.videoURL.length > 0;
        default:
            return NO;
    }
}

- (void)configureTemplateControlsWithAdData:
    (IFLYNativeFeedAdData *)adData {
    self.adSourceLabel.text = adData.adSourceMark ?: @"广告";
    self.badgeReservesIconSpace = adData.adSourceIconURL.length > 0;
    self.adSourceBadgeView.hidden = NO;
    self.adSourceIconView.image = nil;

    self.titleLabel.text = adData.title ?: adData.brand ?: @"广告";
    self.descLabel.text = adData.desc ?: adData.content ?: @"";

    BOOL clickable =
        adData.interactionType ==
            IFLYNativeFeedAdInteractionTypeRedirect ||
        adData.interactionType ==
            IFLYNativeFeedAdInteractionTypeDownload;
    self.ctaButton.hidden = !clickable;
    self.usesTallSplashCTA =
        clickable &&
        (adData.interactType ==
             IFLYNativeFeedAdInteractTypeClickAndShake ||
         adData.interactType ==
             IFLYNativeFeedAdInteractTypeClickShakeAndSlide);

    NSString *ctaText =
        adData.ctaText.length > 0 ? adData.ctaText : @"查看详情";
    if (self.presentationStyle ==
        IFLYNativeFeedDemoPresentationStyleInterstitial) {
        self.ctaTitleLabel.attributedText = nil;
        BOOL hasShake =
            adData.interactType ==
                IFLYNativeFeedAdInteractTypeClickAndShake ||
            adData.interactType ==
                IFLYNativeFeedAdInteractTypeClickShakeAndSlide;
        if (hasShake) {
            NSString *gesture =
                self.headingInteractionEnabled ? @"扭一扭" : @"摇一摇";
            self.ctaTitleLabel.text =
                [NSString stringWithFormat:@"%@或点击%@",
                                           gesture,
                                           ctaText];
        } else {
            self.ctaTitleLabel.text = ctaText;
        }
        self.ctaSubtitleLabel.text = nil;
        self.ctaIconView.image = nil;
        self.interactionGIFView.image = nil;
    } else if (self.usesTallSplashCTA) {
        NSString *gesture =
            self.headingInteractionEnabled ? @"扭一扭" : @"摇一摇";
        BOOL combinedInteract =
            adData.interactType ==
            IFLYNativeFeedAdInteractTypeClickShakeAndSlide;
        NSString *title =
            [NSString stringWithFormat:@"%@或点击图标%@",
                                       gesture,
                                       combinedInteract ? @"" : @" "];
        UIImage *inlineImage =
            IFLYNativeFeedTemplateResourceImage(
                combinedInteract ? @"IFLYAd_shack" : @"IFLYAd_click",
                @"png");
        self.ctaTitleLabel.attributedText =
            IFLYNativeFeedTemplateInlineImageText(title,
                                                  inlineImage,
                                                  combinedInteract);
        self.ctaSubtitleLabel.text = @"跳转详情页或第三方应用";
        self.ctaIconView.image = nil;
        self.interactionGIFView.image =
            IFLYNativeFeedTemplateResourceImage(@"IFLYAdGIF_shack", @"gif");
    } else {
        self.ctaTitleLabel.attributedText =
            IFLYNativeFeedTemplateInlineImageText(
                @"点击了解更多活动详情 ",
                IFLYNativeFeedTemplateResourceImage(@"IFLYAd_right_arrow",
                                                    @"png"),
                NO);
        self.ctaSubtitleLabel.text = nil;
        self.ctaIconView.image = nil;
        self.interactionGIFView.image = nil;
    }

    if (!clickable) {
        self.interactionHintLabel.text = nil;
    } else {
        switch (adData.interactType) {
            case IFLYNativeFeedAdInteractTypeClickAndShake:
                self.interactionHintLabel.text =
                    self.headingInteractionEnabled
                        ? @"扭一扭查看详情"
                        : @"摇一摇查看详情";
                break;
            case IFLYNativeFeedAdInteractTypeClickAndSlide:
                self.interactionHintLabel.text = @"点击查看详情";
                break;
            case IFLYNativeFeedAdInteractTypeClickShakeAndSlide:
                self.interactionHintLabel.text =
                    self.headingInteractionEnabled
                        ? @"点击或扭一扭查看详情"
                        : @"点击或摇一摇查看详情";
                break;
            case IFLYNativeFeedAdInteractTypeClick:
                self.interactionHintLabel.text = @"点击查看详情";
                break;
            default:
                self.interactionHintLabel.text = nil;
                break;
        }
    }

    self.muteButton.hidden =
        adData.materialType != IFLYNativeFeedAdMaterialTypeVideo;
    [self applyTemplateAppearance];
}

- (void)beginRequiredImages:(NSArray<NSString *> *)URLs
                 imageViews:(NSArray<UIImageView *> *)imageViews
                 generation:(NSUInteger)generation {
    self.pendingRequiredImageCount = URLs.count;
    for (NSUInteger index = 0; index < URLs.count; index++) {
        if (generation != self.renderGeneration ||
            !self.preparationActive) {
            break;
        }
        NSString *URLString = URLs[index];
        UIImageView *imageView = imageViews[index];
        __block BOOL callbackDelivered = NO;
        NSObject *callbackGate = [[NSObject alloc] init];
        __weak typeof(self) weakSelf = self;
        id<IFLYNativeFeedDemoImageRequest> request =
            [self.imageLoader
                loadImageWithURLString:URLString
                            completion:^(UIImage *image) {
            @synchronized(callbackGate) {
                callbackDelivered = YES;
            }
            void (^applyImage)(void) = ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self ||
                    generation != self.renderGeneration ||
                    !self.preparationActive) {
                    return;
                }
                if (!image) {
                    [self failPreparationForGeneration:generation];
                    return;
                }
                imageView.image = image;
                if (self.pendingRequiredImageCount > 0) {
                    self.pendingRequiredImageCount -= 1;
                }
                if (self.pendingRequiredImageCount == 0) {
                    [self finishPreparationForGeneration:generation];
                }
            };
            if (NSThread.isMainThread) {
                applyImage();
            } else {
                dispatch_async(dispatch_get_main_queue(), applyImage);
            }
        }];
        BOOL callbackWasDelivered = NO;
        @synchronized(callbackGate) {
            callbackWasDelivered = callbackDelivered;
        }
        if (request) {
            if (generation != self.renderGeneration ||
                (!self.preparationActive && !self.isContentReady)) {
                [request cancel];
            } else if (!callbackWasDelivered) {
                [self.imageRequests addObject:request];
            }
        } else if (!callbackWasDelivered) {
            __weak typeof(self) weakSelfForNilRequest = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelfForNilRequest) self =
                    weakSelfForNilRequest;
                BOOL delivered = NO;
                @synchronized(callbackGate) {
                    delivered = callbackDelivered;
                }
                if (!self || delivered ||
                    generation != self.renderGeneration ||
                    !self.preparationActive) {
                    return;
                }
                [self failPreparationForGeneration:generation];
            });
        }
    }
}

- (void)beginOptionalVideoCoverWithURL:(NSString *)URLString
                            generation:(NSUInteger)generation {
    if (URLString.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    id<IFLYNativeFeedDemoImageRequest> request =
        [self.imageLoader
            loadImageWithURLString:URLString
                        completion:^(UIImage *image) {
        void (^applyCover)(void) = ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || generation != self.renderGeneration ||
                self.displayedMaterialType !=
                    IFLYNativeFeedAdMaterialTypeVideo) {
                return;
            }
            self.videoCoverImageView.image = image;
            if (self.isVideoCoverVisible) {
                self.videoCoverImageView.hidden = image == nil;
                self.videoPlaceholderLabel.hidden = image != nil;
            }
        };
        if (NSThread.isMainThread) {
            applyCover();
        } else {
            dispatch_async(dispatch_get_main_queue(), applyCover);
        }
    }];
    if (request) {
        [self.imageRequests addObject:request];
    }
}

- (void)beginOptionalAdSourceIconWithURL:(NSString *)URLString
                              generation:(NSUInteger)generation {
    if (URLString.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    id<IFLYNativeFeedDemoImageRequest> request =
        [self.imageLoader
            loadImageWithURLString:URLString
                        completion:^(UIImage *image) {
        void (^applyIcon)(void) = ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self || generation != self.renderGeneration ||
                !self.adData) {
                return;
            }
            if (image) {
                self.adSourceIconView.image = image;
                [self setNeedsLayout];
            }
        };
        if (NSThread.isMainThread) {
            applyIcon();
        } else {
            dispatch_async(dispatch_get_main_queue(), applyIcon);
        }
    }];
    if (request) {
        [self.imageRequests addObject:request];
    }
}

- (void)finishPreparationForGeneration:(NSUInteger)generation {
    if (generation != self.renderGeneration ||
        !self.preparationActive) {
        return;
    }
    self.preparationActive = NO;
    self.contentReady = YES;
    IFLYNativeFeedDemoPresentationReadyHandler handler =
        self.readyHandler;
    self.readyHandler = nil;
    if (handler) {
        handler(YES, nil);
    }
}

- (void)failPreparationForGeneration:(NSUInteger)generation {
    if (generation != self.renderGeneration ||
        !self.preparationActive) {
        return;
    }
    self.preparationActive = NO;
    self.contentReady = NO;
    self.pendingRequiredImageCount = 0;
    [self.imageRequests makeObjectsPerformSelector:@selector(cancel)];
    [self.imageRequests removeAllObjects];
    self.renderGeneration += 1;
    NSError *loadError =
        [self errorWithCode:
                  IFLYNativeFeedDemoPresentationViewErrorCodeImageLoadFailed
               description:@"自渲染开屏/插屏主图片加载失败"];
    IFLYNativeFeedDemoPresentationReadyHandler handler =
        self.readyHandler;
    self.readyHandler = nil;
    if (handler) {
        handler(NO, loadError);
    }
}

- (NSError *)errorWithCode:
    (IFLYNativeFeedDemoPresentationViewErrorCode)code
               description:(NSString *)description {
    return [NSError
        errorWithDomain:IFLYNativeFeedDemoPresentationViewErrorDomain
                   code:code
               userInfo:@{ NSLocalizedDescriptionKey : description }];
}

- (IFLYNativeFeedAdViewBinder *)makeViewBinder {
    if (!self.isContentReady || !self.adData) {
        return nil;
    }
    IFLYNativeFeedAdViewBinder *binder =
        [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView =
        self.presentationStyle ==
                IFLYNativeFeedDemoPresentationStyleSplash
            ? self
            : self.surfaceView;
    binder.titleView = nil;
    binder.descView = nil;
    binder.imageView = self.mediaView;
    binder.adSourceView = self.adSourceBadgeView;
    binder.ctaView = self.ctaButton;
    binder.closeView = self.closeView;
    binder.videoView =
        self.displayedMaterialType ==
                IFLYNativeFeedAdMaterialTypeVideo
            ? self.videoView
            : nil;

    NSMutableArray<UIView *> *renderViews =
        [NSMutableArray array];
    NSArray<UIView *> *candidateViews = @[
        self.mediaView,
        self.adSourceBadgeView,
        self.ctaButton,
        self.muteButton,
        self.noAdsButton,
        self.closeView,
    ];
    for (UIView *view in candidateViews) {
        if (!view.hidden) {
            [renderViews addObject:view];
        }
    }
    binder.renderViews = renderViews.copy;
    if (self.adData.interactionType ==
            IFLYNativeFeedAdInteractionTypeRedirect ||
        self.adData.interactionType ==
            IFLYNativeFeedAdInteractionTypeDownload) {
        binder.clickViews = @[ self.mediaView, self.ctaButton ];
    } else {
        binder.clickViews = @[];
    }
    return binder;
}

- (void)updateSplashCountdown:(NSUInteger)seconds {
    if (self.presentationStyle !=
        IFLYNativeFeedDemoPresentationStyleSplash) {
        return;
    }
    NSString *title =
        seconds > 0
            ? [NSString stringWithFormat:@"跳过 %lu",
                                         (unsigned long)seconds]
            : @"跳过";
    [self.closeButton setTitle:title
                     forState:UIControlStateNormal];
}

- (void)handleMuteButtonTap {
    [self syncMuted:!self.isMuted];
    if (self.muteToggleHandler) {
        self.muteToggleHandler(self.isMuted);
    }
}

- (void)syncMuted:(BOOL)muted {
    self.muted = muted;
    self.muteButton.selected = !muted;
    self.muteButton.accessibilityLabel =
        muted ? @"打开声音" : @"关闭声音";
}

- (void)handleNoAdsButtonTap {
    if (self.noAdsHandler) {
        self.noAdsHandler();
    }
}

- (void)showVideoCover {
    if (self.displayedMaterialType !=
        IFLYNativeFeedAdMaterialTypeVideo) {
        return;
    }
    self.videoCoverVisible = YES;
    self.videoCoverView.hidden = NO;
    BOOL hasCover = self.videoCoverImageView.image != nil;
    self.videoCoverImageView.hidden = !hasCover;
    self.videoPlaceholderLabel.hidden = hasCover;
}

- (void)hideVideoCover {
    self.videoCoverVisible = NO;
    self.videoCoverView.hidden = YES;
}

- (void)reset {
    self.renderGeneration += 1;
    [self.imageRequests makeObjectsPerformSelector:@selector(cancel)];
    [self.imageRequests removeAllObjects];
    self.readyHandler = nil;
    self.preparationActive = NO;
    self.pendingRequiredImageCount = 0;
    self.adData = nil;
    self.displayedMaterialType =
        IFLYNativeFeedAdMaterialTypeUnknown;
    self.displayedImageCount = 0;
    self.contentReady = NO;
    self.videoCoverVisible = NO;
    self.materialSize = CGSizeZero;
    self.headingInteractionEnabled = NO;
    self.usesTallSplashCTA = NO;
    self.badgeReservesIconSpace = NO;

    self.singleImageView.image = nil;
    self.singleImageView.hidden = YES;
    for (UIImageView *imageView in self.multipleImageViews) {
        imageView.image = nil;
        imageView.hidden = NO;
    }
    self.multipleImageContainer.hidden = YES;
    self.videoCoverImageView.image = nil;
    self.videoCoverImageView.hidden = YES;
    self.videoPlaceholderLabel.hidden = NO;
    self.videoCoverView.hidden = YES;
    self.videoView.hidden = YES;

    self.adSourceBadgeView.hidden = YES;
    self.adSourceIconView.image = nil;
    self.adSourceIconView.hidden = YES;
    self.adSourceLabel.text = @"广告";
    self.titleLabel.text = nil;
    self.descLabel.text = nil;
    self.interactionHintLabel.text = nil;
    self.ctaTitleLabel.text = nil;
    self.ctaTitleLabel.attributedText = nil;
    self.ctaSubtitleLabel.text = nil;
    self.ctaIconView.image = nil;
    self.interactionGIFView.image = nil;
    self.interactionGIFView.hidden = YES;
    self.ctaButton.hidden = YES;
    self.muteButton.hidden = YES;
    [self syncMuted:YES];
    self.noAdsButton.hidden =
        self.presentationStyle !=
        IFLYNativeFeedDemoPresentationStyleSplash;
    [self.closeButton
        setTitle:(self.presentationStyle ==
                          IFLYNativeFeedDemoPresentationStyleSplash
                      ? @"跳过"
                      : nil)
        forState:UIControlStateNormal];
    self.closeButton.hidden = NO;

    [self applyTemplateAppearance];
    [self setNeedsLayout];
}

@end
