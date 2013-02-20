Pod::Spec.new do |s|
  s.name         = "UIView+Badge"
  s.version      = "0.0.1"
  s.summary      = "iOS System Look And Feel Badge in UIView."
  s.homepage     = "https://github.com/hyukhur/UIView-Badge"
  s.license      = { :type => 'FreeBSD License', :file => 'LICENSE' }
  s.author       = { "Hyuk Hur" => "hyukhur@gmail.com" }
  s.source       = { :git => "https://github.com/hyukhur/UIView-Badge.git", :tag => '0.0.1' }
  s.platform   = :ios, '4.3'
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
