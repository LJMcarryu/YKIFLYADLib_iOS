# 发布流程

## 6.4.4 冻结与发布记录

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.4.4","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.4.4"} -->

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`25ebc73166c9596822cfcf4e93d74fc6c98bd5e4`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`56aaeb4d5b76858b266981d30afd76bff6a73ad2`

`6.4.4` 的正式分发资料以同版本真实冻结 manifest 为准。当前正式版本：[`6.4.4`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.4.4)；公开时间和消费验证结论以 `release-state.json.publication` 与同版本 GitHub Release 的实际状态为准。历史 Tag、Release 和资产保持不可变。


优酷 SDK 由私有源码仓 `LJMcarryu/IFLYADLibDemo` 的 `main` 单一源码生成。本仓不接收 SDK 私有源码和手工替换的二进制。

## 6.4.2 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#642-冻结与发布记录)。

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

## 6.4.1 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#641-冻结与发布记录)。

## 6.4.0 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#640-冻结与发布记录)。

## 6.3.7 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#637-冻结与发布记录)。

## 6.3.6 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#636-冻结与发布记录)。

## 6.3.5 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#635-冻结与发布记录)。

## 6.3.3 历史发布状态

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#633-历史发布状态)。

## 1. 私有源码仓底层产物诊断

以下命令仅在私有源码仓运行，用于本地诊断，输出不构成正式发布资产或 receipt。正式模式由编排器提供 candidate、构建输入与 `--no-rebuild`，不得手工拼接；正式发布仍走上述唯一入口。

```bash
VERSION='<目标版本>'
IFLY_SDK_CODESIGN_IDENTITY='<本机诊断签名身份>' \
scripts/package-youku-release.sh \
  --version "${VERSION}" \
  --ad-request-url 'https://youku-sdk.voiceads.cn/ad/request'
```

脚本输出：

```text
build/youku/release/
├── IFLYADLib.xcframework.zip
├── YKIFLYADLib-<目标版本>.zip
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
- `xcodebuild -version` 必须与所选发布计划的 Xcode version/build 精确一致；诊断产物不得冒充正式资产。
- 正式命令必须设置 `IFLY_SDK_CODESIGN_IDENTITY`；两个切片的 framework 签名均须完整、非 ad-hoc 且 TeamIdentifier 一致。
- 正式发布时设置 `IFLY_NEW_VERSION_RELEASE=1`；编排器默认不执行 Apple Review 扫描，需要时仅通过 `apple-scan --execute` 主动执行并保留报告，扫描状态不改变正式发布结果。分发发布与宿主审核闭环分别记录。
- iOS 14 及以上只有 ATT `authorized` 状态可读取或接受 IDFA；撤权清缓存，普通请求与 S2S 请求使用同一门控。
- 二进制与 Demo 均不得调用 `canOpenURL:`；DeepLink 使用系统打开完成回调判定结果，失败时保留 landing 回退，`jumpDirectly` 保持兼容 no-op。
- CocoaPods 消费侧显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，并通过 iOS 11 消费 Demo 的启动与依赖门禁。
- NativeFeed 公开头、符号和 Demo 必须包含 Ad 级 `attachWithViewBinder:error:`、容器级 `detachAdFromContainerView:` 和可选 `destroy`；列表数据层只持有 Ad，Cell 不持有 Session、Binding 或首次/复用状态。
- NativeFeed 公开头、伞头、二进制 selector、Demo 和接入文档不得再暴露 `IFLYNativeFeedDisplaySession`、`IFLYNativeFeedAdBinding`、`beginDisplaySessionWithError:`、`bindAdWithViewBinder:error:`、`unbindAd` 或 `endDisplaySession`。
- 同一 Ad 跨 Cell 串行迁移、同容器原子接管、失败预检不破坏旧挂载、曝光前后重挂载、迟到容器 detach、视频进度/播放意图恢复、活动容器跨 TTL/视频截止时间不强拆及 detach 后失效必须通过专项测试。
- 按目标版本计划、公开头与 API 变更选择 NativeFeed 回归；历史专项验收见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#635-nativefeed-专项验收)。

### 历史联调与发布证据

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#历史联调与发布证据)。

## 2. 编排器分发清单核对

以下清单由编排器生成、冻结和提交；维护者只在失败诊断时逐项复核，不得手工改写后直接发布。

- 将 `Package.swift` 中的 URL、版本和 checksum 与本次冻结资产及 `checksums.txt` 的真实结果保持一致；正式冻结后必须是本次资产的真实 SwiftPM checksum。
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
真实 checksum、文档 `releaseState=FORMAL`、`release-state.json.phase=FROZEN`、两个不同的真实 A/B 提交及最终分发清单；Draft Release
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

分发仓及 Release 必须保持 Public，确保 CocoaPods raw URL、SwiftPM 仓库和二进制资产均可匿名访问。每次发布后都要在不携带 GitHub 凭据的环境中验证仓库、podspec 和全部四项 Release 资产可下载。

已发布的 tag 和 zip 不允许覆盖重打；任何二进制变化都必须发布新版本。

Apple Review 为主动可选扫描，策略以目标版本计划为准；未运行记录 `not-run`，不得表述为扫描或 Apple 审核通过，历史版本风险授权不沿用。
