# 优酷定制 Simple 使用指南

本工程用于联调优酷定制 iOS SDK `6.3.7` 的自渲染广告。示例使用公开模块 `IFLYADLib`，安装包名称为 `YKIFLYADLib`，最低支持 iOS 11.0。完整安装方式与 SDK API 说明见[仓库 README](../README.md)。

> 当前示例对应优酷 `6.3.7` 候选，尚未发布；公开正式版仍为 [`6.3.6`](https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.3.6)，包含 UIScene 展示、落地页、外跳回流、曝光和 UI 生命周期适配。 已发布的历史 Tag、Release 和资产保持不可变。


## 示例范围

| 首页入口 | 实际使用的 API | 可以体验的内容 |
| --- | --- | --- |
| 自渲染开屏 | `IFLYNativeFeedAd` | 图片 / 视频的开屏视觉布局、倒计时、关闭、广告点击及落地页返回 |
| 自渲染插屏 | `IFLYNativeFeedAd` | 图片 / 视频、横竖素材布局、半屏 / 全屏、关闭与视频封面 |
| 自渲染信息流示例 | `IFLYNativeFeedAd` | 真实列表中的图文 / 视频卡片、Cell 复用、离屏回屏、媒体摇一摇接口 |

三个页面都由示例自己创建 UI。SDK 本身还提供内置开屏 `IFLYSplashAd` 和内置插屏 `IFLYInterstitialAd`，但这里的视觉页面不会调用它们；接入内置格式时参考[根 README](../README.md#开屏广告)，其展示配置与回调也不同。优酷包不提供 Banner 和激励视频。

## 从下载到运行

准备 macOS、Xcode 和 CocoaPods。选择可用的 iPhone / iPad 模拟器，或连接已配置签名的真机。

```bash
git clone https://github.com/LJMcarryu/YKIFLYADLib_iOS.git
cd YKIFLYADLib_iOS/IFLYADLibSimple
pod install
open IFLYADLibSimple.xcworkspace
```

1. 确认 `pod install` 成功；[Podfile](Podfile) 使用 `6.3.7` 候选 Tag 的公开 Podspec URL，不需要另行在公共索引搜索定制 Pod。
2. 打开 `IFLYADLibSimple.xcworkspace`，不要只打开 `.xcodeproj`。
3. 选择 `IFLYADLibSimple` scheme 和运行设备。真机运行前，在 **Signing & Capabilities** 中选择自己的 Team，并填写可签名的 Bundle ID。
4. 按下方说明替换广告位，确认该 Bundle ID 等应用信息已在平台配置。
5. 运行后完成隐私流程，首页显示 SDK 版本与三个自渲染入口。进入页面前确认版本符合预期。

CocoaPods 会链接 `IFLYADLib`，复制 `IFLYPlayer.bundle` 并传递 `-ObjC`。不要再手动添加同一份 framework，或同时安装标准 `IFLYADLib` 包。

命令行构建可在本目录执行：

```bash
xcodebuild -showdestinations \
  -workspace IFLYADLibSimple.xcworkspace -scheme IFLYADLibSimple

xcodebuild build \
  -workspace IFLYADLibSimple.xcworkspace -scheme IFLYADLibSimple \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

构建成功只验证编译、链接和资源集成。真实广告填充、跳转、视频、ATT、传感器及监测结果仍需在适用设备和广告位上联调。

## 配置广告位和请求

广告位集中在 [IFLYAdPrefixHeader.pch](IFLYADLibSimple/Supporting%20Files/IFLYAdPrefixHeader.pch)。保留宏名，替换字符串值；请向平台取得自己应用对应的优酷广告位，不要把演示值用于生产投放。

| 场景 | 需要修改的宏 |
| --- | --- |
| 开屏图片 | `__SPLASH_NATIVE_AD_UNIT_ID__` |
| 开屏视频 | `__SPLASH_VIDEO_AD_UNIT_ID__` |
| 插屏竖图 | `__INTERSTITIAL_AD_UNIT_ID__` |
| 插屏横图 | `__INTERSTITIAL_LANDSCAPE_IMAGE_AD_UNIT_ID__` |
| 插屏竖视频 | `__INTERSTITIAL_PORTRAIT_VIDEO_AD_UNIT_ID__` |
| 插屏横视频 | `__INTERSTITIAL_LANDSCAPE_VIDEO_AD_UNIT_ID__` |
| 信息流图文 | `__TYPED_ONE_NATIVE_AD_UNIT_ID__` |
| 信息流视频 | `__FEED_VIDEO_AD_UNIT_ID__` |

演示使用八个独立联调广告位，插屏横竖方向分别使用对应的图片或视频广告位；请确保平台配置的素材方向与所选布局一致。图片按钮要求单图素材，视频按钮要求视频素材；类型不匹配时页面会报错。

公共请求配置在 [IFLYADUtil.m](IFLYADLibSimple/Supporting%20Files/IFLYADUtil.m) 的 `mediaSampleRequestConfig`：当前读取宿主名称和版本，设置 5 秒超时、`settleType = 1`、`bidFloor = 0.01`、`interactStatus = 1`，并按系统授权状态提供 IDFA。交易参数是演示配置，正式接入应使用平台约定值。页面通过 `loadAdWithRequestConfig:` 发起普通请求；本示例没有 S2S 或竞价操作入口。

## 首次隐私流程

首次启动先显示隐私页面，可以打开[SDK 隐私政策](https://aimarx.com/help-center/sdk-privacy-policy)。选择“同意并继续”后才会配置 SDK、进入首页并尝试申请 ATT。页面本身不自动请求广告，进入并操作对应示例后才会加载。

同意记录保存在本地，下次启动直接进入首页。需要重新验证首次体验时，可删除示例 App 后重新安装。选择“不同意并退出应用”会结束本演示进程；宿主接入时应按自己的产品流程处理拒绝选择，不要直接复制示例退出行为。

iOS 14 及以上，示例只在 ATT `authorized` 时读取 IDFA；拒绝授权后仍可进入示例，IDFA 为空不等于 SDK 安装失败。系统可能因现有授权或设备设置不再次显示弹窗。授权发生变化后重新发起请求，示例会重新读取当前状态。

工程的 **Build Settings → Privacy - Tracking Usage Description** 配置演示用途的 ATT 文案（`INFOPLIST_KEY_NSUserTrackingUsageDescription`），构建时写入 App 的 `Info.plist`；[源 Info.plist](IFLYADLibSimple/Info.plist) 为联调 HTTP 素材配置 `NSAllowsArbitraryLoads`。移植到宿主时应采用符合实际用途的文案和网络配置。`setPersonalizedEnabled:` 只记录选择，不替代 ATT，也不会阻止或改写请求、标识符和监测；参见[隐私与请求配置](../README.md#初始化隐私和请求配置)。

## 自渲染开屏

入口文件：[IFLYNativeFeedPresentationDemoViewController.m](IFLYADLibSimple/biz/native/presentation/IFLYNativeFeedPresentationDemoViewController.m)。

1. 在首页选择“自渲染开屏”。
2. 点击“加载图片开屏广告位”或“加载视频开屏广告位”。此时创建 Ad 并发出请求，状态区显示加载中。
3. 数据返回后，页面校验素材类型并准备图片/封面和 UI，然后弹出示例广告页面；页面进入 window、布局完成后再绑定 SDK。
4. 广告满足可见条件后可观察 `nativeFeedAdDidExpose:`。视频从静音开始，实际起播后收到 `nativeFeedAdDidStartPlay:`。
5. 图片开屏从绑定完成开始显示 5 秒倒计时。可以点击关闭；倒计时结束也会关闭。视频开屏还会在播放完成时关闭。这些是本示例的页面行为。
6. 对可点击广告，点击已注册区域会进入 SDK 跳转。进入落地页时暂停示例倒计时，返回后恢复剩余时间；点击事件与跳转成功分别记录。
7. 广告关闭后回到操作页面，可以重新加载。当前广告仍在展示或关闭过程中时，重复加载操作会被忽略。

操作页面的“状态与回调日志”显示加载、绑定、曝光、点击、跳转、播放和关闭信息。没有填充时显示请求错误，不会弹出空广告页面。

## 自渲染插屏

入口与开屏共用上述控制器，布局实现在 [IFLYNativeFeedDemoPresentationView.m](IFLYADLibSimple/biz/native/presentation/IFLYNativeFeedDemoPresentationView.m)。

1. 选择“自渲染插屏”。
2. 在“插屏素材方向”选择竖版或横版，在“插屏展示形态”选择半屏或全屏，再点击图片或视频加载按钮。
3. 素材及 UI 准备完成后自动弹出示例页面。与开屏一样，先绑定，再按真实可见状态触发曝光；这不是 `interstitialAdDidReady:` / `showAdFromRootViewController:` 的调用流程。
4. 验证布局、关闭按钮、实际 CTA、静音按钮和落地页返回。视频完成后显示伴随图片/封面，等待用户关闭；发生视频播放失败时示例关闭本次展示。
5. 关闭后再选择其他布局并加载；已有广告不会因切换选项自动更改素材。

半屏/全屏与横竖方向是两组不同选项。这里只测试宿主自建 NativeFeed 页面；内置插屏应使用 `IFLYInterstitialAdConfig.presentationStyle`。

## 自渲染信息流示例

入口文件：[IFLYNativeViewController.m](IFLYADLibSimple/biz/native/IFLYNativeViewController.m)。页面使用真实 `UITableView`，包含普通内容行和固定广告条目。

1. 选择“自渲染信息流示例”，默认是“图文”。
2. 向下滚动到第 5 个条目（前面有 4 行普通内容）。广告条目进入显示范围后才发起请求；未滚动到广告时，“等待广告条目进入屏幕”是正常状态。
3. 请求成功后读取公开 `adData`，绘制卡片并绑定。保持卡片至少 2/3 可见、连续 500ms，观察顶部的曝光状态提示。
4. 继续滚动使卡片完全离屏，再滚回。广告有效期间保留同一 Ad，重新绑定当前 Cell，已发生的曝光不重复计数。
5. 切换“视频”，当前广告会清理并创建对应的新条目；若条目不在屏幕上，等它再次进入显示范围后才加载。视频起播后封面隐藏，暂停或完播后显示相应状态。
6. 点击卡片的可点击区域进行跳转测试；点击“×”关闭广告。关闭后的 Ad 被清理，不能把它当成普通离屏条目再绑定；后续重新加载会创建新 Ad。
7. 切换图文/视频、快速滚动、进入落地页再返回、切换前后台，检查图片和视频是否仍属于当前卡片。

数据层按稳定条目持有 Ad；Cell 在 `willDisplay` 中渲染并 attach，在 `didEndDisplaying` / `prepareForReuse` 中立即对自己的容器 detach。不要用过期 `indexPath` 查找 Ad，也不要将解绑异步延后。永久删除条目或退出页面时，清理容器、delegate 和 Ad 引用。可恢复的列表条目正常离屏不调用 `destroy`。

### 媒体摇一摇入口

导航栏的“媒体摇一摇上报”按钮用于手动验证公开方法 `reportMediaShakeTriggeredWithError:`，本示例没有实现宿主的传感器判定算法。SDK 也不会在该定制模式下自主触发 NativeFeed 摇一摇点击。

先让当前广告自然曝光并保持有效可见，再点击该按钮。它代表“宿主已判定摇一摇发生”，接受后进入真实广告点击流程，可能打开落地页；不要把它当成无副作用的状态查询。生产接入只在宿主实际识别到事件后调用。

调用必须在主线程。`YES` 表示事件已接受，不保证取得传感器样本或跳转成功；同一已加载广告最多接受一次，离屏再回屏不会重置；已经处理普通点击后不能重复上报。是否允许调用不以 `interactionType`、`interactType`、素材类型或目标地址为筛选条件。失败时读取 `IFLYAdError`：

| 错误码 | 含义 / 操作 |
| --- | --- |
| `71512` | 当前安装包不支持此接口能力；检查是否误接了其他渠道的包 |
| `71513` | 尚未自然曝光或当前不满足可见条件；让广告进入有效显示范围 |
| `71514` | 已处理点击或已有点击正在处理；不要对同一广告重复上报 |
| `71515` | 调用不在主线程；修正调用位置 |

真机验证传感器、外跳和授权行为；模拟器中的按钮调用不能证明真实摇动识别正确。接口详情见[媒体摇一摇](../README.md#优酷媒体摇一摇)。

## 回调如何判断

| 事件 | 说明 |
| --- | --- |
| `nativeFeedAdDidLoad:` | 数据可读，可开始宿主 UI 渲染；不保证宿主图片已经下载 |
| `nativeFeedAdDidRender:` | 本次容器绑定成功，不等于已曝光 |
| `nativeFeedAdDidExpose:` | 达到有效曝光条件并执行曝光处理；不代表服务端统计已入库 |
| `nativeFeedAdDidClick:` | 已处理广告点击；是否成功跳转看 `nativeFeedAd:didJumpWithSuccess:` |
| `nativeFeedAdDidStartPlay:` / `nativeFeedAdDidResumePlay:` | 视频实际开始 / 恢复播放 |
| `nativeFeedAdDidPausePlay:` / `nativeFeedAdDidPlayFinish:` | 视频暂停 / 完播；页面如何收尾由示例场景决定 |
| `nativeFeedAdDidClose:` | 广告关闭，可清理条目；与落地页返回回调区分 |
| `didFailWithError:` / `didFailToRenderWithError:` / `didFailToPlayWithError:` | 分别定位请求流程、绑定/渲染、视频播放错误 |
| `didRejectClickWithError:` | 已绑定的点击没有通过当前视图检查；不要补报或自行跳转 |

视觉页面有页内日志。信息流页面以顶部状态和 Xcode Console 为主，并未实现上表全部可选代理方法；需要观察点击或跳转细节时可按公开协议添加对应方法，或参考视觉页面的已有实现。

## 常见问题

| 现象 | 排查步骤 |
| --- | --- |
| `pod install` 下载或 TLS 失败 | 检查到 GitHub、`raw.githubusercontent.com` 及 CocoaPods CDN 的网络连接和代理；连接恢复后重试，保留固定版本 URL |
| 找不到模块或链接报错 | 确认安装成功且打开 workspace；检查 scheme、`-ObjC`、重复 framework 和资源投递 |
| 真机签名失败 | 设置自己的 Team 和 Bundle ID，并确认设备已包含在签名配置中 |
| 首页未出现 ATT 弹窗 | 先完成隐私同意，再查看设备系统版本与现有 ATT 状态；授权不会每次启动都弹出 |
| 信息流没有请求 | 先把第 5 个条目滚入屏幕；查看广告位宏是否为空 |
| `70204` 无填充 | 核对广告位、应用信息及投放条件；无填充不等于构建失败，不要连续无限重试 |
| `70400` / `71005` | 核对广告位是否有效、是否为空、是否属于当前优酷应用和广告形式 |
| `71003` / `71006` | 检查网络与超时，记录发生阶段和错误描述 |
| 返回素材与按钮不匹配 | 确认平台配置为预期图片或视频；切换布局不会更改实际素材类型 |
| `71502` / `71504` | 检查广告容器或视频承载视图是否存在、层级和尺寸是否有效 |
| `71503` 点击被拒绝 | 保存完整 `[71503/<point>]` 错误描述，检查点击视图、可见性及绑定关系；不要补跳转 |
| 已绑定却无曝光 / 视频不播放 | 检查前台、可见面积与持续时间；卡片不能被遮挡；绑定完成不等于已曝光 |
| 回屏后不能恢复 | 检查是否过期、已关闭或已销毁；这些情况下应创建新 Ad |
| 有曝光回调但统计未看到 | 回调不能证明统计入库；通过约定支持渠道核对时间、广告位及监测结果 |

示例在同意隐私后开启 SDK 日志。可在 [IFLYDemoRootCoordinator.m](IFLYADLibSimple/privacy/IFLYDemoRootCoordinator.m) 调整；正式宿主建议关闭，仅在排错时开启。SDK 发布包日志量有限，完整排查需同时保存代理错误码和重现步骤。

## 移植到宿主前

保留自己的隐私流程、导航和业务生命周期；按需要参考单个页面、公共请求配置和 Binder 构造，不需要复制整个 App。自渲染 UI 应清楚标识广告，保持广告内容、CTA 与关闭按钮的正确绑定。

完成图文/视频、关闭、跳转与回流、快速滚动和前后台测试。另行验证 iOS 最低支持版本、真机传感器、真实广告位填充及监测结果。通过 [Issues](https://github.com/LJMcarryu/YKIFLYADLib_iOS/issues) 反馈时提供 SDK / iOS / Xcode 版本、接入方式、页面与按钮、重现步骤及错误码，去除 IDFA、token、用户信息和完整请求内容。
