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

## 6.2.3 发布状态

当前候选版本：`6.2.3`。正式签名资产、checksum 和 A/B 元数据已经冻结；公开可用性以同版本 GitHub Release 和发布后 CI 为准。最低支持 iOS 11.0，支持 iPhone、iPad、arm64 真机及 arm64/x86_64 模拟器。
正式 SDK 产物要求使用不高于 Xcode 26.2 的工具链构建，具体版本记录在 Release 的 `delivery-manifest.json`。

<!-- 供发布 CI 机器校验的两提交 provenance；README、CHANGELOG、RELEASING 必须保持一致。 -->
- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`11bd2827041cd245329d12e959310f77d76b7ddd`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`6b2b21020589d3b96534167e9cb94b5a9fb76fa1`

`6.2.3` 的正式签名资产和 checksum 已冻结并完成本地校验；公开可用性以同版本 GitHub Release 和发布后 CI 为准。

`releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结；公开可用性以同版本 GitHub Release 和发布后 CI 为准。本提交是 `6.2.3` 的不可变发布目标。

`6.2.3` 不沿用历史风险授权；主动 Apple Review 扫描策略固定为 `failOn=high`、`failOnWarning=true`、`strict=true`、`requireManual=true`、`acceptedWarningRuleIds=[]`。扫描状态不改写正式发布状态，未扫描不得表述为通过。

## 6.2.2 历史正式事实

以下为 `6.2.2` 历史正式事实：

`6.2.2` 正式分发资产由私有源码提交
`a8ec925d3731d7d11734647aa02ca7d91d674965` 生成；`delivery-manifest.json` 的
`sourceCommit` 与 `sourceBuild.sourceCommit` 均保持该提交。SwiftPM zip 的 SHA-256 为
`1ddbe4b12ec95658845b80adb8d4d91b9a9ce778d618b4f1a9ad41d5886d1ddb`，合并 zip 的
SHA-256 为 `0ba19a49cc09f4dba8b62224ba84a2f8c3447ca7ad959ae7edf06286fd89f0bc`。
产物使用 Xcode 26.2（Build `17C52`）；两个 framework 切片均为非 ad-hoc 开发签名，
证书 SHA-1 为 `767B1F38300A6AACAF2B7AC3A4EA052201D981BB`，`TeamIdentifier` 均为
`FM295M5CZ5`。[GitHub Release 6.2.2](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.2)
已正式公开，资产库存严格为 4 项；[published CI](https://github.com/LJMcarryu/YKIFLYADLib_iOS/actions/runs/31347053230)
已成功完成无凭据匿名下载、资产与 A/B provenance 校验，并实际构建 Demo 和 SwiftPM 产品。
该分发验收不代表最终宿主合规、`Validate App` 或 Apple 审核通过。

## 仓库内容

```text
YKIFLYADLib.podspec       CocoaPods 分发清单
Package.swift             Swift Package Manager 分发清单
IFLYADLibSimple/          三个 NativeFeed 自渲染场景的 Demo 工程
```

SDK 私有源码、构建脚本和测试代码不在本分发仓。二进制只通过同版本 GitHub Release 交付。

`6.2.3` 分发清单已冻结真实 checksum、A/B 和 `delivery-manifest.json`；公开可用性以同版本 GitHub Release 和发布后 CI 为准。

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

正式发布后，以下远程方式固定使用 `6.2.3` tag 的 podspec 和同版本 GitHub Release 资产：

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!

  pod 'YKIFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/YKIFLYADLib_iOS/6.2.3/YKIFLYADLib.podspec'
end
```

然后执行：

```bash
pod install
open YourApp.xcworkspace
```

Pod 名是 `YKIFLYADLib`，但 SDK 模块名仍是 `IFLYADLib`。不要同时集成标准版 `IFLYADLib` 和优酷定制版，两者包含相同 Objective-C/C 符号。

## Swift Package Manager 接入

以下远程方式待 `6.2.3` 正式公开后使用精确版本；发布前不要依赖 `main` 分支获取二进制。

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

`6.1.2` 在 SDK 内统一收紧 IDFA 门控：iOS 14 及以上仅在 ATT 状态为
`authorized` 时读取或接受 IDFA，未授权阶段传入的 IDFA 不会留待授权后复用；
授权被撤回后会清除缓存。普通广告请求与 S2S 请求遵循同一规则。iOS 11～13
继续按系统广告跟踪状态处理；CocoaPods 清单显式链接 `AdSupport`，并弱链接
`AppTrackingTransparency`，不会让 iOS 11～13 因缺少该系统框架而无法启动。

## 跳转兼容说明

`6.1.2` 不再使用 `canOpenURL:` 预检 DeepLink，而是直接调用系统
`openURL:options:completionHandler:` 并根据完成回调判断是否打开；失败时仍按既有
规则回退 landing。非法 HTTP URL、携带凭据的 URL 和危险 scheme 会在打开前拒绝。
历史字段 `jumpDirectly` 仅为源码兼容保留，设置后不会绕过 SDK 的监测、回退或
安全校验，也不会改变跳转行为。

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

本节描述 `6.2.2` 的 SDK 托管挂载契约，实际接入必须与所选 tag 的公开头保持一致。

`6.2.3` 在该主路径上新增受限外部 CTA：Binder 的 `allowsExternalClickViews` 默认 `NO`。只有外部 CTA 与广告同生共灭且媒体无法调整层级时才显式开启；SDK 仅接受同 window/scene 且归属可判定的同 Cell 或窄范围兄弟视图。共享、固定悬浮、广告离屏后仍可点击或归属不明时失败关闭，运行中拒绝通过 delegate `nativeFeedAd:didRejectClickWithError:` 通知 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）。固定单容器页面还可按需使用 `detachFromCurrentContainer`；常规 Cell 仍应按容器 detach。

固定卡片与复用列表使用同一套 SDK 托管挂载入口：

```text
创建 IFLYNativeFeedAd
→ loadAd
→ nativeFeedAdDidLoad:
→ 读取 adData
→ 媒体渲染 UI
→ 构造 Binder
→ attachWithViewBinder:error:
→ SDK 管理曝光、点击、跳转、视频和监测
→ Cell 离屏、复用或切换普通内容时 detachAdFromContainerView:
→ 条目永久结束时释放数据层最后一个 Ad 强引用
```

媒体必须提交的视图生命周期动作只有 attach 和 detach。SDK 内部维护展示会话、Binding、generation 和内容级去重；媒体数据层只持 `IFLYNativeFeedAd`，Cell 不持 SDK 生命周期对象，也不记录“首次展示还是复用展示”。`destroy` 是仍持有 Ad 时主动提前终止的可选入口，不是正常回收必调项。

同一逻辑条目滚出后再回来仍使用原 Ad：

```text
数据层按稳定 itemID 持有 Ad
→ Cell 进屏时用 adData 重画 UI，并对该 Ad attach
→ Cell 离屏或复用时只按自身 containerView detach
→ 数据层继续持有原 Ad，回屏后对新 Cell 再次 attach
→ 条目永久淘汰时 detach 当前容器，并释放最后一个 Ad 强引用
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
    if (![ad attachWithViewBinder:binder error:&error]) {
        [self disposeNativeAd];
    }
}

- (void)disposeNativeAd {
    IFLYNativeFeedAd *ad = self.ad;
    self.ad = nil;
    [IFLYNativeFeedAd detachAdFromContainerView:self.containerView];
    ad.delegate = nil;
    ad.currentViewController = nil;
    // self.ad 是最后一个强引用时，离开本方法后 SDK 会自动完成终态清理。
}

- (void)terminateNativeAdEarly {
    // 仅当业务仍要保留 ad 引用，但希望立刻取消请求并终止恢复能力时使用。
    [IFLYNativeFeedAd detachAdFromContainerView:self.containerView];
    [self.ad destroy];
}
```

attach 必须在主线程同步调用。`containerView` 必填，Binder 中的视图必须属于该容器层级。相同 Ad 与相同活动容器重复 attach 为幂等成功；有效期内换容器时由 SDK 串行迁移，目标容器已有其他广告时会在预检成功后原子接管。新挂载预检失败不会破坏原活动挂载。

### UITableView / UICollectionView 复用

列表数据模型以稳定 `itemID` 持有 Ad，不要用会随 diff、插入和删除变化的 `indexPath` 作为广告身份：

```objc
// didLoad：数据层只保存该逻辑条目的 Ad。
item.ad = ad;

// willDisplay / Cell 配置：用 item.ad.adData 重画当前 Cell，再提交 Binder。
IFLYAdError *error = nil;
[item.ad attachWithViewBinder:binder error:&error];

// didEndDisplaying / prepareForReuse / 变成普通内容：只提交该 Cell 的容器。
[IFLYNativeFeedAd detachAdFromContainerView:cell.adContainerView];

// 条目删除、页面退出或缓存淘汰：detach 可见容器并释放最后一个 Ad 强引用。
[IFLYNativeFeedAd detachAdFromContainerView:cell.adContainerView];
item.ad.delegate = nil;
item.ad.currentViewController = nil;
item.ad = nil;
```

`attachWithViewBinder:error:` 必须在主线程调用；`detachAdFromContainerView:` 幂等，可从任意线程重复调用。`didEndDisplaying` 应直接提交回调 Cell 自身的 `containerView`，不要根据可能过期的 `indexPath` 反查广告。SDK 会给每个容器挂载分配内部 generation，旧 Cell 迟到的 detach、手势、曝光或视频事件不会影响已迁移到新 Cell 的挂载。

未曝光时重挂载会重新累计连续可见 `500ms`，不累加不同 Cell 的时长；已曝光后恢复不重复发送曝光监测或公开曝光回调。同一 Ad 同时只允许一个活动容器。视频 detach 后保留播放器、进度和既有 `playRequested` 播放意图；显式 `pausePlay` / `stopPlay` 后不会因回屏自动恢复，只有 `resumePlay` / `startPlay` 才重新申请播放。

素材 TTL 或视频投放截止时间在当前容器活动期间到达时，不中途强拆该 Cell；相同 Ad 与相同活动容器的幂等 attach 仍成功，但迁移到其他容器会失败。当前容器正常 detach 后旧 Ad 不再允许恢复，应释放该条目并请求新广告。

### 点击语义

- `Redirect`、`Download`：显式传入至少一个 `clickViews`。
- `Exposure`、`Unknown`：必须显式传 `@[]`。
- 不要把 `clickViews` 留为 `nil`；`nil` 会把整个容器作为默认点击区域。
- DeepLink、landing、下载兜底和点击监测由 SDK 统一处理，媒体不要自行 `openURL`。

### 媒体摇一摇上报

自优酷 `6.1.1` 起，NativeFeed 由媒体负责判定摇一摇，SDK 不自主按阈值触发。广告自然曝光且有效可见期间，SDK 对全部 NativeFeed 广告被动缓存短时三轴数据，不依赖服务端 `interact` 或素材类型；媒体确认摇一摇后在主线程调用：

```objc
IFLYAdError *error = nil;
BOOL accepted = [ad reportMediaShakeTriggeredWithError:&error];
```

`YES` 只表示 SDK 已接受事件并进入宏替换、监测、跳转和点击回调，不保证一定匹配到加速度样本或跳转成功。每个逻辑广告条目最多接受一次；Cell detach/attach 不重置次数。广告尚未自然曝光、当前没有活动可见挂载、普通点击已进入处理或非主线程调用时会返回 `NO`，具体错误为 `71512`～`71515`。媒体未调用该接口时，不会形成这类摇一摇点击。

### 视频容器

媒体只需提供普通 `UIView` 作为 `binder.videoView`，不需要创建 `AVPlayer`。SDK 只管理自己创建的播放器图层，并负责：

- 容器尺寸变化
- 绑定、解绑和复用
- 前后台切换
- 静音、缓冲、暂停、恢复和完播
- 播放事件及广告监测

固定卡片页面退出、列表 Cell 离屏、复用或改成普通内容时，都按其 `containerView` 调用 `detachAdFromContainerView:`。逻辑条目仍在数据源时继续保留 Ad；条目永久终止时释放最后一个 Ad 强引用即可。只有业务仍持有 Ad、但需要立即取消请求或终止恢复能力时才调用 `destroy`。

首次视频挂载成功后，可在 `nativeFeedAdDidRender:` 中调用 `startPlay`。后续跨 Cell attach 也可能收到 `didRender`，不应在该回调中无条件重置播放意图；回屏时应保留原 `playRequested`，只有媒体明确需要重新起播时才调用 `startPlay` / `resumePlay`。播放器的
前后台暂停恢复、静音、缓冲、播放监测和资源释放由 SDK 管理；媒体只在
`nativeFeedAdDidStartPlay:`、`nativeFeedAdDidPausePlay:`、
`nativeFeedAdDidResumePlay:`、`nativeFeedAdDidPlayFinish:` 和播放失败回调中
同步自己的封面、占位和状态 UI。两种场景都不能只移除 `videoView`，必须提交整个广告容器 detach。

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
不公开 `adData`、创意 ID 或完整服务端响应。`6.2.2` 继续只提供本节列出的自渲染
白名单字段；CTA 使用 `ctaText`，竞价字段统一从 `bidInfo` 获取。

## Demo

[IFLYADLibSimple](./IFLYADLibSimple) 只调用 `IFLYNativeFeedAd` 自渲染能力，使用开屏、插屏和信息流三类广告位提供三个示例入口：

- 自渲染开屏：使用图片/视频开屏广告位，通过 `IFLYNativeFeedAdData` 和 Binder 复刻模板开屏样式。
- 自渲染插屏：使用横竖版图片/视频插屏广告位，通过 `IFLYNativeFeedAdData` 和 Binder 复刻模板插屏样式。
- 自渲染信息流列表复用示例，可切换图文/视频广告位，展示“数据层只持 Ad、Cell 只提交容器”的 SDK 托管挂载和媒体摇一摇上报。

首次启动会先展示隐私同意页面；同意后才允许配置 SDK、请求 ATT 和加载广告。三个示例使用六个优酷定制联调广告位，其中插屏横竖版共用对应的图片或视频广告位。能否返回素材仍取决于优酷请求域名路由和服务端广告位配置。

自渲染开屏和自渲染插屏只是媒体侧视觉示例，不调用 `IFLYSplashAd` 或 `IFLYInterstitialAd` 的 SDK 内置模板渲染接口。

## 能力边界

本定制包不包含：

- `IFLYBannerAd`
- `IFLYRewardVideoAd`

同一个 App 不能同时链接标准版、YS 版或其他包含相同 `IFLYADLib` 模块和符号的自包含变体。
