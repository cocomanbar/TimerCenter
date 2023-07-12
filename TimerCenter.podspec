
Pod::Spec.new do |s|
  s.name             = 'TimerCenter'
  s.version          = '1.0.0'
  s.summary          = 'A short description of TimerCenter.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cocomanbar/TimerCenter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cocomanbar' => '125322078@qq.com' }
  s.source           = { :git => 'https://github.com/cocomanbar/TimerCenter.git', :tag => s.version.to_s }
  
  s.swift_version = '5.0'
  s.static_framework = true
  s.ios.deployment_target = '10.0'
  
  s.subspec 'Core' do |a|
      a.source_files = 'TimerCenter/Classes/Core/**/*'
      a.dependency 'TimerCenter/Proxy'
      a.dependency 'TimerCenter/Thread'
  end
  
  s.subspec 'Proxy' do |a|
      a.source_files = 'TimerCenter/Classes/Proxy/**/*'
  end
  
  s.subspec 'Thread' do |a|
      a.source_files = 'TimerCenter/Classes/Thread/**/*'
  end
  
end
