Pod::Spec.new do |s|
  s.name         = "Zhi"
  s.version      = "0.0.1"
  s.summary      = "Swift Library for Live Reloading Auto Layout Constraints on iOS"
  s.description  = <<-DESC
Adjust Auto Layout constraints and watch your app update immediately without a rebuild + run cycle. This library allows you to specify your auto layout constraints in separate `.styles` files. In addition to writing constraints using Apple's Visual Format Language as well as an equation-based syntax, the library also supports setting of visual properties during development, such as colors, font (including dynamic type style names) and images.
                   DESC
  s.homepage     = "http://hboon.com/zhi"
  s.license      = { :type => "BSD 2-clause", :file => "LICENSE" }
  s.author             = { "Hwee-Boon Yar" => "hboon@motionobj.com" }
  s.social_media_url   = "https://twitter.com/hboon"
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.source       = { :git => "https://github.com/hboon/Zhi.git", :tag => "#{s.version}" }
  s.source_files  = "Zhi/Zhi/**/*"
  s.dependency "KZFileWatchers"
end
