# 优酷定制 SDK：Pod 名为 YKIFLYADLib，模块名为 IFLYADLib。

Pod::Spec.new do |s|
  s.name = 'YKIFLYADLib'
  s.module_name = 'IFLYADLib'
  s.version = '6.5.1'
  s.summary = '优酷定制 IFLYADLib：开屏、插屏和自渲染信息流。'
  s.homepage = 'https://github.com/LJMcarryu/YKIFLYADLib_iOS'
  s.author = { 'IFLY' => '讯飞AI营销' }
  s.source = { :http => 'https://download-adsdk.voiceads.cn/ios_sdk/6.5.1/youku/YKIFLYADLib-6.5.1.zip' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.platform = :ios, '11.0'
  s.static_framework = true
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC' }
  # 静态 XCFramework 最终由宿主 App 链接，必须同步传播到 aggregate/user target。
  s.user_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC' }
  s.frameworks = ['AdSupport']
  s.weak_frameworks = ['AppTrackingTransparency']
  s.vendored_frameworks = 'IFLYADLib.xcframework'
  s.resources = ['IFLYPlayer.bundle']
end
