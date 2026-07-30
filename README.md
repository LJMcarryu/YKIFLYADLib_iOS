# 优酷定制 IFLYADLib iOS SDK

本仓库是优酷媒体定制版的二进制分发仓，仅提供以下三种广告能力：

- 开屏广告 `IFLYSplashAd`
- 插屏广告 `IFLYInterstitialAd`
- 媒体自渲染 `IFLYNativeFeedAd`

图片和视频素材均受支持。Banner、激励视频不在本产物中，对应公开头、实现符号和专属资源已物理裁剪。

定制版保持标准 SDK 的模块名、类前缀和品牌资源：

```objc
#import <IFLYADLib/IFLYADLib.h>
```

所有类型仍使用 `IFLY*` 前缀，资源包仍为 `IFLYPlayer.bundle`。优酷普通请求地址在二进制构建时固化为 `https://youku-sdk.voiceads.cn/sdk/req`，不提供公开运行时 URL setter。

当前版本：`6.0.14`。最低支持 iOS 11.0，支持 iPhone、iPad、arm64 真机及 arm64/x86_64 模拟器。
正式 SDK 产物要求使用不高于 Xcode 26.2 的工具链构建，具体版本记录在 Release 的 `delivery-manifest.json`。

## 仓库内容

```text
YKIFLYADLib.podspec       CocoaPods 分发清单
Package.swift             Swift Package Manager 分发清单
IFLYADLibSimple/          仅含开屏、插屏、自渲染的 Demo 工程
```

SDK 私有源码、构建脚本和测试代码不在本分发仓。二进制只通过同版本 GitHub Release 交付。

当前仓库为 Private。GitHub 网页访问权限不会自动替 CocoaPods 的 `raw.githubusercontent.com` 或 SwiftPM 的二进制 URL 完成鉴权；在确定公开仓或经认证的二进制托管方案前，标准远程 CocoaPods/SwiftPM 地址不作为可用交付方式，只能使用获授权后下载的同版本合并包手动集成。若后续将仓库调整为 Public，则可直接使用下述远程接入方式。

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

以下远程方式要求仓库及 Release 可匿名访问；Private 阶段请使用获授权下载的合并包和本地 `:path` 接入。

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!

  pod 'YKIFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/YKIFLYADLib_iOS/6.0.14/YKIFLYADLib.podspec'
end
```

然后执行：

```bash
pod install
open YourApp.xcworkspace
```

Pod 名是 `YKIFLYADLib`，但 SDK 模块名仍是 `IFLYADLib`。不要同时集成标准版 `IFLYADLib` 和优酷定制版，两者包含相同 Objective-C/C 符号。

## Swift Package Manager 接入

以下远程方式要求仓库及 Release 可匿名访问，Private 阶段不可直接使用。

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

## 媒体自渲染

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

### 自渲染公开字段

`IFLYNativeFeedAdData` 公开以下媒体渲染字段：

- `creativeId`
- `templateId` / `materialType`
- `interactionType`
- `interactType`
- `title`、`desc`、`content`、`ctaText`、`brand`
- `adSourceMark`、`adSourceIconURL`
- `mainImage`、`image1`、`image2`、`image3`、`imageList`、`imageURLs`
- `videoURL`、`videoCoverURL`、`videoDuration`、`videoSize`
- `icon` / `iconURL`
- `closeIconURL`
- `targetURL`、`deeplinkURL`
- `marketURL`、`downloadURL`
- `packageName`

`templateId` 归一值：

| 值 | 类型 | 判断 |
| --- | --- | --- |
| `0` | Unknown | 素材无法识别 |
| `1` | SingleImage | 存在 `img` 或 `icon` |
| `2` | Video | 存在有效 `video` |
| `3` | MultipleImages | `img1`、`img2` 均有效，`img3` 可选 |

优先级是 `video → img1+img2 → img/icon → Unknown`。

### 通用竞价字段

三种广告都只通过以下对象读取通用竞价字段：

```objc
NSNumber *price = ad.bidInfo.price;
NSString *dealId = ad.bidInfo.dealId;
```

除 NativeFeed 自渲染外，开屏和插屏不公开 `adData`、创意 ID或完整服务端响应。

## Demo

[IFLYADLibSimple](./IFLYADLibSimple) 仅保留开屏、插屏、媒体自渲染三个入口。首次启动会先展示隐私同意页面；同意后才允许配置 SDK、请求 ATT 和加载广告。

Demo 按产品确认复用标准 Demo 的五个联调广告位，可直接发起开屏图片/视频、插屏及自渲染图片/视频请求；能否返回素材还取决于优酷域名路由和服务端广告位配置。这些广告位仅供联调，媒体正式接入必须替换为自身生产广告位。

## 能力边界

本定制包不包含：

- `IFLYBannerAd`
- `IFLYRewardVideoAd`

同一个 App 不能同时链接标准版、YS 版或其他包含相同 `IFLYADLib` 模块和符号的自包含变体。
