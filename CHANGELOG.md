# 版本记录

## 6.3.0（2026-08-18）

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.3.0","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.0"} -->

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`eb99fce9d25c428c72364a6cca525bdd60f9933b`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`def3a9d78dcb1b67959e84e7aa438c9e9be7cb93`
- `candidateId`：`a556965f5b23c71cc07e8df741666383e084008a82f7a8e1748eed0494df43cd`
- `IFLYADLib.xcframework.zip` 的 SwiftPM checksum/SHA-256：`89a12212dfc3601f0d639eb5a87c8888825bff25f4320da8f8457f3ba9c31245`；`YKIFLYADLib-6.3.0.zip` 的 SHA-256：`29fa01226d68ee59df0bd257db0d67d9e73bd9d0bc3a6232a93bc79897e53f90`。
- `releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结；公开可用性以 [GitHub Release 6.3.0](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.0) 和发布后 CI 为准。
- Apple Review 扫描未执行且不是发布门禁：`requiredForRelease=false`、`statusAtFreeze=not-run`、`evidenceIncluded=false`。
- 优酷变体的外置 CTA 可在绑定后再挂载和布局，不再要求与 containerView 存在共同层级、包装器或距离关系；`allowsExternalClickViews` 仍默认 `NO`。
- 点击时仍须通过同 window/scene、CTA 可见可交互且面积小于 window 的 25%、广告容器前台可见比例至少 2/3，以及当前 Ad/container/generation 独占租约校验；失败以 71503 拒绝，不曝光、不监测、不跳转。

## 6.2.4（2026-08-17）

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`b0f745d582ce2bed5110702cff972be4153e5038`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`7b08118b43a0c4441de4c76a64f34fa54b3fe889`
- `candidateId`：`61f427469346615982e0225fad8187611794cc0a54c452da83073e89fd5ea1bd`
- `IFLYADLib.xcframework.zip` 的 SwiftPM checksum/SHA-256：`ce27b5d98a925c109fa6355a8095db7201717c7e1b9b2bcbbb92265dc2272d5e`；`YKIFLYADLib-6.2.4.zip` 的 SHA-256：`c39a0e321a58f5ae89157530c32864f4d5501b118b173fc3f8c2bcea0d99e8c0`。
- `releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结；[GitHub Release 6.2.4](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.4) 的 4 个资产已完成无 Token 匿名校验。
- annotated Tag 解引用到 `c16ba284c12cf9f165c85c63fd6f846c52ad46b7`，正式消费 [Run 32027222871](https://github.com/LJMcarryu/YKIFLYADLib_iOS/actions/runs/32027222871) 为 `success`。
- Apple Review 扫描未执行且不是发布门禁：`requiredForRelease=false`、`statusAtFreeze=not-run`、`evidenceIncluded=false`。
- `6.2.4` 不沿用历史风险授权；主动 Apple Review 扫描仍使用 `failOn=high`、`failOnWarning=true`、`strict=true`、`requireManual=true`、`acceptedWarningRuleIds=[]`，未扫描不得表述为通过。
- NativeFeed 受限外部 CTA 新增 window-local 归属：同 window/scene 内容器与 CTA 几何紧凑相邻时，非 Cell 场景不再强制共同 wrapper；绑定时固定归属类型和祖先路径，运行中 reparent 不得重新猜测归属。
- 跨 window、页面级或近全屏容器、远距离分散、共享/固定悬浮、离屏仍可点击和归属不明仍以 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）失败关闭。

## 6.2.3

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`ea0240e620b57d7275e486199099c648f51de257`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`0f26b7647e6c1aadb32eca68b24f6845639a59c2`
- `candidateId`：`f54a629205204bc1d2a820b23160450c856368c756ea544aa1623ef130d975e5`
- `IFLYADLib.xcframework.zip` 的 SwiftPM checksum/SHA-256：`309c22486980cc283e76ea6d1299255b4f244e6ae4be3ef4f0ed959bd1cc0814`；`YKIFLYADLib-6.2.3.zip` 的 SHA-256：`c4c821bd97aaa7eaed3f2441476c43a6bed6e34e8deec9b6b26c1decc88ef86b`。
- [GitHub Release 6.2.3](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.3) 已于 2026-08-16 正式公开，annotated tag 解引用到 `ac7c5302903e9535d1a7d847eeac24a3c0237d74`，4 个资产已通过无 Token 匿名验证与正式消费 [Run 31940242816](https://github.com/LJMcarryu/YKIFLYADLib_iOS/actions/runs/31940242816)。
- `releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结。
- 公开可用性以同版本 GitHub Release 和发布后 CI 为准。
- Apple Review 扫描未执行且不是发布门禁：`requiredForRelease=false`、`statusAtFreeze=not-run`、`evidenceIncluded=false`。
- `6.2.3` 不沿用历史风险授权；主动 Apple Review 扫描策略固定为 `failOn=high`、`failOnWarning=true`、`strict=true`、`requireManual=true`、`acceptedWarningRuleIds=[]`。扫描状态不改写正式发布状态，未扫描不得表述为通过。
- NativeFeed Binder 新增 `allowsExternalClickViews`（默认 `NO`）。显式开启后仅接受同 window/scene 且归属可判定的同 Cell 或窄范围兄弟视图；共享、固定悬浮、离屏仍可点击或归属不明时失败关闭，并通过 `nativeFeedAd:didRejectClickWithError:` 返回 `IFLYAdErrorCodeNativeFeedClickViewsInvalid`（71503）。
- 新增 `detachFromCurrentContainer` 固定单容器便利入口；6.2.2 的 Ad 级 attach 与容器级 detach 仍是通用主路径。

## 6.2.2

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`a8ec925d3731d7d11734647aa02ca7d91d674965`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`eff78263c2d3f65b029f4114de1a9ed00f3827f3`

- 正式资产已在内部冻结：SwiftPM zip SHA-256 为 `1ddbe4b12ec95658845b80adb8d4d91b9a9ce778d618b4f1a9ad41d5886d1ddb`，合并 zip SHA-256 为 `0ba19a49cc09f4dba8b62224ba84a2f8c3447ca7ad959ae7edf06286fd89f0bc`。[GitHub Release 6.2.2](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.2) 已正式公开，annotated tag 解引用后的提交为 `498f148b24bfc8866fff0a0e8575b34d2e2bc542`，资产库存严格为 4 项；[published CI](https://github.com/LJMcarryu/YKIFLYADLib_iOS/actions/runs/31347053230) 成功完成无凭据匿名下载、资产与 A/B provenance 校验，以及 Demo、SwiftPM 产品的实际消费构建。该分发验收不代表最终宿主合规、`Validate App` 或 Apple 审核通过。
- 按已确认范围保留 `SRC-004`、`SRC-008`、`SRC-009`、`SRC-011`、`NET-001`、`RRA-003`、`TRACK-001`、`TRACK-002`、`ADS-011`、`EXPORT-001` 启发式残余风险，以 `failOn=high`、`failOnWarning=false`、`strict=false`、`requireManual=false` 执行；不据此宣称最终宿主合规或 Apple 审核通过。

- NativeFeed 改为 SDK 托管挂载：媒体数据层只需持有 `IFLYNativeFeedAd`，Cell 不再维护 DisplaySession、Binding 或首次/复用状态。
- Cell 配置时调用 Ad 级 `attachWithViewBinder:error:`；离屏、复用或切换普通内容时调用容器级 `detachAdFromContainerView:`。同一广告可在 Cell 间串行迁移，同一容器可由新广告原子接管。
- detach 只解除当前视图宿主，数据层继续持有同一 Ad 时回屏可再次 attach；释放最后一个 Ad 强引用会自动完成终态清理，`destroy` 仅用于仍持有 Ad 时主动提前终止。
- 移除公开的 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 和 `endDisplaySession`；从 `6.2.1` 升级必须同步修改接入代码。
- 保持曝光、点击和视频节点按逻辑广告内容去重，视频进度与播放意图跨 Cell 恢复；曝光前换 Cell 会重新累计连续可见 `500ms`。
- 保持优酷专属请求地址 `https://youku-sdk.voiceads.cn/ad/request`、媒体摇一摇上报、Splash/Interstitial/NativeFeed 三种能力、iOS 11.0 最低系统及 4 个 Release 资产契约不变。

## 6.2.1

- NativeFeed 新增 `IFLYNativeFeedDisplaySession` 和 `IFLYNativeFeedAdBinding`，支持同一稳定逻辑广告条目在 `UITableView` / `UICollectionView` 复用 Cell 之间串行恢复；固定卡片的 `bindAdWithViewBinder:error:` / `unbindAd` 仍保持一次性语义。
- 数据层按稳定 ID 持有 Ad + DisplaySession，Cell 只持有当前 Binding；离屏调用 `detach`，条目永久删除、页面退出或缓存淘汰时按 `detach -> endDisplaySession -> destroy` 收口。
- 曝光前重挂载不累加不同 Cell 的可见时长；已曝光后恢复不重复曝光。Binding generation 隔离迟到的 detach、手势、曝光和视频事件。
- 视频跨 Cell 恢复时保留播放器、进度和播放意图。素材 TTL 或视频投放截止时间只拒绝后续 attach，不中途强拆当前活动 Binding；正常 detach 后不得再恢复。
- Demo 改为真实列表复用示例，覆盖 `willDisplay` / `didEndDisplaying` 乱序与图文/视频条目，并保留优酷媒体摇一摇上报入口。
- 保持优酷专属请求地址 `https://youku-sdk.voiceads.cn/ad/request`、Splash/Interstitial/NativeFeed 三种能力、iOS 11.0 最低系统和既有 ATT/跳转边界不变。

## 6.1.2

- 同步全渠道共享 Core 修复：iOS 14 及以上仅在 ATT 状态为 `authorized` 时读取或接受 IDFA；未授权及撤权后不再复用缓存值，普通请求与 S2S 请求使用同一门控。
- 跳转链路移除 `canOpenURL:` 预检，改为调用 `openURL:options:completionHandler:` 并以系统完成回调判断结果；DeepLink 打开失败时仍按既有规则回退 landing。
- `jumpDirectly` 仅保留为源码兼容字段，设置该字段不再绕过 SDK 跳转处理或改变行为。
- CocoaPods 清单显式链接 `AdSupport` 并弱链接 `AppTrackingTransparency`，保持 iOS 11～13 宿主可启动。
- Demo 隐私政策链接仅接受 HTTP/HTTPS，不再调用 `canOpenURL:`。
- 保持优酷专属请求地址、Splash/Interstitial/NativeFeed 三种能力和 `6.1.1` 引入的媒体摇一摇上报接口不变。

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
