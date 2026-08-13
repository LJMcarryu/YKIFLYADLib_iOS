# 优酷定制 Demo

该工程只调用优酷定制 SDK 的 `IFLYNativeFeedAd` 自渲染能力，使用开屏、插屏和信息流三类广告位提供以下三个示例：

- 自渲染开屏：使用图片/视频开屏广告位，按模板开屏样式渲染。
- 自渲染插屏：使用横竖版图片/视频插屏广告位，按模板插屏样式渲染。
- 自渲染信息流示例：用真实 `UITableView` 展示图文/视频 Cell 复用，同一稳定逻辑条目滚出后回屏仍恢复原广告。

Demo 只调用 `IFLYADLib` 公开 API，不依赖私有 SDK 源码。首次启动必须先同意隐私政策；同意后才会配置 SDK、申请 ATT 并允许发起广告请求，选择“不同意并退出应用”会调用 `exit(0)`。

## 运行

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

最低支持 iOS 11.0，支持 iPhone 和 iPad。真机运行前，请在 Xcode 的 Signing & Capabilities 中选择自己的开发者 Team。

Demo 已切换到 `6.2.3` tag 的 `YKIFLYADLib.podspec`；候选资产与元数据已冻结，公开可用性以同版本 GitHub Release 和发布后 CI 为准。
Demo 首页只有上述三个自渲染示例入口，不调用 `IFLYSplashAd` 或 `IFLYInterstitialAd` 的 SDK 内置模板渲染接口，也不包含 Banner、激励视频及其他进阶功能。三个示例均使用优酷定制联调广告位；能否返回素材还取决于优酷请求域名路由和服务端广告位配置。

`6.2.2` 保留 `6.1.2` 的全渠道共享修复：iOS 14 及以上只有 ATT `authorized` 时 SDK
才读取或接受 IDFA，撤权后清除缓存；普通请求与 S2S 请求使用同一门控。
DeepLink 不再经过 `canOpenURL:` 预检，而是以系统打开完成回调判定结果并保留
landing 回退；`jumpDirectly` 仅作为兼容 no-op。CocoaPods 清单显式链接
`AdSupport`、弱链接 `AppTrackingTransparency`，保持 iOS 11～13 可启动。
Demo 的隐私政策链接也只允许 HTTP/HTTPS，并直接交给系统打开。

## 信息流列表复用顺序

1. 数据模型以稳定 `itemIdentifier` 创建并持有 `IFLYNativeFeedAd`，设置 delegate 后调用 `loadAdWithRequestConfig:`。
2. 在 `nativeFeedAdDidLoad:` 中读取 `ad.adData`；媒体数据层只保存 Ad，展示会话、Binding 和 generation 由 SDK 内部托管。
3. `willDisplay` 中用原 `adData` 重画当前 Cell，构造 Binder，再对 Ad 调用 `attachWithViewBinder:error:`；Cell 不持有 Ad、Session、Binding 或首次/复用状态。
4. `didEndDisplaying` 和 `prepareForReuse` 调用 `detachAdFromContainerView:`，只提交该回调 Cell 自身的容器，不根据可能过期的 `indexPath` 反查广告。
5. 条目仍在数据源时保留同一 Ad，回屏后可对新 Cell 再次 attach；条目永久删除、关闭、页面退出或缓存淘汰时，detach 当前容器并释放最后一个 Ad 强引用。

`destroy` 不是正常回收必调项。仅当业务仍要持有 Ad、但希望立即取消请求并终止后续恢复能力时才主动调用。

视频场景不需要媒体创建 `AVPlayer`。媒体只提供普通 `UIView` 作为 `videoView`，SDK 会管理播放器图层、前后台、静音、缓冲、暂停、完播及监测。
视频按容器 detach 时移除旧 Cell 宿主，但保留播放器、进度和既有 `playRequested` 播放意图；同一稳定条目回屏后可从原状态恢复。媒体显式调用 `pausePlay` / `stopPlay` 后回屏不会自动起播，只有 `resumePlay` / `startPlay` 才重新申请播放。

`6.2.2` 继续使用归一后的 `templateId/materialType`、`interactionType` 和
`interactType`，只读取公开白名单字段；CTA 读取 `ctaText`，竞价信息读取
`bidInfo`。仅 `Redirect/Download` 传入实际 `clickViews`，
`Exposure/Unknown` 显式传 `@[]`。固定卡片和复用列表统一使用 Ad 级 attach 与容器级 detach。

`6.2.3` 默认仍要求点击视图位于广告容器内。确需容器外 CTA 时显式开启 `allowsExternalClickViews` 并处理 `nativeFeedAd:didRejectClickWithError:`；共享、悬浮、离屏仍可点击或归属不明会以 71503 失败关闭。固定单容器页面可按需使用 `detachFromCurrentContainer`。

曝光前滚出再回来会重新累计连续可见 `500ms`；已曝光条目恢复时不重复曝光。TTL 或视频投放截止时间不强拆当前活动容器，但会拒绝迁移到其他容器；当前容器正常 detach 后旧 Ad 不可再恢复。

信息流页面导航栏提供 `6.1.1` 引入的“媒体摇一摇上报”入口。广告自然曝光且当前有效可见后，媒体判定摇一摇并调用 `reportMediaShakeTriggeredWithError:`；SDK 从调用前的短时窗口选择真实三轴样本完成宏替换和点击处理。SDK 不自主触发该类点击，媒体未调用时不会上报。

## 广告位

Demo 使用以下六个优酷定制广告位，集中配置在
`Supporting Files/IFLYAdPrefixHeader.pch`：

| 场景 | 配置宏 | 广告位 ID |
| --- | --- | --- |
| 开屏图片 | `__SPLASH_NATIVE_AD_UNIT_ID__` | `BC05C9AA5D3E0D3E8F1B25CDAB603831` |
| 开屏视频 | `__SPLASH_VIDEO_AD_UNIT_ID__` | `5AF6465D44FCFAD4935C20D620614506` |
| 插屏图片（横竖共用） | `__INTERSTITIAL_AD_UNIT_ID__`、`__INTERSTITIAL_LANDSCAPE_IMAGE_AD_UNIT_ID__` | `A830C77F232A5DE10AF0E4B92E0426C9` |
| 插屏视频（横竖共用） | `__INTERSTITIAL_PORTRAIT_VIDEO_AD_UNIT_ID__`、`__INTERSTITIAL_LANDSCAPE_VIDEO_AD_UNIT_ID__` | `784C8D7CF6CFC970473E3CB1DE893B61` |
| 自渲染信息流图片 | `__TYPED_ONE_NATIVE_AD_UNIT_ID__` | `C954B4CD38EE3DE2D7A6283169B3E459` |
| 自渲染信息流视频 | `__FEED_VIDEO_AD_UNIT_ID__` | `C389BA3CD04BF2771C944B58E493DF94` |

插屏横竖版选择只控制 Demo 展示布局，不再对应不同广告位。
