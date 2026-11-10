# 版本记录

## [6.5.0] - 更新说明

> `6.5.0` 已验证 CocoaPods、SwiftPM 的安装、版本锁定与模拟器构建；真机广告展示需在宿主 App 中联调。

<!-- ifly-release-status: {"version":"6.5.0","status":"FAST_UNVERIFIED","distribution":"tos","releaseUrl":"https://download-adsdk.voiceads.cn/ios_sdk/6.5.0/youku/fast-release-record.json"} -->

> 以下为历史版本记录，验收结论仅适用于各节明确列出的历史版本。

## [6.4.7] - 极速发布（未验证）

版本更新。该历史版本未完成安装、构建与广告展示验证，请在宿主 App 中联调。


## [6.4.6] - TOS 分发

调整 SDK 下载分发，安装入口保持不变。

下载文件与校验值见[版本下载记录](https://download-adsdk.voiceads.cn/ios_sdk/6.4.6/youku/release-record.json)。


## [6.4.4] - 发布工程优化

<a id="变更"></a>

优化 SDK 分发。公开 API、广告形式和最低系统要求保持不变。


## [6.4.2] - 冻结与发布记录

更新 SDK 分发。


## 6.4.1 - 发布工程优化

<a id="变更-1"></a>
<a id="变更-2"></a>

优化 SDK 分发。


## 6.4.0 冻结与发布记录

更新版本分发。


## 6.3.7 冻结与发布记录

更新版本分发。


## 6.3.6 冻结与发布记录

<a id="变更-3"></a>

优化多窗口场景下的广告展示与页面返回。

开屏 `customWindow` 须与宿主页面处于同一 Scene，并保持可见、尺寸有效。


## 6.3.5

<a id="变更-4"></a>

优化广告加载、展示及视频播放。


## 6.3.3（2026-09-01）

优化 NativeFeed 诊断信息。


## 6.3.2（2026-08-25）

优化 NativeFeed 点击交互。


## 6.3.1（2026-08-19）

优化 NativeFeed 视图绑定与点击处理。


## 6.3.0（2026-08-18）

优化 NativeFeed 外部点击视图的接入。


## 6.2.4（2026-08-17）

优化 NativeFeed 视图绑定与点击处理。


## 6.2.3

NativeFeed 新增 `allowsExternalClickViews`，默认 `NO`；需要外部点击视图时显式开启。

新增 `detachFromCurrentContainer` 便利方法。


## 6.2.2

NativeFeed 改用 Ad 级 `attachWithViewBinder:error:` 挂载、容器级 `detachAdFromContainerView:` 解绑；数据层持有 Ad，Cell 离屏或复用时解绑。

移除 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 和 `endDisplaySession`。从旧版升级须替换相关调用并重新编译。


## 6.2.1

NativeFeed 新增 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding` 及列表展示接口，支持 Cell 复用。

旧的 `bindAdWithViewBinder:error:` / `unbindAd` 用于固定卡片，两种接入方式不能在同一广告实例混用。


## 6.1.2

优化请求与跳转处理。

`jumpDirectly` 保留兼容，设置该属性不再影响跳转行为。

iOS 14 及以上传入 IDFA 前须取得 ATT 授权。


## 6.1.1

NativeFeed 新增媒体交互上报接口 `reportMediaShakeTriggeredWithError:`，更新接入示例。


## 6.1.0

提供开屏、插屏和 NativeFeed 接口，最低支持 iOS 11.0，包含真机与模拟器切片。

调整竞价和 NativeFeed 接口；使用 `bidInfo.price` / `bidInfo.dealId`、`ctaText` 和新版素材枚举，新增 `appName`。移除旧公开入口，升级须按该版本公开头修改调用并重新编译。


## 6.0.14

首次提供优酷定制 SDK，支持开屏、插屏和信息流，最低支持 iOS 11.0。
