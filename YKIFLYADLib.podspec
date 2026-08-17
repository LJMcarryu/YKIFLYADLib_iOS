# 优酷媒体定制 Model B 单包分发。
# Pod 身份使用 YKIFLYADLib，二进制模块、公开类前缀和资源仍保持 IFLYADLib / IFLY* / IFLYPlayer.bundle。
# 正式合并包由私有源码仓 scripts/package-youku-release.sh 生成。

Pod::Spec.new do |s|
  s.name = 'YKIFLYADLib'
  s.module_name = 'IFLYADLib'
  s.version = '6.2.4'
  s.summary = '优酷定制 IFLYADLib：开屏、插屏和自渲染信息流。'
  s.homepage = 'https://github.com/LJMcarryu/YKIFLYADLib_iOS'
  s.author = { 'IFLY' => '讯飞AI营销' }
  s.source = { :http => 'https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/download/6.2.4/YKIFLYADLib-6.2.4.zip' }
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
