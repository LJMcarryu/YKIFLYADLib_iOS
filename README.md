# 优酷定制 IFLYADLib iOS SDK

优酷 SDK 版本目标：6.3.5。

优酷定制版是面向 iOS 应用的静态广告 SDK，提供开屏、插屏和自渲染信息流。三种格式均支持图片或视频素材；Banner 和激励视频不在本产物中。

## 6.3.5 冻结与发布记录

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.3.5","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5"} -->

当前正式版本：[`6.3.5`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5)。实际发布状态、时间和消费验证结果以版本匹配的 `release-state.json.publication` 与该 Release 为准。

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`5958c2bce742a715a3725462b8694f0b2d377760`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`b8dfe3e1c60f52d7e605b3d4c9a9d57494beb2b9`

`releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结。正式发布状态、时间和消费验证结果以版本匹配的 `release-state.json.publication` 及 [Release 6.3.5](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5) 为准。`artifactCandidateId` 为 `b50d00ecb38e4037147fe665b07434a2c350a85b7334a0f68aab976858f4dfea`。Apple Review 为 `not-run`；CocoaPods trunk 为 `not-in-scope`。

`IFLYADLib.xcframework.zip` 的 SwiftPM checksum/SHA-256 为 `6a9d77527f1e46674d489d899fba27d8c68ebbf1a9b8ff1b2a5227f803ab3f09`；`YKIFLYADLib-6.3.5.zip` 的 SHA-256 为 `28d48f2ad7e691bcf0527b0e607f8f62f3fc69a9ca8412fa10df0ecc301bb158`。

## 6.3.3 已发布版本

历史正式版本：[`6.3.3`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.3)。生产项目请固定到具体版本，不要依赖 `main` 分支。

## 能力矩阵

| 能力 | 入口类 | 渲染方式 |
| --- | --- | --- |
| 开屏 | `IFLYSplashAd` | SDK 内置渲染，支持图片和视频 |
| 插屏 | `IFLYInterstitialAd` | SDK 内置渲染，支持半屏/全屏、图片和视频 |
| 自渲染信息流 | `IFLYNativeFeedAd` | 媒体渲染 UI，SDK 管理交互和视频 |
| Banner | — | 本变体不提供 |
| 激励视频 | — | 本变体不提供 |

## 命名、资源和环境要求

优酷版的 Pod 名称是 `YKIFLYADLib`，但 SDK module、公开类和方法仍使用标准 `IFLY*` 命名：

```objc
#import <IFLYADLib/IFLYADLib.h>
```

资源包为 `IFLYPlayer.bundle`。SDK 支持 iOS 11.0 及以上，使用静态 XCFramework；最终 App 必须链接 `-ObjC`，不需要 Embed & Sign。

优酷版与标准 `IFLYADLib` 包含相同的公开符号，不要在同一个 App 中同时集成两者。

## 安装

### CocoaPods

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!
  pod 'YKIFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/YKIFLYADLib_iOS/6.3.5/YKIFLYADLib.podspec'
end
```

```bash
pod install
open YourApp.xcworkspace
```

CocoaPods 会自动投递 `IFLYPlayer.bundle` 并传播 `-ObjC`。

### Swift Package Manager

在 Xcode 中添加：

```text
https://github.com/LJMcarryu/YKIFLYADLib_iOS.git
```

选择版本 `6.3.5` 和产品 `IFLYADLib`。SwiftPM 会自动投递资源；在 App target 的 `Other Linker Flags` 添加：

```text
-ObjC
```

### 手动集成

从 [Release 6.3.5](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5) 下载 `YKIFLYADLib-6.3.5.zip`：

1. 将 `IFLYADLib.xcframework` 加入 App target，Embed 选择 **Do Not Embed**。
2. 将 `IFLYPlayer.bundle` 加入 **Copy Bundle Resources**。
3. 在 App target 的 `Other Linker Flags` 添加 `-ObjC`。
4. 导入 `<IFLYADLib/IFLYADLib.h>`。

## 初始化、隐私和请求配置

```objc
#import <IFLYADLib/IFLYADLib.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IFLYAdConfig setPersonalizedEnabled:YES];
    [IFLYAdConfig setLogEnabled:NO];
    return YES;
}
```

`setPersonalizedEnabled:` 只记录媒体侧个性化状态，不代替 ATT，也不会自行修改请求、填充或点击行为。正式上线建议关闭日志。

iOS 14 及以上如需使用 IDFA，请配置：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

只有 ATT `authorized` 时才读取或传入 IDFA；授权完成后请重新读取。宿主仍须在 App Store Connect 隐私标签中如实申报 SDK 实际数据处理。

三种广告都支持 `IFLYAdRequestConfig`：

```objc
- (IFLYAdRequestConfig *)requestConfig {
    IFLYAdRequestConfig *config = [[IFLYAdRequestConfig alloc] init];
    config.requestTimeout = @5;
    config.appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    config.appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    config.settleType = @1;  // 0=固定价格，1=RTB
    config.bidFloor = @0.01;
    config.interactStatus = @1;
    return config;
}
```

常用字段包括 `requestId`、`requestTimeout`、`appName`、`appVersion`、`userAgent`、`idfa`、`caidList`、`settleType`、`bidFloor`、`pmpDeals` 和 `deepLinkDisabled`。广告对象可调用 `loadAd` 或：

```objc
[ad loadAdWithRequestConfig:[self requestConfig]];
```

点击、DeepLink、落地页和失败回退由 SDK 统一处理；历史 `jumpDirectly` 字段仅为兼容保留，不应用来控制业务跳转。

## 开屏广告

开屏广告挂载到 window，不使用 `presentViewController:`；应在 `splashAdDidReady:` 后展示：

```objc
@interface SplashViewController () <IFLYSplashAdDelegate>
@property (nonatomic, strong) IFLYSplashAd *splashAd;
@end

- (void)loadSplash {
    IFLYSplashAd *ad = [[IFLYSplashAd alloc] initWithAdUnitId:@"YOUR_SPLASH_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.splashAd = ad;
    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)splashAdDidReady:(IFLYSplashAd *)ad {
    if (ad != self.splashAd || !ad.isAdValid) return;
    IFLYSplashAdConfig *config = [[IFLYSplashAdConfig alloc] init];
    config.traceDuration = 5;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Splash failed: %d %@", error.errorCode, error.errorDescription);
}
```

常用回调包括 `splashAdDidLoad:`、`splashAdDidReady:`、`splashAdDidShow:`、`splashAdDidExpose:`、`splashAdDidClick:`、`splashAdDidClose:`、`splashAdDidSkip:` 和失败回调。

## 插屏广告

```objc
@interface InterstitialViewController () <IFLYInterstitialAdDelegate>
@property (nonatomic, strong) IFLYInterstitialAd *interstitialAd;
@end

- (void)loadInterstitial {
    IFLYInterstitialAd *ad = [[IFLYInterstitialAd alloc] initWithAdUnitId:@"YOUR_INTERSTITIAL_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.interstitialAd = ad;
    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)interstitialAdDidReady:(IFLYInterstitialAd *)ad {
    if (ad != self.interstitialAd || !ad.isAdValid) return;
    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Interstitial failed: %d %@", error.errorCode, error.errorDescription);
}
```

可选 `IFLYInterstitialPresentationStyleHalfScreen` 或 `IFLYInterstitialPresentationStyleFullScreen`。展示或关闭后请重新创建实例。

## 自渲染信息流

NativeFeed 由媒体根据 `ad.adData` 渲染 UI，SDK 负责曝光、点击、跳转、关闭、监测和视频播放器。加载成功后在主线程同步调用 `attachWithViewBinder:error:`：

```objc
@interface NativeFeedViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *nativeAd;
@property (nonatomic, strong) UIView *adContainer;
@end

- (void)loadNativeFeed {
    IFLYNativeFeedAd *ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:@"YOUR_NATIVE_FEED_AD_UNIT_ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.nativeAd = ad;
    [ad loadAdWithRequestConfig:[self requestConfig]];
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    if (ad != self.nativeAd || !ad.adData.isMaterialComplete) return;

    // 先根据 ad.adData 渲染标题、品牌、图片/视频和 CTA。
    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.adContainer;
    binder.renderViews = @[/* 媒体实际渲染的视图 */];
    binder.clickViews = @[/* Redirect/Download 点击视图；Exposure/Unknown 传 @[] */];
    binder.videoView = /* 视频素材使用普通 UIView；非视频传 nil */ nil;

    IFLYAdError *error = nil;
    if (![ad attachWithViewBinder:binder error:&error]) {
        NSLog(@"NativeFeed attach failed: %d %@", error.errorCode, error.errorDescription);
    }
}

- (void)leaveScreen {
    [IFLYNativeFeedAd detachAdFromContainerView:self.adContainer];
}
```

接入规则：

- `containerView` 必填；视频素材必须提供普通 `UIView` 作为 `videoView`；不要自行创建 `AVPlayer`。
- `interactionType` 为 `Exposure` 或 `Unknown` 时，`clickViews` 传 `@[]`；为 `Redirect` 或 `Download` 时只传实际点击视图。
- 如确需把 CTA 放在容器外，显式设置 `binder.allowsExternalClickViews = YES`，并保证 CTA 与广告处于同一 window/scene、可见且可交互。常规接入优先让 CTA 位于容器内。
- Cell 离屏、复用或切换普通内容时，对具体容器调用 `detachAdFromContainerView:`；不要按旧 `indexPath` 反查广告。
- 列表数据层持有 `IFLYNativeFeedAd`，Cell 只负责渲染和 attach/detach。条目暂时离屏可继续持有同一 Ad；永久删除或退出页面时 detach、置空 delegate 并释放 Ad。
- 绑定且曝光后可用 `startPlay`、`pausePlay`、`resumePlay`、`stopPlay` 控制 SDK 播放器。

公开 `adData` 字段包括：`materialType`、`templateId`、`title`、`desc`、`content`、`ctaText`、`brand`、`appName`、`icon`、`mainImage`、`imageList`、`imageURLs`、`videoURL`、`videoCoverURL`、`videoDuration`、`targetURL`、`deeplinkURL`、`marketURL`、`downloadURL`、`packageName`、`interactionType` 和 `interactType`。点击和跳转由 SDK 处理，媒体不要自行打开 URL。

NativeFeed 回调包括 `nativeFeedAdDidLoad:`、`nativeFeedAdDidRender:`、`nativeFeedAdDidExpose:`、`nativeFeedAdDidClick:`、`nativeFeedAdDidJump:`、`nativeFeedAdDidClose:`、`nativeFeedAd:didFailWithError:` 和 `nativeFeedAd:didFailToRenderWithError:`；视频素材还会触发播放状态回调。

### 优酷媒体摇一摇

优酷版额外提供媒体侧摇一摇上报接口。它只上报媒体已经识别到的摇一摇事件，不会替代普通点击：

```objc
IFLYAdError *error = nil;
BOOL accepted = [ad reportMediaShakeTriggeredWithError:&error];
if (!accepted) {
    NSLog(@"Shake report failed: %d %@", error.errorCode, error.errorDescription);
}
```

只有广告数据声明支持该互动时才调用；普通点击、跳转和奖励逻辑仍由 SDK 管理。

## S2S 和 Header Bidding

如平台已开通服务端竞价：

```objc
NSError *error = nil;
NSString *sdkToken = [IFLYAdSDK getSdkTokenWithAdUnitId:@"YOUR_AD_UNIT_ID" error:&error];
[ad loadAdWithServerBiddingToken:rspToken];
```

加载成功后读取公开竞价字段：

```objc
NSNumber *price = ad.bidInfo.price;
NSString *dealId = ad.bidInfo.dealId;
[ad sendBidResultWithType:IFLYAdBidResultTypeWin reason:@"win"];
```

Token 生命周期、通知时机和失败重试策略以平台协议为准；未开通时使用普通 `loadAd`。

## 错误处理与生命周期

- `*AdDidLoad:` 表示响应解析成功，素材可能仍在下载。
- `*AdDidReady:` 表示内置渲染主素材已就绪，可以展示。
- 展示前检查 `isAdValid`。
- 页面退出时置空 delegate、调用 `destroy` 并释放强引用；NativeFeed 列表正常离屏只需 detach。
- 所有失败通过对应 delegate 的 `didFailWithError:` 返回 `IFLYAdError`；无填充、网络错误、超时和素材不完整应按业务策略结束或重试，不要无限重试。

## 示例工程

`IFLYADLibSimple` 当前是 NativeFeed 自渲染示例，包含图片、视频和展示布局场景。示例页面中的开屏/插屏视觉场景用于演示媒体页面布局，不调用 SDK 内置 `IFLYSplashAd` 或 `IFLYInterstitialAd`；内置格式请按本文代码接入。

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

Demo 构建成功表示 6.3.5 包能够被 CocoaPods 正确消费和链接；它不等同于线上填充，也不替代内置开屏/插屏的运行验证。

## 常见问题

| 问题 | 处理方式 |
| --- | --- |
| 找不到 Banner 或 Reward 类 | 这两个能力不在优酷 6.3.5 产物中。 |
| 与标准版同时链接时报符号冲突 | 优酷版和标准版都使用 `IFLY*` 符号，同一 App 只能选择其中一个。 |
| `-ObjC` 缺失 | 在最终 App target 的 `Other Linker Flags` 添加 `-ObjC`。 |
| NativeFeed 绑定失败 | 确认主线程调用、容器非空、视频传入 `videoView`，并让点击视图与 `interactionType` 匹配。 |
| IDFA 为空 | 检查 ATT 授权和 `NSUserTrackingUsageDescription`；授权完成后重新读取。 |
| 资源缺失 | 确认 `IFLYPlayer.bundle` 已由 CocoaPods/SwiftPM 投递，或已在手动集成时加入 Copy Bundle Resources。 |

## 反馈与支持

请在 [Issues](https://github.com/LJMcarryu/YKIFLYADLib_iOS/issues) 提交问题，并附 SDK 版本、iOS/Xcode 版本、接入方式、复现步骤和错误回调。版本变更见 [`CHANGELOG.md`](./CHANGELOG.md)。
