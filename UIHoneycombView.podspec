Pod::Spec.new do |spec|

  spec.name         = "UIHoneycombView"
  spec.version      = "0.0.1"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/onebuffer/UIHoneycombView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Cao Phuoc Thanh" => "caophuocthanh@gmail.com" }

  spec.ios.deployment_target = "12.1"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/onebuffer/UIHoneycombView.git", :tag => "#{spec.version}" }
  spec.source_files  = "UIHoneycombView/**/*.{h,m,swift}"

end
