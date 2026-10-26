# 优酷定制 IFLYADLib iOS SDK


本仓库提供面向 iOS 应用的优酷定制广告 SDK，包含开屏、插屏和自渲染信息流，以及安装说明和 Objective-C 示例。

当前正式版本：[`6.4.4`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.4.4)。生产项目请固定具体版本。

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.4.4","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.4.4"} -->

[运行示例](IFLYADLibSimple/README.md) · [安装方式](docs/接入指南/安装方式.md) · [隐私与请求配置](docs/接入指南/隐私与请求配置.md) · [更新记录](CHANGELOG.md) · [排错](docs/接入指南/生命周期与排错.md) · [支持](#隐私许可与支持)

## 能力与接入身份

| 广告形式 | 公开入口 | 展示方式 |
| --- | --- | --- |
| 开屏 | `IFLYSplashAd` | SDK 渲染，图片或视频 |
| 插屏 | `IFLYInterstitialAd` | SDK 渲染，半屏或全屏，图片或视频 |
| 自渲染信息流 | `IFLYNativeFeedAd` | 宿主渲染 UI，SDK 管理绑定后的交互和视频 |

本包不提供 Banner、激励视频。所有格式均支持图片与视频，实际素材由广告位返回。

| 项目 | 接入值 |
| --- | --- |
| CocoaPods Pod | `YKIFLYADLib` |
| SwiftPM product | `IFLYADLib` |
| framework / 导入模块 | `IFLYADLib` |
| 外置资源 | `IFLYPlayer.bundle` |
| 链接要求 | 静态 XCFramework；最终 App 保留 `$(inherited)` 和 `-ObjC`，选择 **Do Not Embed** |
| 同一 App 的选择 | CocoaPods、SwiftPM、手动集成三选一；只安装一份 SDK 发行包 |

类和方法使用 `IFLY*` 命名。优酷版与标准 `IFLYADLib` 含相同公开符号，不要在同一个 App 中同时链接。

```objc
#import <IFLYADLib/IFLYADLib.h>
```

## 环境要求

| 项目 | 要求 |
| --- | --- |
| 最低系统 | iOS 11.0 |
| 二进制接入 | 能使用 XCFramework 的 Xcode |
| SwiftPM 清单 | Swift tools 5.9；需由能解析该清单的 Xcode 使用 |
| 示例 | macOS、Xcode、CocoaPods；真机需配置自己的 Team 与 Bundle ID |

包清单版本不单独代表全部 Xcode 的二进制兼容性。运行示例后的检查方法与模拟器、真机验证边界见 [Simple 指南](IFLYADLibSimple/README.md)；具体版本的构建及消费验证记录见同版 Release。

## 安装

推荐通过精确版本的公开 Podspec URL 安装，将 `YourApp` 替换为实际 target：

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'

target 'YourApp' do
  use_frameworks!
  pod 'YKIFLYADLib',
      :podspec => 'https://raw.githubusercontent.com/LJMcarryu/YKIFLYADLib_iOS/6.4.4/YKIFLYADLib.podspec'
end
```

```bash
pod install
open YourApp.xcworkspace
```

CocoaPods 自动投递 `IFLYPlayer.bundle`、传播 `-ObjC` 并处理 `AdSupport` 与弱链接 `AppTrackingTransparency`。保留完整 Podspec URL，不使用仅填写 Pod 名和版本的 trunk 安装方式。

[SwiftPM 精确版本与手动集成](docs/接入指南/安装方式.md)中提供产品选择、完整包资产名、资源和链接设置。

## 最小使用流程

先取得分配给当前 App、渠道和格式的广告位，完成宿主隐私流程，再发起请求。首次接入可使用默认请求配置；交易参数仅在平台明确约定后填写，见[请求配置](docs/接入指南/隐私与请求配置.md)。

内置开屏、插屏：强持有广告对象并设置代理 → 调用 `loadAd` 或 `loadAdWithRequestConfig:` → 等待 `DidReady` → 在业务允许展示时检查 `isAdValid`、前台状态和展示页面 → 调用展示接口 → 结束后清理。`DidLoad` 只表示数据已返回。

自渲染信息流：强持有 `IFLYNativeFeedAd` → 加载 → `nativeFeedAdDidLoad:` → 宿主准备 UI 和图片 → 主线程 attach。它没有 `DidReady`，绑定成功也不等于曝光。列表正常离屏立即按具体 Cell 容器 detach，回屏仍有效时可重新 attach；过期、关闭或销毁后须新建实例。

失败、无填充或放弃等待时让业务继续；开屏分别处理等待超时、失败、跳过和关闭，并保证进入后续页面只执行一次。内置开屏、插屏完成或永久放弃后置空 delegate、销毁并释放实例；NativeFeed 按对应绑定与列表生命周期清理。不要在广告临时覆盖页面触发的 `viewDidDisappear:` 中无条件销毁。详见[生命周期与排错](docs/接入指南/生命周期与排错.md)。

**SDK 的内置格式能力与示例 API 覆盖范围不同**：Simple 的自渲染开屏、自渲染插屏和信息流三个页面全部使用 `IFLYNativeFeedAd`，前两者演示宿主自建视觉布局。内置 `IFLYSplashAd`、`IFLYInterstitialAd` 接入请看各格式指南。

## 按广告形式接入

| 广告形式 | 接入指南 | 示例源码与覆盖范围 |
| --- | --- | --- |
| 开屏 | [开屏指南](docs/接入指南/开屏广告.md) | 内置 API 代码见指南；[自渲染视觉示例](IFLYADLibSimple/IFLYADLibSimple/biz/native/presentation/IFLYNativeFeedPresentationDemoViewController.m) |
| 插屏 | [插屏指南](docs/接入指南/插屏广告.md) | 内置 API 代码见指南；与上行共用自渲染视觉示例 |
| 自渲染信息流 | [NativeFeed 指南](docs/接入指南/自渲染信息流.md) | [列表页面](IFLYADLibSimple/IFLYADLibSimple/biz/native/IFLYNativeViewController.m) |

[服务端竞价与结果通知](docs/接入指南/服务端竞价.md)仅供已开通相应流程的媒体使用，普通接入直接使用上述加载流程。

## 隐私、许可与支持

`setPersonalizedEnabled:` 仅记录状态，不过滤或改写 IDFA、CAID、UA、请求字段或广告行为，也不替代隐私同意与 ATT 授权。宿主控制请求时机与传入信息；iOS 14 及以上仅在 ATT `authorized` 时读取、传入 IDFA。详情见[隐私与请求配置](docs/接入指南/隐私与请求配置.md)。

[SDK 隐私政策](https://aimarx.com/help-center/sdk-privacy-policy) · [使用许可](LICENSE) · [安全问题私密报告](SECURITY.md) · [普通接入问题 Issues](https://github.com/LJMcarryu/YKIFLYADLib_iOS/issues)

反馈时提供 SDK/iOS/Xcode 版本、安装方式、广告形式、复现步骤与错误码；去除 IDFA、CAID、token、用户信息和敏感 URL。发布版日志仅保留错误与诊断，日志开关不会恢复已裁剪的请求/响应详情。

## 原章节入口

### 初始化、隐私和请求配置

请见[初始化、隐私和请求配置](docs/接入指南/隐私与请求配置.md)。

### 开屏广告

请见[开屏广告](docs/接入指南/开屏广告.md)。

### 插屏广告

请见[插屏广告](docs/接入指南/插屏广告.md)。

### 自渲染信息流

请见[自渲染信息流](docs/接入指南/自渲染信息流.md)。

### 优酷媒体摇一摇

请见[优酷媒体摇一摇](docs/接入指南/自渲染信息流.md#优酷媒体摇一摇)。

### S2S 和 Header Bidding

请见[S2S 和 Header Bidding](docs/接入指南/服务端竞价.md)。

### 错误处理与生命周期

请见[错误处理与生命周期](docs/接入指南/生命周期与排错.md)。

### 示例工程

请见[示例工程](IFLYADLibSimple/README.md)。

### 常见问题

请见[常见问题](docs/接入指南/生命周期与排错.md#常见问题)。

### 反馈与支持

请见[反馈与支持](#隐私许可与支持)。
