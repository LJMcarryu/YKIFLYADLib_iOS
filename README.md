# 优酷定制 IFLYADLib iOS SDK

本仓库是优酷媒体定制版的二进制分发仓，仅提供以下三种广告能力：

- 开屏广告 `IFLYSplashAd`
- 插屏广告 `IFLYInterstitialAd`
- 自渲染信息流 `IFLYNativeFeedAd`

图片和视频素材均受支持。Banner、激励视频不在本产物中，对应公开头、实现符号和专属资源已物理裁剪。

定制版保持标准 SDK 的模块名、类前缀和品牌资源：

```objc
#import <IFLYADLib/IFLYADLib.h>
```

所有类型仍使用 `IFLY*` 前缀，资源包仍为 `IFLYPlayer.bundle`。优酷普通请求地址在二进制构建时固化为专属地址 `https://youku-sdk.voiceads.cn/ad/request`，不提供公开运行时 URL setter。

当前版本：`6.1.0`。最低支持 iOS 11.0，支持 iPhone、iPad、arm64 真机及 arm64/x86_64 模拟器。
正式 SDK 产物要求使用不高于 Xcode 26.2 的工具链构建，具体版本记录在 Release 的 `delivery-manifest.json`。

## 仓库内容

```text
YKIFLYADLib.podspec       CocoaPods 分发清单
Package.swift             Swift Package Manager 分发清单
IFLYADLibSimple/          仅含开屏、插屏、自渲染的 Demo 工程
```

SDK 私有源码、构建脚本和测试代码不在本分发仓。二进制只通过同版本 GitHub Release 交付。

当前仓库与同版本 GitHub Release 均为 Public，可匿名使用下述 CocoaPods、SwiftPM 或手动接入方式。

## Release 资产

每个正式版本包含两个交付资产和两个校验元数据文件：

| 文件 | 内容 | 适用方式 |
| --- | --- | --- |
| `YKIFLYADLib-<版本>.zip` | `IFLYADLib.xcframework`、`IFLYPlayer.bundle`、`LICENSE` | CocoaPods、手动集成 |
| `IFLYADLib.xcframework.zip` | 仅静态 XCFramework | SwiftPM 二进制 target |

同一 Release 还必须上传 `checksums.txt` 和 `delivery-manifest.json`。

静态 XCFramework 内的资源不会自动进入宿主 App：CocoaPods 通过 podspec 投递，SwiftPM 通过仓库内资源 target 投递；只有手动集成需要自行复制 `IFLYPlayer.bundle`。
SDK 为 Objective-C 静态库，最终 App 链接必须包含 `-ObjC`。CocoaPods 清单已配置该参数；SwiftPM 和手动接入需要在 App Target 的 `Other Linker Flags` 中添加。

## CocoaPods 接入

以下远程方式直接使用公开仓库中的 podspec 和同版本 GitHub Release 资产。

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!

  pod 'YKIFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/YKIFLYADLib_iOS/6.1.0/YKIFLYADLib.podspec'
end
```

然后执行：

```bash
pod install
open YourApp.xcworkspace
```

Pod 名是 `YKIFLYADLib`，但 SDK 模块名仍是 `IFLYADLib`。不要同时集成标准版 `IFLYADLib` 和优酷定制版，两者包含相同 Objective-C/C 符号。

## Swift Package Manager 接入

以下远程方式直接使用公开仓库和同版本 GitHub Release 资产。

在 Xcode 的 “Add Package Dependencies” 中添加：

```text
https://github.com/LJMcarryu/YKIFLYADLib_iOS.git
```

选择产品 `IFLYADLib` 即可，`IFLYPlayer.bundle` 会由同一 SwiftPM 产品自动投递，无需额外下载或复制。随后在 App Target 的 `Other Linker Flags` 添加 `-ObjC`。

## 手动接入

1. 下载并解压 `YKIFLYADLib-<版本>.zip`。
2. 将 `IFLYADLib.xcframework` 加入 App Target，Embed 选择 “Do Not Embed”。
3. 将 `IFLYPlayer.bundle` 加入 App Target 的 “Copy Bundle Resources”。
4. 在 App Target 的 `Other Linker Flags` 添加 `-ObjC`。
5. 在代码中导入 `<IFLYADLib/IFLYADLib.h>`。

## 隐私与 ATT

宿主 App 应在发起广告请求前完成自己的隐私同意流程。iOS 14 及以上如需使用 IDFA，还应配置：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>用于获取广告标识符 IDFA，以便请求和展示相关广告。</string>
```

SDK 的 `PrivacyInfo.xcprivacy` 位于 `IFLYPlayer.bundle`。媒体仍需根据实际业务在 App Store Connect 中完成隐私标签、ATT 和相关合规声明。

## 全局配置

```objc
[IFLYAdConfig setPersonalizedEnabled:YES];
[IFLYAdConfig setLogEnabled:NO];
```

`setPersonalizedEnabled:` 当前只记录媒体传入的状态，不会自动过滤请求字段或改变广告行为。正式版本建议关闭 SDK 日志。

## 开屏广告

```objc
@interface SplashViewController () <IFLYSplashAdDelegate>
@property (nonatomic, strong) IFLYSplashAd *ad;
@end

- (void)loadSplash {
    [self.ad destroy];

    IFLYSplashAd *ad = [[IFLYSplashAd alloc] initWithAdUnitId:@"开屏广告位 ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.ad = ad;
    [ad loadAd];
}

- (void)splashAdDidReady:(IFLYSplashAd *)ad {
    if (ad != self.ad || !ad.isAdValid) {
        return;
    }
    IFLYSplashAdConfig *config = [[IFLYSplashAdConfig alloc] init];
    config.traceDuration = 5;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}

- (void)splashAdDidClose:(IFLYSplashAd *)ad {
    if (ad == self.ad) {
        [ad destroy];
        self.ad = nil;
    }
}
```

`splashAdDidLoad:` 表示响应解析成功，`splashAdDidReady:` 表示 SDK 管理的主素材已经就绪。只能在 `didReady` 后展示。

## 插屏广告

```objc
@interface InterstitialViewController () <IFLYInterstitialAdDelegate>
@property (nonatomic, strong) IFLYInterstitialAd *ad;
@end

- (void)loadInterstitial {
    [self.ad destroy];

    IFLYInterstitialAd *ad =
        [[IFLYInterstitialAd alloc] initWithAdUnitId:@"插屏广告位 ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    self.ad = ad;
    [ad loadAd];
}

- (void)interstitialAdDidReady:(IFLYInterstitialAd *)ad {
    if (ad != self.ad || !ad.isAdValid) {
        return;
    }
    IFLYInterstitialAdConfig *config = [[IFLYInterstitialAdConfig alloc] init];
    config.presentationStyle = IFLYInterstitialPresentationStyleHalfScreen;
    config.muteOnStart = YES;
    [ad showAdFromRootViewController:self config:config];
}
```

插屏支持图片、视频以及横竖版素材。`presentationStyle` 可选择半屏或全屏；媒体不需要自行创建播放器。

## 自渲染信息流

自渲染链路为：

```text
创建 IFLYNativeFeedAd
→ loadAd
→ nativeFeedAdDidLoad:
→ 读取 adData
→ 媒体渲染 UI
→ 构造 Binder
→ bindAdWithViewBinder:error:
→ SDK 管理曝光、点击、跳转、视频和监测
→ unbindAd / destroy
```

### 请求和渲染

```objc
@interface NativeViewController () <IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) IFLYNativeFeedAd *ad;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIButton *closeButton;
@end

- (void)loadNativeAd {
    [self disposeNativeAd];

    IFLYNativeFeedAd *ad =
        [[IFLYNativeFeedAd alloc] initWithAdUnitId:@"自渲染广告位 ID"];
    ad.delegate = self;
    ad.currentViewController = self;
    ad.muteOnStart = YES;
    self.ad = ad;
    [ad loadAd];
}

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    if (ad != self.ad) {
        return;
    }

    IFLYNativeFeedAdData *data = ad.adData;
    if (!data.isMaterialComplete ||
        data.materialType == IFLYNativeFeedAdMaterialTypeUnknown) {
        [self disposeNativeAd];
        return;
    }

    // 先根据 data 渲染媒体自己的标题、图片、广告标识和关闭按钮。
    IFLYNativeFeedAdViewBinder *binder =
        [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.containerView;
    binder.closeView = self.closeButton;
    binder.renderViews = @[self.containerView, self.closeButton];

    BOOL clickable =
        data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    binder.clickViews = clickable ? @[self.containerView] : @[];

    if (data.materialType == IFLYNativeFeedAdMaterialTypeVideo) {
        binder.videoView = self.videoView;
    } else {
        binder.imageView = self.imageView;
    }

    IFLYAdError *error = nil;
    if (![ad bindAdWithViewBinder:binder error:&error]) {
        [self disposeNativeAd];
    }
}

- (void)disposeNativeAd {
    IFLYNativeFeedAd *ad = self.ad;
    self.ad = nil;
    [ad unbindAd];
    ad.delegate = nil;
    [ad destroy];
}
```

绑定必须在主线程进行。`containerView` 必填，Binder 中的视图必须属于该容器层级。

### 点击语义

- `Redirect`、`Download`：显式传入至少一个 `clickViews`。
- `Exposure`、`Unknown`：必须显式传 `@[]`。
- 不要把 `clickViews` 留为 `nil`；`nil` 会把整个容器作为默认点击区域。
- DeepLink、landing、下载兜底和点击监测由 SDK 统一处理，媒体不要自行 `openURL`。

### 视频容器

媒体只需提供普通 `UIView` 作为 `binder.videoView`，不需要创建 `AVPlayer`。SDK 只管理自己创建的播放器图层，并负责：

- 容器尺寸变化
- 绑定、解绑和复用
- 前后台切换
- 静音、缓冲、暂停、恢复和完播
- 播放事件及广告监测

页面复用或退出前必须先 `unbindAd`，再清除 delegate 并 `destroy`。一个广告实例绑定成功后即被消费，不能再次绑定到另一个容器。

视频 Binder 成功后可在 `nativeFeedAdDidRender:` 中调用 `startPlay`。播放器的
前后台暂停恢复、静音、缓冲、播放监测和资源释放由 SDK 管理；媒体只在
`nativeFeedAdDidStartPlay:`、`nativeFeedAdDidPausePlay:`、
`nativeFeedAdDidResumePlay:`、`nativeFeedAdDidPlayFinish:` 和播放失败回调中
同步自己的封面、占位和状态 UI。页面离开、Cell 复用或容器改作他用前仍必须调用
`unbindAd`，不能只移除 `videoView`。

### 自渲染公开字段

`IFLYNativeFeedAdData` 公开以下媒体渲染字段：

- `creativeId`
- `templateId` / `materialType`
- `interactionType`
- `interactType`
- `title`、`desc`、`content`、`ctaText`、`brand`、`appName`
- `adSourceMark`、`adSourceIconURL`
- `mainImage`、`image1`、`image2`、`image3`、`imageList`、`imageURLs`、`imageSize`
- `videoURL`、`videoCoverURL`、`videoDuration`、`videoSize`
- `icon` / `iconURL`
- `closeIconURL`
- `targetURL`、`deeplinkURL`
- `marketURL`、`downloadURL`
- `packageName`
- `hasShakeInteraction`

`templateId` 归一值：

| 值 | 类型 | 判断 |
| --- | --- | --- |
| `0` | Unknown | 素材无法识别 |
| `1` | SingleImage | 存在 `img` 或 `icon` |
| `2` | Video | 存在有效 `video` |
| `3` | MultipleImages | `img1`、`img2` 均有效，`img3` 可选 |

优先级是 `video → img1+img2 → img/icon → Unknown`。

`interactionType` 只按服务端 `action_type` 归一：`1=Exposure`、
`2=Redirect`、`3/4=Download`，`9` 及其他未支持值为 `Unknown`。
`Exposure`、`Unknown` 必须给 Binder 显式传入空的 `clickViews`；媒体不得把它们
兜底为可点击。`interactType` 按服务端 `interact` 归一：
`1=Click`、`2=ClickAndShake`、`3=ClickAndSlide`、
`4=ClickShakeAndSlide`，`5/6/7` 及其他未支持值为 `Unknown`。
当前 NativeFeed 不安装上滑手势，包含上滑的枚举只保留归一语义。

`appName` 对应服务端 `app_name`，仅用于下载类广告的应用名称。它与
`IFLYAdRequestConfig.appName` 不同：后者是媒体宿主 App 的请求参数。

### 通用竞价字段

三种广告都只通过以下对象读取通用竞价字段：

```objc
NSNumber *price = ad.bidInfo.price;
NSString *dealId = ad.bidInfo.dealId;
```

`price` 可能为 `nil`；S2S 加载成功时为 `0`。除 NativeFeed 自渲染外，开屏和插屏
不公开 `adData`、创意 ID 或完整服务端响应。`6.1.0` 只提供本节列出的自渲染
白名单字段；CTA 使用 `ctaText`，竞价字段统一从 `bidInfo` 获取。

## Demo

[IFLYADLibSimple](./IFLYADLibSimple) 使用开屏、插屏、NativeFeed 三种 SDK 能力，首页仅提供三个自渲染示例入口：

- 自渲染开屏：使用图片/视频开屏广告位，通过 `IFLYNativeFeedAdData` 和 Binder 复刻模板开屏样式。
- 自渲染插屏：使用横竖版图片/视频插屏广告位，通过 `IFLYNativeFeedAdData` 和 Binder 复刻模板插屏样式。
- 自渲染信息流示例。

首次启动会先展示隐私同意页面；同意后才允许配置 SDK、请求 ATT 和加载广告。三个示例使用六个优酷定制联调广告位，其中插屏横竖版共用对应的图片或视频广告位。能否返回素材仍取决于优酷请求域名路由和服务端广告位配置。

## 能力边界

本定制包不包含：

- `IFLYBannerAd`
- `IFLYRewardVideoAd`

同一个 App 不能同时链接标准版、YS 版或其他包含相同 `IFLYADLib` 模块和符号的自包含变体。
