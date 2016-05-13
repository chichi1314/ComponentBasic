Pod::Spec.new do |s|

  s.name         = "JPGuideCenter"
  s.version      = "0.0.1"
  s.summary      = "a giude "

  s.description  = <<-DESC
程序启动引导页
                   DESC

  s.homepage     = "https://github.com/chichi1314"
  s.screenshots  = "https://github.com/agdsdl/DLSlideView/raw/master/Images/demo1.jpg", "https://github.com/agdsdl/DLSlideView/raw/master/Images/demo2.jpg"


  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { 'chichi1314' => '865489714@qq.com' }
  s.social_media_url   = "http://weibo.com/u/1421886475"

  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/chichi1314/ComponentBasic.git", :tag => s.version.to_s }
  s.source_files  = "ComponentBasic/JPGuide/*.{m,h}"

  s.requires_arc = true

end