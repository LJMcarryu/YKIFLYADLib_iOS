# 优酷定制 Demo

该工程仅演示优酷定制 SDK 的三种能力：

- 开屏广告：图片、视频。
- 插屏广告：横竖版图片、横竖版视频。
- 媒体自渲染：读取公开 `adData`，渲染图片或视频容器，再通过 Binder 绑定。

Demo 只调用 `IFLYADLib` 公开 API，不依赖私有 SDK 源码。首次启动必须先同意隐私政策；同意后才会配置 SDK、申请 ATT 并允许发起广告请求，选择“不同意并退出应用”会调用 `exit(0)`。

## 运行

```bash
cd IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

最低支持 iOS 11.0，支持 iPhone 和 iPad。真机运行前，请在 Xcode 的 Signing & Capabilities 中选择自己的开发者 Team。

Demo 默认引用 tag `6.0.14` 的 `YKIFLYADLib.podspec`。升级 SDK 时，需要同步修改 `Podfile` 中的 tag。
Demo 只有开屏、插屏和自渲染三个能力页面；其中开屏与自渲染分别提供图片/视频联调槽位，因此配置文件中共有五个素材场景广告位。广告位默认均为空，请先在 `Supporting Files/IFLYAdPrefixHeader.pch` 配置优酷联调广告位，否则页面会提示并停止请求。

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

仓库不提交广告位。请先配置优酷分配的联调广告位，正式接入时再替换为生产广告位。
