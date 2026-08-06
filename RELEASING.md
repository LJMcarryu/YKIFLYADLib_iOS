# 发布流程

优酷 SDK 由私有源码仓 `LJMcarryu/IFLYADLibDemo` 的 `main` 单一源码生成。本仓不接收 SDK 私有源码和手工替换的二进制。

## 1. 在私有源码仓构建

```bash
IFLY_NEW_VERSION_RELEASE=1 \
IFLY_SDK_CODESIGN_IDENTITY='正式 SDK 签名身份' \
scripts/package-youku-release.sh \
  --version 6.1.2 \
  --ad-request-url 'https://youku-sdk.voiceads.cn/ad/request'
```

脚本输出：

```text
build/youku/release/
├── IFLYADLib.xcframework.zip
├── YKIFLYADLib-6.1.2.zip
├── checksums.txt
└── delivery-manifest.json
```

脚本必须通过以下门禁：

- 只包含 Splash、Interstitial、NativeFeed。
- 不包含 Banner、Reward 公开头和类符号。
- 请求地址严格等于获准的优酷专属地址 `https://youku-sdk.voiceads.cn/ad/request`，且不残留通用、历史灰度或旧正式路径请求 URL。
- 目标 URL 的 host 已写入 framework、外置资源和 SwiftPM 资源的 `NSPrivacyTrackingDomains`。
- device 为 arm64，simulator 为 arm64/x86_64。
- 最低系统版本为 iOS 11.0。
- 外置 `IFLYPlayer.bundle` 包含 `PrivacyInfo.xcprivacy`。
- 源码仓必须是干净提交；优酷发布版本必须与获准版本、运行时 SDK 版本、XCFramework 和交付清单一致，不改变其他渠道的版本。
- `xcodebuild -version` 必须不高于 Xcode 26.2；本地超版本验证产物不得发布。
- 正式命令必须设置 `IFLY_SDK_CODESIGN_IDENTITY`；两个切片的 framework 签名均须完整、非 ad-hoc 且 TeamIdentifier 一致。
- 正式发布时设置 `IFLY_NEW_VERSION_RELEASE=1`，对两个 zip 执行 Apple 审核扫描并保留报告；分发发布与宿主审核闭环分别记录。
- iOS 14 及以上只有 ATT `authorized` 状态可读取或接受 IDFA；撤权清缓存，普通请求与 S2S 请求使用同一门控。
- 二进制与 Demo 均不得调用 `canOpenURL:`；DeepLink 使用系统打开完成回调判定结果，失败时保留 landing 回退，`jumpDirectly` 保持兼容 no-op。
- CocoaPods 消费侧显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，并通过 iOS 11 消费 Demo 的启动与依赖门禁。

### 当前联调状态

2026 年 7 月 30 日已使用模拟器产物，在 iOS 26.2 上完成 Demo 构建、启动和三个自渲染示例入口点验。六个优酷定制广告位均已从对应页面发起请求：自渲染开屏图片/视频、自渲染插屏图片/视频和自渲染信息流图片/视频；插屏横竖版已确认共用对应的图片广告位 `A830C77F232A5DE10AF0E4B92E0426C9` 或视频广告位 `784C8D7CF6CFC970473E3CB1DE893B61`。

2026 年 7 月 31 日使用 Xcode 26.2 重新构建固化 `https://youku-sdk.voiceads.cn/ad/request` 的 device arm64 与 simulator arm64/x86_64 候选包，并以本地 Pod 接入本仓 Demo。六个优酷广告位均至少一次完成 `didLoad`；图片完成 Binder 渲染与曝光，视频完成起播和播放结束，插屏横竖版及半屏/全屏均通过，CTA 触发点击及 `didJumpWithSuccess=YES`。开屏图片首次请求返回一次 `70204`，立即重试成功。该轮为模拟器和 ad-hoc 签名验证；App Store 下载跳转、服务端监测入库及正式签名仍须真机和服务端配合终验。

2026 年 8 月 5 日使用 Xcode 26.2 和批准的开发签名生成优酷 `6.1.1` 正式分发资产。935 项 SDK 单测、Youku 变体构建、CocoaPods Demo、SwiftPM 产品与资源投递均通过；产物已固化媒体摇一摇上报 selector、采样实现和 `6.1.1` 运行时版本。Apple 审核扫描报告单独留存，不把二进制分发完成描述为最终宿主 App 审核闭环。

2026 年 8 月 6 日使用 Xcode 26.2，从私有源码仓提交
`cf68ee40924916bfa4b19943ae8248ff338555f4` 生成优酷 `6.1.2` 正式分发资产。
两个 framework 切片的 `TeamIdentifier` 均为 `FM295M5CZ5`；SDK 950 项测试和
Demo 128 项测试全部通过。

本次 Apple 审核扫描仍以 `high` 阈值阻断确定性失败，并原样保留
`RRA-003`、`TRACK-001/002`、`SRC-009`、`ADS-011` 等启发式、人工复核或
最终宿主责任状态，不将其改写为已通过。该风险边界只绑定优酷 `6.1.2`、
上述源码提交和本次归档产物，不延伸到后续版本、最终宿主 App 或新增数据链路；
二进制分发完成不代表最终宿主 App 审核和合规证据已闭环。

## 2. 更新分发清单

- 将 `Package.swift` 中的 URL、版本和 checksum 替换为 `checksums.txt` 的结果。
- 用源码仓 `build/youku/swiftpm-resources/IFLYPlayer.bundle` 同步覆盖本仓 `spm/IFLYAdResources/IFLYPlayer.bundle`。
- 将 `YKIFLYADLib.podspec`、Demo `Podfile`、README、CHANGELOG 中的版本同步更新。
- 确认 podspec 显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，并核对最终二进制没有对 `AppTrackingTransparency` 的强依赖。
- `swift package dump-package` 和 `pod ipc spec YKIFLYADLib.podspec` 必须通过；Release 可下载后再执行完整 pod lint。
- Release CI 固定使用获准的正式完整 URL `https://youku-sdk.voiceads.cn/ad/request`，并与 manifest 和二进制逐项比对；变更地址必须同步修改构建脚本、隐私清单和本门禁。

## 3. 提交和发布

1. 提交本仓清单、Demo 与文档。
2. 创建与 SDK 版本一致且不带 `v` 前缀的 tag。
3. 创建 GitHub Release，上传两个 zip 以及 `checksums.txt`、`delivery-manifest.json`。
4. Release CI 验证精确资产白名单、两个 zip 的同源 XCFramework、URL、架构、隐私清单、SwiftPM 产品/资源和 CocoaPods Demo 编译。

分发仓及 Release 必须保持 Public，确保 CocoaPods raw URL、SwiftPM 仓库和二进制资产均可匿名访问。每次发布后都要在不携带 GitHub 凭据的环境中验证仓库、podspec 和两个 Release 资产可下载。

已发布的 tag 和 zip 不允许覆盖重打；任何二进制变化都必须发布新版本。
