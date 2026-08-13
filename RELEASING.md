# 发布流程

优酷 SDK 由私有源码仓 `LJMcarryu/IFLYADLibDemo` 的 `main` 单一源码生成。本仓不接收 SDK 私有源码和手工替换的二进制。

## 正式发布唯一入口

新版本正式发布只能从内部私有源码仓根目录的 `scripts/release-orchestrator.py` 发起，并按
`prepare → preflight → publish → verify → closeout` 顺序完成。先用默认只读计划确认候选身份，
只有在版本、Xcode、签名和冻结条件满足时才可为对应阶段显式传入 `--execute`。不得从本公开仓
手工创建或移动 tag、发布 Release，也不得直接派发 candidate 工作流来替代编排器 receipt。

本文后续的打包命令、`.github/scripts/**`、公开仓校验命令和 GitHub Actions
`workflow_dispatch` 都是底层门禁或故障诊断入口，可用于定位和复验单项问题，但不是正式发布
入口。CI 对同一候选的复验顺序排队且不取消既有 run；候选与正式 Release 使用不同并发组。
重型验证 job 最长运行 55 分钟，结束后由无 Token、只读的 summary job 汇总 Candidate、Release、
checkout commit、四资产库存身份和全部 job 结论；summary 对上游失败继续失败关闭。

## 6.2.3 发布状态

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`11bd2827041cd245329d12e959310f77d76b7ddd`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`6b2b21020589d3b96534167e9cb94b5a9fb76fa1`

正式签名资产、checksum 和 A/B 已完成本地冻结校验；公开可用性以同版本 GitHub Release 和发布后 CI 为准，发布后事实由编排器验证。

`releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结；公开可用性以同版本 GitHub Release 和发布后 CI 为准。

`6.2.3` 不沿用历史风险授权；主动 Apple Review 扫描策略固定为 `failOn=high`、`failOnWarning=true`、`strict=true`、`requireManual=true`、`acceptedWarningRuleIds=[]`。扫描状态不改写正式发布状态，未扫描不得表述为通过。

## 1. 私有源码仓底层产物诊断

本节命令由编排器调用或供失败定位使用，不得脱离上述唯一入口独立执行为正式发布。

```bash
IFLY_NEW_VERSION_RELEASE=1 \
IFLY_SDK_CODESIGN_IDENTITY='正式 SDK 签名身份' \
scripts/package-youku-release.sh \
  --version 6.2.3 \
  --ad-request-url 'https://youku-sdk.voiceads.cn/ad/request'
```

脚本输出：

```text
build/youku/release/
├── IFLYADLib.xcframework.zip
├── YKIFLYADLib-6.2.3.zip
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
- NativeFeed 公开头、符号和 Demo 必须包含 Ad 级 `attachWithViewBinder:error:`、容器级 `detachAdFromContainerView:` 和可选 `destroy`；列表数据层只持有 Ad，Cell 不持有 Session、Binding 或首次/复用状态。
- NativeFeed 公开头、伞头、二进制 selector、Demo 和接入文档不得再暴露 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 或 `endDisplaySession`。
- 同一 Ad 跨 Cell 串行迁移、同容器原子接管、失败预检不破坏旧挂载、曝光前后重挂载、迟到容器 detach、视频进度/播放意图恢复、活动容器跨 TTL/视频截止时间不强拆及 detach 后失效必须通过专项测试。
- `6.2.3` 还必须验证外部 CTA 默认关闭、同 window/scene 与归属门禁、运行时 71503 delegate 拒绝回调，以及 `detachFromCurrentContainer`。

### 当前联调状态

`releaseState=FORMAL` 表示正式签名资产、checksum、A/B 和 `delivery-manifest.json` 已经冻结；公开可用性以同版本 GitHub Release 和发布后 CI 为准。
`6.2.3` 正式分发资产已冻结；以下均为历史版本事实。

2026 年 8 月 10 日，优酷 `6.2.2` 正式分发资产由私有源码提交
`a8ec925d3731d7d11734647aa02ca7d91d674965` 构建，发布元数据提交
`eff78263c2d3f65b029f4114de1a9ed00f3827f3` 仅回填 checksum、扫描汇总和发布验收事实。
`delivery-manifest.json` 的 `sourceCommit` 与 `sourceBuild.sourceCommit` 均为前者。
`IFLYADLib.xcframework.zip` 的 SHA-256 为
`1ddbe4b12ec95658845b80adb8d4d91b9a9ce778d618b4f1a9ad41d5886d1ddb`，
`YKIFLYADLib-6.2.2.zip` 的 SHA-256 为
`0ba19a49cc09f4dba8b62224ba84a2f8c3447ca7ad959ae7edf06286fd89f0bc`。
产物使用 Xcode 26.2（Build `17C52`）；两个 framework 切片均为非 ad-hoc 开发签名，
证书 SHA-1 为 `767B1F38300A6AACAF2B7AC3A4EA052201D981BB`，`TeamIdentifier` 均为
`FM295M5CZ5`。4 个交付文件已在内部冻结，并已通过
<https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.2> 正式公开；Release 非草稿、
非预发布，资产库存严格为 4 项。annotated tag 解引用后的提交为
`498f148b24bfc8866fff0a0e8575b34d2e2bc542`。
[published CI 31347053230](https://github.com/LJMcarryu/YKIFLYADLib_iOS/actions/runs/31347053230)
结论为 `success`：使用不带 GitHub 凭据的公开 URL 匿名下载精确资产集，校验资产与 A/B
provenance、checksum、双包同源、能力、资源和请求地址，并实际构建 Demo 与 SwiftPM 产品，
同时复核 CocoaPods/SwiftPM 最终链接依赖。该分发验收不代表最终宿主合规、`Validate App`
或 Apple 审核通过。

本轮发布决策仅限通用版/模型 A、YS、优酷 `6.2.2`：接受 `SRC-004`、`SRC-008`、
`SRC-009`、`SRC-011`、`NET-001`、`RRA-003`、`TRACK-001`、`TRACK-002`、
`ADS-011`、`EXPORT-001` 启发式残余风险并允许原样归档，以 `failOn=high`、
`failOnWarning=false`、`strict=false`、`requireManual=false` 继续正式发布。
该确认不代表最终宿主合规或 Apple 审核通过。

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

2026 年 8 月 7 日使用 Xcode 26.2，从私有源码仓提交
`3fcc0007b47a66d82f3134fab2a1eac58b35c94d` 生成优酷 `6.2.1` 正式分发资产。
`IFLYADLib.xcframework.zip` 的 SHA-256 为
`a3c31e6fc523aa2bb1af71849ba1dc893d94e69ae68246eab4d9d20cbb07232f`，
`YKIFLYADLib-6.2.1.zip` 的 SHA-256 为
`8cb718c2895e6e2d7370da6ffab801b8a0aecb6c4452b0fb4ac5b1df3f8b92db`。

两个 framework 切片的 `TeamIdentifier` 均为 `FM295M5CZ5`。SDK
`977/977`、Demo `133/133`、NativeFeed 可复用绑定专项 `27/27`、
Demo 列表专项 `16/16` 和 Youku 分发测试 `31/31` 通过。源码扫描
记录失败 0、风险 11、待人工确认 80、通过 21、未扫描 9；变体产物扫描
记录 1 个 `medium` 确定性失败、风险 12、待人工确认 80、通过 27、未扫描 1。
本次按已批准的 `failOn=high`、`failOnWarning=false`、`strict=false`、
`requireManual=false` 执行，中等结果原样保留但不阻断 SDK 分发；不得由此宣称宿主 App
合规、App Privacy、真机、监测入库、功耗、`Validate App` 或 Apple 人工审核已闭环。
匿名下载和公开仓 CI 是 Release 发布后的独立验收项，不由本节的正式产包事实推定为已通过。

## 2. 编排器分发清单核对

以下清单由编排器生成、冻结和提交；维护者只在失败诊断时逐项复核，不得手工改写后直接发布。

- 将 `Package.swift` 中的 URL、版本和 checksum 与 `checksums.txt` 的真实结果保持一致；`6.2.3` 准备态只允许精确 PENDING 占位，正式冻结后必须回填本次资产的真实 SwiftPM checksum。
- 用源码仓 `build/youku/swiftpm-resources/IFLYPlayer.bundle` 同步覆盖本仓 `spm/IFLYAdResources/IFLYPlayer.bundle`。
- 将 `YKIFLYADLib.podspec`、Demo `Podfile`、README、CHANGELOG 中的版本同步更新。
- 确认 podspec 显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，并核对最终二进制没有对 `AppTrackingTransparency` 的强依赖。
- `swift package dump-package` 和 `pod ipc spec YKIFLYADLib.podspec` 必须通过；创建 tag/Release 前必须确认 checksum 是与冻结 zip 一致的 64 位小写十六进制值，Release 可下载后再执行完整 pod lint。
- Release CI 固定使用获准的正式完整 URL `https://youku-sdk.voiceads.cn/ad/request`，并与 manifest 和二进制逐项比对；变更地址必须同步修改构建脚本、隐私清单和本门禁。

### Draft 候选消费控制面

每个候选使用不可覆盖的 `release-candidate/<version>-<candidateId>` 分支。Draft Release 的
`target_commitish` 只能是该候选分支或触发时的精确提交；`workflow_dispatch` 必须从该分支触发，
并同时提供版本 `candidate_tag`、64 位小写 `candidate_id`、正整数 `candidate_release_id` 和
32 位小写 `dispatch_nonce`。工作流将 checkout 严格绑定到触发 `github.sha`，并把 run name
固定为 `draft-candidate:<candidateId>:<releaseId>:<dispatchNonce>`。候选提交必须已经包含最终
真实 checksum、`releaseState=FORMAL`、两个不同的真实 A/B 提交及最终分发清单；Draft Release
本身仍保持 `draft=true`、`published_at=null`。后续 publish 只改变 `main`、tag 与 Release
可见性，直接使用同一不可变候选提交，不再回填清单或切换提交。候选分支发布后暂不删除，用于
失败恢复和证据复验。

首次启用前，必须先把只包含 workflow、控制脚本和测试的 bootstrap 提交独立合入远端 `main`，
且不得在该提交中修改版本、`Package.swift` 或 `YKIFLYADLib.podspec`。默认分支先识别新 inputs
和 run-name 后，编排器才能可靠派发候选工作流；每版的版本内容门禁仍随候选提交更新。

## 3. 编排器执行结果核对

1. 核对编排器已提交本仓清单、Demo 与文档，并且候选提交与 receipt 记录一致。
2. 核对编排器创建的 annotated tag 与 SDK 版本一致、无 `v` 前缀且指向冻结提交；CI 会拒绝轻量 tag、错误 checkout 和非正式 checksum。
3. 核对编排器发布的 GitHub Release 精确包含两个 zip、`checksums.txt` 和 `delivery-manifest.json`。
4. 核对 Release CI 已验证精确资产白名单、两个 zip 的同源 XCFramework、URL、架构、隐私清单、SwiftPM 产品/资源和 CocoaPods Demo 编译。

分发仓及 Release 必须保持 Public，确保 CocoaPods raw URL、SwiftPM 仓库和二进制资产均可匿名访问。每次发布后都要在不携带 GitHub 凭据的环境中验证仓库、podspec 和两个 Release 资产可下载。

已发布的 tag 和 zip 不允许覆盖重打；任何二进制变化都必须发布新版本。
