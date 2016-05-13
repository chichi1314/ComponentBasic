Pod::Spec.new do |s|
  s.name     = 'JPGuideCenter'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'GuideCenter.'
  s.homepage = 'https://github.com/chichi1314'
  s.author   = { 'chichi1314' => '865489714@qq.com' }
  s.source   = { :git => 'https://github.com/chichi1314/ComponentBasic.git', :tag => '0.0.1' }
  s.platform = :ios  
  s.source_files = 'ComponentBasic/JPGuide1.0.0/*.{h,m}'
  s.resources = "ComponentBasic/pic/*.png"
  s.framework = 'UIKit'

  s.requires_arc = true  
end