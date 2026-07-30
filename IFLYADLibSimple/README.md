# 优酷定制 Demo

该工程仅使用优酷定制 SDK 的开屏、插屏、NativeFeed 三种能力，提供以下五个示例：

- 开屏广告：图片、视频。
- 插屏广告：横竖版图片、横竖版视频。
- 自渲染开屏：使用图片/视频开屏广告位，按模板开屏样式渲染。
- 自渲染插屏：使用横竖版图片/视频插屏广告位，按模板插屏样式渲染。
- 自渲染信息流示例：读取公开 `adData`，渲染图片或视频容器，再通过 Binder 绑定。

Demo 只调用 `IFLYADLib` 公开 API，不依赖私有 SDK 源码。首次启动必须先同意隐私政策；同意后才会配置 SDK、申请 ATT 并允许发起广告请求，选择“不同意并退出应用”会调用 `exit(0)`。

## 运行

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

最低支持 iOS 11.0，支持 iPhone 和 iPad。真机运行前，请在 Xcode 的 Signing & Capabilities 中选择自己的开发者 Team。

Demo 默认引用 tag `6.0.14` 的 `YKIFLYADLib.podspec`。升级 SDK 时，需要同步修改 `Podfile` 中的 tag。
Demo 首页只有上述五个示例入口，不包含 Banner、激励视频及其他进阶功能。五个示例均使用优酷定制联调广告位；能否返回素材还取决于优酷请求域名路由和服务端广告位配置。

## 自渲染接入顺序

1. 创建一个 `IFLYNativeFeedAd` 实例并设置 delegate。
2. 调用 `loadAdWithRequestConfig:`。
3. 在 `nativeFeedAdDidLoad:` 中读取 `ad.adData`。
4. 媒体根据 `templateId`、`imageURLs`、`videoURL` 等公开字段渲染 UI。
5. 构造 `IFLYNativeFeedAdViewBinder`，设置容器、渲染视图、点击视图、关闭视图和可选 `videoView`。
6. 在主线程调用 `bindAdWithViewBinder:error:`。
7. 页面复用或离开前调用 `unbindAd`，不再使用广告时调用 `destroy`。

视频场景不需要媒体创建 `AVPlayer`。媒体只提供普通 `UIView` 作为 `videoView`，SDK 会管理播放器图层、前后台、静音、缓冲、暂停、完播及监测。

## 广告位

Demo 使用以下六个优酷定制广告位，集中配置在
`Supporting Files/IFLYAdPrefixHeader.pch`。开屏和插屏模板示例与对应自渲染示例共用广告位：

| 场景 | 配置宏 | 广告位 ID |
| --- | --- | --- |
| 开屏图片 | `__SPLASH_NATIVE_AD_UNIT_ID__` | `BC05C9AA5D3E0D3E8F1B25CDAB603831` |
| 开屏视频 | `__SPLASH_VIDEO_AD_UNIT_ID__` | `5AF6465D44FCFAD4935C20D620614506` |
| 插屏图片（横竖共用） | `__INTERSTITIAL_AD_UNIT_ID__`、`__INTERSTITIAL_LANDSCAPE_IMAGE_AD_UNIT_ID__` | `A830C77F232A5DE10AF0E4B92E0426C9` |
| 插屏视频（横竖共用） | `__INTERSTITIAL_PORTRAIT_VIDEO_AD_UNIT_ID__`、`__INTERSTITIAL_LANDSCAPE_VIDEO_AD_UNIT_ID__` | `784C8D7CF6CFC970473E3CB1DE893B61` |
| 自渲染信息流图片 | `__TYPED_ONE_NATIVE_AD_UNIT_ID__` | `C954B4CD38EE3DE2D7A6283169B3E459` |
| 自渲染信息流视频 | `__FEED_VIDEO_AD_UNIT_ID__` | `C389BA3CD04BF2771C944B58E493DF94` |

插屏横竖版选择只控制 Demo 展示布局，不再对应不同广告位。
