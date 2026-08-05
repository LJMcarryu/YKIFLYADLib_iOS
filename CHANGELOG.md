# 版本记录

## 6.1.1

- NativeFeed 新增媒体摇一摇点击上报接口 `reportMediaShakeTriggeredWithError:`。
- 所有已自然曝光且有效可见的 NativeFeed 广告被动缓存短时三轴数据；不依赖服务端 `interact`、素材类型或跳转能力。
- 媒体调用是该模式唯一的摇一摇点击触发源；SDK 从调用前的短时间窗口选择一帧真实数据用于点击宏替换、监测和后续点击处理，不自主按阈值触发。
- Demo 增加媒体摇一摇上报入口，发布 CI 增加 manifest、公开头、二进制 selector 和采样类门禁。
- 优酷版本独立升级为 `6.1.1`，普通请求地址及原有三种广告能力保持不变。

## 6.1.0

- 普通广告请求地址固化为优酷专属正式地址
  `https://youku-sdk.voiceads.cn/ad/request`，不对媒体公开 URL setter。
- 收紧公开响应数据边界：通用竞价字段统一为 `bidInfo.price/dealId`；
  NativeFeed 只暴露媒体渲染白名单字段。
- NativeFeed 使用归一后的 `templateId/materialType`、`interactionType` 和
  `interactType`；移除非白名单旧公开入口，CTA 改用 `ctaText`。
- NativeFeed 新增下载类应用名称 `appName`，对应服务端 `app_name`。
- Demo 仅保留自渲染开屏、自渲染插屏和自渲染信息流三个示例，并继续使用
  六个优酷定制广告位。
- Demo 完善 Binder 点击白名单、仅曝光空 `clickViews`、解绑复用和视频生命周期示例。
- SwiftPM 资源隐私清单声明优酷专属请求域名 `youku-sdk.voiceads.cn`。
- 最低支持 iOS 11.0；包含 arm64 真机和 arm64/x86_64 模拟器切片。

## 6.0.14

- 创建优酷定制 Model B 单包交付。
- 仅保留开屏、插屏、自渲染信息流三种能力。
- 支持图片、视频及 NativeFeed Binder 播放链路。
- 物理裁剪 Banner、激励视频的公开头、实现符号和专属资源。
- SDK 模块名、`IFLY*` 类前缀及 `IFLYPlayer.bundle` 保持不变。
- 最低支持 iOS 11.0；包含 arm64 真机和 arm64/x86_64 模拟器切片。
