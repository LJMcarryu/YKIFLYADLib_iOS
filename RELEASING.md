# 发布流程

优酷 SDK 由私有源码仓 `LJMcarryu/IFLYADLibDemo` 的 `main` 单一源码生成。本仓不接收 SDK 私有源码和手工替换的二进制。

## 1. 在私有源码仓构建

```bash
IFLY_NEW_VERSION_RELEASE=1 \
IFLY_SDK_CODESIGN_IDENTITY='正式 SDK 签名身份' \
scripts/package-youku-release.sh \
  --version 6.0.14 \
  --ad-request-url 'https://youku-sdk.voiceads.cn/sdk/req'
```

脚本输出：

```text
build/youku/release/
├── IFLYADLib.xcframework.zip
├── YKIFLYADLib-6.0.14.zip
├── checksums.txt
└── delivery-manifest.json
```

脚本必须通过以下门禁：

- 只包含 Splash、Interstitial、NativeFeed。
- 不包含 Banner、Reward 公开头和类符号。
- 请求地址严格等于 `https://youku-sdk.voiceads.cn/sdk/req`，且不残留标准普通请求 URL。
- 专属 URL 的 host 已写入 framework、外置资源和 SwiftPM 资源的 `NSPrivacyTrackingDomains`。
- device 为 arm64，simulator 为 arm64/x86_64。
- 最低系统版本为 iOS 11.0。
- 外置 `IFLYPlayer.bundle` 包含 `PrivacyInfo.xcprivacy`。
- 源码仓必须是干净提交，参数版本必须与 SDK 和 XCFramework 版本一致。
- `xcodebuild -version` 必须不高于 Xcode 26.2；本地超版本验证产物不得发布。
- 正式命令必须设置 `IFLY_SDK_CODESIGN_IDENTITY`；两个切片的 framework 签名均须完整、非 ad-hoc 且 TeamIdentifier 一致。
- 正式发布时设置 `IFLY_NEW_VERSION_RELEASE=1`，对两个 zip 执行 Apple 审核扫描。

### 当前联调状态

2026 年 7 月 30 日已使用固化正式地址的模拟器产物，在 iOS 26.2 上完成 Demo 构建、启动和五个示例入口点验。自渲染开屏页面包含图片/视频开屏入口；自渲染插屏页面包含横竖版、半屏/全屏及图片/视频入口；原“媒体自渲染”页面已统一显示为“自渲染信息流示例”。横版视频自渲染插屏已确认使用广告位 `284707795BA1F6A692D315CD02CDD78D` 发起请求。

当前模板开屏、模板插屏、自渲染信息流和新增自渲染视觉示例的联调请求仍收到 `https://youku-sdk.voiceads.cn/sdk/req` 返回的 HTTP 404，SDK 对应回调错误码 `71003`。这只能证明 SDK 地址固化、广告位选择和失败回调链路正确，不能视为真实广告联调通过。创建正式 Release 前必须由服务端确认并开通该 host 下的 `/sdk/req` 路由，并重新验证素材返回、解析、展示和监测。

## 2. 更新分发清单

- 将 `Package.swift` 中的 URL、版本和 checksum 替换为 `checksums.txt` 的结果。
- 用源码仓 `build/youku/swiftpm-resources/IFLYPlayer.bundle` 同步覆盖本仓 `spm/IFLYAdResources/IFLYPlayer.bundle`。
- 将 `YKIFLYADLib.podspec`、Demo `Podfile`、README、CHANGELOG 中的版本同步更新。
- `swift package dump-package` 和 `pod ipc spec YKIFLYADLib.podspec` 必须通过；Release 可下载后再执行完整 pod lint。
- 仓库变量 `YOUKU_AD_REQUEST_URL` 必须配置为获准的正式完整 URL，Release CI 会与 manifest 和二进制逐项比对。

## 3. 提交和发布

1. 提交本仓清单、Demo 与文档。
2. 创建与 SDK 版本一致且不带 `v` 前缀的 tag。
3. 创建 GitHub Release，上传两个 zip 以及 `checksums.txt`、`delivery-manifest.json`。
4. Release CI 验证精确资产白名单、两个 zip 的同源 XCFramework、URL、架构、隐私清单、SwiftPM 产品/资源和 CocoaPods Demo 编译。

仓库为 Private 时，GitHub 仓库权限不会自动解决 CocoaPods raw URL 或 SwiftPM 二进制 URL 的下载鉴权，不能把远程清单宣称为可用交付。正式开放远程接入前，发布负责人必须二选一：

- 将分发仓及 Release 调整为 Public；
- 把 podspec、Package.swift 和文档切换到具备明确鉴权方案的二进制托管地址。

已发布的 tag 和 zip 不允许覆盖重打；任何二进制变化都必须发布新版本。
