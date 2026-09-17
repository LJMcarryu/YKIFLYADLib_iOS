# 优酷定制 IFLYADLib iOS SDK

优酷定制版是面向 iOS 应用的静态广告 SDK，提供开屏、插屏和自渲染信息流。三种格式均支持图片或视频素材；Banner 和激励视频不在本产物中。

## 版本与阅读入口

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.3.5","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5"} -->

## 6.3.6 候选联调说明

`6.3.6` 目前是待联调候选，尚未发布。当前公开正式版和生产依赖仍为 [`6.3.5`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5)；已发布的 Tag、Release 和资产不追溯改变。

- 公开 API 方法签名不变。
- 共享 UIScene 适配将展示、落地页、外跳回流、曝光判断和 UI 生命周期绑定到广告的实际来源 window/Scene。没有来源时，仅在前台应用 Scene 唯一且明确时兜底，不跨 Scene 随机选择；独立落地页始终属于来源 Scene。
- 开屏的 rootVC 仍须已经入窗。在 Scene 宿主中使用 `customWindow` 时，窗口必须可见、尺寸有限且为正、已经关联 Scene，并与 `rootVC.window` 属于同一 Scene；它可以不是 key window，可以使用较高 `windowLevel`，也可以不设置 rootVC。输入无效时展示失败，修正窗口后可重试。

当前正式版本：[6.3.5](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5)。生产项目请固定具体版本；版本变化见 [CHANGELOG](CHANGELOG.md)。本文适用于优酷定制版，API 以所安装版本的 framework 公开头为准。

- 首次接入：依次完成[安装](#安装)、[隐私与请求配置](#初始化隐私和请求配置)，再选择下方广告形式。
- 运行示例：[Simple 运行与操作指南](IFLYADLibSimple/README.md)，包含广告位配置、隐私流程、页面操作和排错步骤。
- 自建广告 UI：[自渲染信息流](#自渲染信息流)；优酷媒体交互见[媒体摇一摇](#优酷媒体摇一摇)。
- 联调失败：[错误处理与生命周期](#错误处理与生命周期)和[常见问题](#常见问题)。

## 能力矩阵

| 能力 | 入口类 | 渲染方式 |
| --- | --- | --- |
| 开屏 | `IFLYSplashAd` | SDK 内置渲染，支持图片和视频 |
| 插屏 | `IFLYInterstitialAd` | SDK 内置渲染，支持半屏/全屏、图片和视频 |
| 自渲染信息流 | `IFLYNativeFeedAd` | 媒体渲染 UI，SDK 管理交互和视频 |
| Banner | — | 本包不提供 |
| 激励视频 | — | 本包不提供 |

## 命名、资源和环境要求

优酷版的 Pod 名称是 `YKIFLYADLib`，但 SDK module、公开类和方法仍使用标准 `IFLY*` 命名：

```objc
#import <IFLYADLib/IFLYADLib.h>
```

| 项目 | 要求 |
| --- | --- |
| 系统 | iOS 11.0 及以上 |
| 开发环境 | 支持 XCFramework 的 Xcode；SwiftPM 接入需支持 Swift tools 5.9 的 Xcode |
| CocoaPods 名称 | `YKIFLYADLib` |
| SwiftPM 产品 / 导入模块 | `IFLYADLib` |
| 资源包 | `IFLYPlayer.bundle` |
| 链接方式 | 静态链接；最终 App 必须包含 `-ObjC`，framework 选择 **Do Not Embed** |

本仓库的 Simple 使用 Objective-C；Swift 工程可通过 `import IFLYADLib` 使用公开 API。

优酷版与标准 `IFLYADLib` 包含相同的公开符号，不要在同一个 App 中同时集成两者。

## 安装

### CocoaPods

以下使用固定版本的公开 Podspec URL 安装。请保留完整 URL；仅填写 Pod 名称和版本不保证能够从 CocoaPods 公共索引获取该定制包。

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

选择依赖规则 **Exact Version**，版本填 `6.3.5` 和产品 `IFLYADLib`。SwiftPM 会自动投递资源；在 App target 的 `Other Linker Flags` 添加：

```text
-ObjC
```

### 手动集成

从 [Release 6.3.5](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.5) 下载 `YKIFLYADLib-6.3.5.zip`：

1. 将 `IFLYADLib.xcframework` 加入 App target，Embed 选择 **Do Not Embed**。
2. 将 `IFLYPlayer.bundle` 加入 **Copy Bundle Resources**。
3. 在 App target 的 `Other Linker Flags` 添加 `-ObjC`。
4. 在 **Link Binary With Libraries** 中添加 `AdSupport.framework`，将 `AppTrackingTransparency.framework` 设置为 **Optional**，以兼容 iOS 11～13。
5. 导入 `<IFLYADLib/IFLYADLib.h>`。确认工程只引用一份 SDK 及对应资源，不要混用不同版本的 framework 和 bundle。

## 初始化、隐私和请求配置

先在广告平台取得当前应用、优酷渠道及相应形式的广告位 ID，并确认 Bundle ID 等应用信息已经配置。示例广告位只用于联调，正式接入须换成分配给自己应用的广告位。

SDK 无需单独创建全局实例。宿主完成自己的隐私告知、取得相应同意后，再进行配置和广告请求：

```objc
#import <IFLYADLib/IFLYADLib.h>

// 在宿主完成隐私流程后调用；值应来自用户的实际选择。
- (void)configureAdvertisingWithPersonalizedEnabled:(BOOL)enabled {
    [IFLYAdConfig setPersonalizedEnabled:enabled];
    [IFLYAdConfig setLogEnabled:NO];
}
```

`setPersonalizedEnabled:` 只记录状态，不改变 IDFA、CAID、UA 等请求字段，也不改变填充、点击或监测行为。它不替代隐私同意、ATT 或宿主的数据处理控制。需要限制采集或传参时，宿主仍须执行对应业务逻辑。

iOS 14 及以上如需使用 IDFA，先在 App 的 `Info.plist` 中设置符合实际用途的说明，再由宿主在适当时机申请 ATT：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

只有 ATT 为 `authorized` 时才读取或传入 IDFA。未授权时不要伪造标识符；授权完成后重新读取并用于后续请求，不复用授权前的配置。Simple 演示了此流程，见 [AppDelegate.m](IFLYADLibSimple/IFLYADLibSimple/AppDelegate.m) 和 [IFLYADUtil.m](IFLYADLibSimple/IFLYADLibSimple/Supporting%20Files/IFLYADUtil.m)。宿主应结合[SDK 隐私政策](https://aimarx.com/help-center/sdk-privacy-policy)完成自己的隐私告知和 App Store Connect 隐私申报。

三种广告都支持 `IFLYAdRequestConfig`：

```objc
- (IFLYAdRequestConfig *)requestConfig {
    IFLYAdRequestConfig *config = [[IFLYAdRequestConfig alloc] init];
    config.requestTimeout = @5;
    config.appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"]
        ?: NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
    config.appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    config.settleType = @1;  // 0=固定价格，1=RTB
    config.bidFloor = @0.01;
    config.interactStatus = @1;
    return config;
}
```

请求配置与展示配置分别传入。`requestConfig` 是本文示例的宿主辅助方法，可按应用实际情况调整：

| 字段 | 用途 |
| --- | --- |
| `requestTimeout` | 请求超时，单位秒；示例使用 5 秒 |
| `appName` / `appVersion` | 当前宿主的名称与版本 |
| `settleType` / `bidFloor` / `pmpDeals` | 平台约定的交易类型、底价和 PMP 配置，不应直接照搬示例到生产 |
| `idfa` / `caidList` / `userAgent` | 按实际授权和平台要求提供，不填写虚构值 |
| `deepLinkDisabled` | `YES` 时禁用 DeepLink，使用落地页；不会修改请求参数 |

配置中的其他可选字段见 `IFLYAdRequestConfig` 公开头。广告对象可调用 `loadAd`，或在需要设置请求参数时调用：

```objc
[ad loadAdWithRequestConfig:[self requestConfig]];
```

点击、DeepLink、落地页和失败回退由 SDK 统一处理；历史 `jumpDirectly` 字段仅为兼容保留，不应用来控制业务跳转。

## 开屏广告

开屏广告由 SDK 展示到宿主 window。先持有广告实例、设置代理并加载；收到 `splashAdDidReady:` 后，在宿主页面已进入 window 且可展示时调用展示接口：

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
    if (ad != self.splashAd || !ad.isAdValid || !self.view.window) return;
    IFLYSplashAdConfig *config = [[IFLYSplashAdConfig alloc] init];
    config.traceDuration = 5;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)splashAd:(IFLYSplashAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Splash failed: %d %@", error.errorCode, error.errorDescription);
}
```

`splashAdDidLoad:` 只表示广告数据已返回；等待 `splashAdDidReady:` 才能展示。`traceDuration` 支持 3～5 秒，默认 5 秒；自定义底部 Logo 可设置 `mediumBottomView`。若就绪时页面尚不可展示，应保存就绪状态，在合适时机再次检查 `isAdValid`，不要忽略后永久等待。

通过 `splashAdDidShow:`、`splashAdDidExpose:`、`splashAdDidClick:`、`splashAdDidSkip:`、`splashAdDidClose:` 处理界面状态。点击或离开 App 不等于广告关闭，应结合关闭及落地页返回回调处理。展示完成或放弃本次展示后，清理实例；下次重新创建。

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
    if (ad != self.interstitialAd || !ad.isAdValid || !self.view.window) return;
    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)interstitialAd:(IFLYInterstitialAd *)ad didFailWithError:(IFLYAdError *)error {
    NSLog(@"Interstitial failed: %d %@", error.errorCode, error.errorDescription);
}
```

可选 `IFLYInterstitialPresentationStyleHalfScreen` 或 `IFLYInterstitialPresentationStyleFullScreen`。素材横竖方向由返回素材决定，半屏/全屏由展示配置决定。请在当前页面可呈现时展示，避免与其他模态页面同时弹出；如果就绪回调到达时暂不可展示，可在后续业务时机重新检查 `isAdValid`。

`interstitialAdDidLoad:` 表示数据返回，`interstitialAdDidReady:` 表示素材准备完成。展示后关注 `interstitialAdDidShow:`、`interstitialAdDidRender:`、`interstitialAdDidExpose:` 和 `interstitialAdDidClose:`；渲染错误另有 `didFailToRenderWithError:`，视频错误另有 `didFailToPlayWithError:`。插屏实例为一次性使用，展示或关闭后再次加载须创建新实例。

## 自渲染信息流

NativeFeed 由宿主根据 `ad.adData` 渲染标题、图片、广告标识、CTA 和关闭按钮。SDK 负责绑定后的曝光、点击、跳转及视频播放。它没有 `didReady` 回调，也不会替宿主下载并显示图片。

接入步骤：创建并持有 Ad → `loadAdWithRequestConfig:` → 收到 `nativeFeedAdDidLoad:` → 准备视图和图片 → 在主线程调用 `attachWithViewBinder:error:`。可直接参考 [列表示例](IFLYADLibSimple/IFLYADLibSimple/biz/native/IFLYNativeViewController.m) 和[视觉示例](IFLYADLibSimple/IFLYADLibSimple/biz/native/presentation/IFLYNativeFeedPresentationDemoViewController.m)。

下面的绑定方法适用于已完成布局的单个广告卡片；传入的图片/视频承载视图、CTA 和关闭按钮须先加入 `container`，宿主持有这些视图：

```objc
- (BOOL)attachAd:(IFLYNativeFeedAd *)ad
      container:(UIView *)container
      mediaView:(UIView *)mediaView
        ctaView:(UIView *)ctaView
      closeView:(UIView *)closeView {
    IFLYNativeFeedAdData *data = ad.adData;
    if (!data.isMaterialComplete) return NO;

    BOOL clickable = data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect
        || data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = container;
    binder.renderViews = @[mediaView, ctaView, closeView];
    binder.clickViews = clickable ? @[mediaView, ctaView] : @[];
    binder.closeView = closeView;
    binder.videoView = data.materialType == IFLYNativeFeedAdMaterialTypeVideo
        ? mediaView : nil;

    IFLYAdError *error = nil;
    BOOL attached = [ad attachWithViewBinder:binder error:&error];
    if (!attached) {
        NSLog(@"NativeFeed attach failed: %d %@", error.errorCode, error.errorDescription);
    } else if (ad.hasVideoTemplate) {
        [ad startPlay];
    }
    return attached;
}
```

创建时设置 `delegate`、`currentViewController` 和所需的 `muteOnStart`，并像开屏、插屏示例一样强引用广告对象。以上方法的视图参数均须非空；视频的 `mediaView` 使用普通 `UIView`，不要创建自己的 `AVPlayer`。`startPlay` 提出播放请求，实际起播仍须满足已绑定、已曝光等条件。可以通过 `pausePlay`、`resumePlay`、`stopPlay` 控制播放，通过对应回调更新封面与按钮。

### 素材、曝光与点击

| 接入内容 | 使用规则 |
| --- | --- |
| 单图 / 多图 | 按 `materialType` 和 `imageURLs` 渲染；图片由宿主下载，并处理失败和 Cell 复用时的旧图片回调 |
| 视频 | 使用 `videoView` 承载 SDK 播放，`videoCoverURL` 是可选封面；缺少封面不等于视频不可用 |
| 文案 | 读取 `title`、`desc`、`content`、`ctaText`、`brand`、`appName`，允许非必填文案为空 |
| 广告标识 | 宿主展示清晰的广告标识，可使用 `adSourceMark`、`adSourceIconURL` |
| 点击 | `Redirect` / `Download` 注册实际 CTA；`Exposure` / `Unknown` 显式传空 `clickViews`，不应自行兜底成可跳转 |
| 关闭 | 将关闭按钮传给 `closeView`，避免关闭操作被当成广告点击；收到关闭回调后移除该条目 |
| 曝光 | 前台活跃、未锁屏且容器至少 2/3 可见并连续保持 500ms 后触发；绑定成功不等于曝光 |

自然曝光前滚出再回来需要重新累计连续可见时间；同一广告已经曝光后，正常离屏再回屏不重复曝光。曝光回调表示 SDK 已执行对应处理，不应视为服务端统计入库凭证。

点击、DeepLink 和落地页由 SDK 处理。宿主不要依据 `targetURL`、`deeplinkURL` 等字段另行打开页面或补报点击。是否跳转成功以 `nativeFeedAd:didJumpWithSuccess:` 为准；不存在 `nativeFeedAdDidJump:` 回调。

### 容器外 CTA

默认 `clickViews` 应位于广告容器内。确有布局需要时，设置 `binder.allowsExternalClickViews = YES`。外部 CTA 可以在绑定后再挂载、布局，但点击时必须与广告位于同一 window/scene，自身可见、可交互、具有有效尺寸，广告容器在前台至少 2/3 可见。不要传 `UIWindow`、控制器页面根视图或把无关页面区域注册成广告热区；同一个外部 CTA 不应同时交给多个广告。

`renderViews`、`closeView`、`videoView` 仍须属于广告容器。更换点击视图或改变其容器内外关系时，先 detach，再重新 attach。普通子视图的点击可由注册的父级 CTA 处理；带有宿主按钮事件或自有手势的子视图优先执行宿主交互。显式注册为 CTA 的按钮本身由 SDK 处理，关闭按钮及子视图与广告点击分离。

绑定阶段失败由 `attachWithViewBinder:error:` 返回 `NO` 并回调 `didFailToRenderWithError:`；已绑定后的点击被拒绝，由 `nativeFeedAd:didRejectClickWithError:` 返回 `71503`。错误描述格式为 `[71503/<point>] 中文原因与处理提示`。记录错误并修正布局或绑定关系，不要在拒绝后自行补跳转。

### 列表复用与释放

1. 列表数据层按稳定条目持有 `IFLYNativeFeedAd`；Cell 负责当前 UI。
2. `willDisplay` 中根据原 Ad 的 `adData` 渲染并 attach，正常离屏不重新请求。
3. `didEndDisplaying`、`prepareForReuse` 或切换为普通内容时，立即对该回调 Cell 的容器调用 `+[IFLYNativeFeedAd detachAdFromContainerView:]`。不要按旧 `indexPath` 反查，也不要延迟解绑。
4. 条目仍存在且广告有效时，回屏可继续 attach 原 Ad；视频可恢复原进度。手动暂停或停止后，需要再次 `resumePlay` / `startPlay` 才申请播放。
5. 广告关闭、条目永久删除或页面退出时，detach 已知容器、置空 delegate 和 `currentViewController`，释放最后一个 Ad 强引用。需要立即终止但仍保留对象引用时才主动调用 `destroy`。

`detachFromCurrentContainer` 仅用于固定、非复用且不会迁移的单容器。已过期广告不能迁移或重新挂载，收到过期错误后创建新 Ad。完整列表实现见 [Simple](IFLYADLibSimple/README.md#自渲染信息流示例)。

### 优酷媒体摇一摇

优酷版额外提供媒体侧摇一摇上报接口。它只上报媒体已经识别到的摇一摇事件，不会替代普通点击：

```objc
IFLYAdError *error = nil;
BOOL accepted = [ad reportMediaShakeTriggeredWithError:&error];
if (!accepted) {
    NSLog(@"Shake report failed: %d %@", error.errorCode, error.errorDescription);
}
```

只能在主线程、广告已自然曝光且当前活动挂载有效可见时调用，不以服务端 `interact`、`interactionType`、素材类型或跳转目标为准入条件。SDK 在可见期间被动采样，媒体调用是该模式唯一的摇一摇点击触发源；同一已加载广告最多接受一次，离屏再回屏不会重置；普通点击已进入点击链路后不能再次上报。返回 `YES` 表示进入点击处理，不保证取得加速度样本或跳转成功。

## S2S 和 Header Bidding

仅在广告平台已为应用开通并明确竞价流程时使用。普通广告请求直接调用 `loadAd` 或 `loadAdWithRequestConfig:`。

```objc
NSError *error = nil;
NSString *sdkToken = [IFLYAdSDK getSdkTokenWithAdUnitId:@"YOUR_AD_UNIT_ID" error:&error];
if (sdkToken.length == 0) {
    NSLog(@"SDK token failed: %@", error.localizedDescription);
    return;
}
// 将 sdkToken 交给宿主服务端；取得平台返回的 rspToken 后，交给对应广告实例加载：
// [ad loadAdWithServerBiddingToken:rspToken];
```

`sdkToken` 与 `rspToken` 不是同一个值。响应 token 应按平台协议使用，不要重复消费过期、已使用或未竞胜的 token；失败由广告代理返回。S2S 成功加载后的 `bidInfo.price` 固定为 `0`，不要将其当成服务端成交价。

普通客户端竞价加载成功后，可读取 `ad.bidInfo.price`（单位元）和 `ad.bidInfo.dealId`；缺失时按平台约定处理。实际竞价结果确定后，再调用 `sendBidResultWithType:reason:` 发送相应通知，不应因为素材就绪就自动通知胜出。

## 错误处理与生命周期

广告回调在主线程执行。持有广告实例和代理，所有 UI 操作在主线程完成；异步图片回调须确认仍属于当前广告和当前 Cell。

| 阶段 | 回调 / 返回值 | 处理建议 |
| --- | --- | --- |
| 请求 | `didFailWithError:` | 记录 `errorCode` 和 `errorDescription`，按业务策略结束或有限重试 |
| 内置素材就绪 | `splashAdDidReady:` / `interstitialAdDidReady:` | 检查 `isAdValid` 及页面状态后展示 |
| NativeFeed 数据返回 | `nativeFeedAdDidLoad:` | 准备宿主 UI，再 attach；不等同于素材已显示 |
| NativeFeed 绑定 | attach 返回值与 `didFailToRenderWithError:` | 两者可能描述同一次失败，避免重复弹窗或重复重试 |
| 点击拒绝 | `nativeFeedAd:didRejectClickWithError:` | 按 `71503` 描述修正视图，禁止绕过 SDK 补报或跳转 |
| 跳转结果 | 对应 `didJumpWithSuccess:` | 与点击事件分开记录；失败不等于加载失败 |
| 广告关闭 | 对应 `AdDidClose:` | 移除展示内容并清理引用；落地页返回回调不等于广告关闭 |

常见错误可先按下表处理，完整枚举见所安装 SDK 的 `IFLYAdError.h`：

| 错误码 | 含义与排查方向 |
| --- | --- |
| `70204` | 无广告填充；确认广告位投放、测试应用和设备条件，保留内容页继续使用 |
| `70400` / `71005` | 广告位无效 / 为空；检查渠道、形式和配置值 |
| `71003` / `71006` | 网络错误 / 请求超时；检查连接和请求耗时，避免无限重试 |
| `70401` / `70404` | S2S token 为空或无效；检查服务端返回及使用时机 |
| `71406` / `71603` | 插屏 / 开屏未就绪；等待对应 `didReady` |
| `71410` / `71604` | 展示控制器不可用；确认页面已进入 window 且可呈现 |
| `71502` / `71504` | NativeFeed 容器 / 视频承载视图无效；检查层级、尺寸和视图类型 |
| `71503` | 点击视图无效；保留 `<point>` 与中文提示定位 |
| `71506`～`71508` | NativeFeed 已过期、已关闭或已销毁；创建新实例 |
| `71513`～`71515` | 摇一摇未满足可见条件、已处理点击或调用线程错误 |

页面永久退出或放弃开屏/插屏展示时，先置空 delegate，再 `destroy` 并释放强引用。不要在普通 `viewDidDisappear:` 中无条件销毁：它也可能由广告、落地页或其他页面暂时覆盖触发。已 `destroy` 的实例不再用于新请求。NativeFeed 列表正常离屏按上面的容器解绑流程处理。

## 示例工程

[IFLYADLibSimple](IFLYADLibSimple/README.md) 包含自渲染开屏、自渲染插屏和信息流列表三个入口，全部使用 `IFLYNativeFeedAd`。开屏/插屏入口演示宿主自建页面和布局；SDK 内置 `IFLYSplashAd`、`IFLYInterstitialAd` 的接入见本文对应章节。

```bash
git clone https://github.com/LJMcarryu/YKIFLYADLib_iOS.git
cd YKIFLYADLib_iOS/IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

当前 Simple 的 Podfile 固定 SDK `6.3.5`。选择 `IFLYADLibSimple` scheme 和运行设备，真机运行时设置自己的 Team / Bundle ID，并配置适用广告位。完整操作、预期回调、首次隐私流程及命令行构建见 [Simple 指南](IFLYADLibSimple/README.md)。

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

排错时可临时调用 `[IFLYAdConfig setLogEnabled:YES]`，查看 Xcode Console。发布包仅输出错误和诊断日志，打开开关也不会恢复完整请求/响应日志；不应依靠日志输出量判断请求是否成功。

请在 [Issues](https://github.com/LJMcarryu/YKIFLYADLib_iOS/issues) 提交问题，并附 SDK 版本、iOS/Xcode 版本、接入方式、设备型号、广告形式、复现步骤和完整错误码。提交前移除 IDFA、token、用户信息、完整请求/响应和带参数的监测 URL；广告位及其他联调信息通过双方约定的支持渠道提供。版本变更见 [CHANGELOG](CHANGELOG.md)。
