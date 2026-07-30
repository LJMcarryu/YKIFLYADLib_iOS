# 版本记录

## 6.0.14

- 创建优酷定制 Model B 单包交付。
- 仅保留开屏、插屏、自渲染信息流三种能力。
- 支持图片、视频及 NativeFeed Binder 播放链路。
- 物理裁剪 Banner、激励视频的公开头、实现符号和专属资源。
- SDK 模块名、`IFLY*` 类前缀及 `IFLYPlayer.bundle` 保持不变。
- 普通广告请求地址当前由内部构建配置固化为灰度地址 `https://youku-sdk-grey.voiceads.cn/sdk/req`，不对媒体公开 URL setter。
- SwiftPM 资源隐私清单同步声明灰度请求域名 `youku-sdk-grey.voiceads.cn`。
- 最低支持 iOS 11.0；包含 arm64 真机和 arm64/x86_64 模拟器切片。
- Demo 提供开屏、插屏、自渲染开屏、自渲染插屏和自渲染信息流五个示例，并在首次启动隐私同意后才允许广告请求。
- Demo 切换为六个优酷定制广告位；插屏横竖版共用对应的图片或视频广告位。
