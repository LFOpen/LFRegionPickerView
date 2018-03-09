#
#  Be sure to run `pod spec lint LFRegionPickerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LFRegionPickerView"
  s.version      = "0.0.7"
  s.summary      = "简易版地址选择器."
  s.description  = <<-DESC
		一个简单的地址选择器，简化相关的操作
                   DESC

  s.homepage     = "https://github.com/LFOpen/LFRegionPickerView"
  s.license      = "MIT"
  s.author             = { "archerLj" => "lj0011977@163.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/LFOpen/LFRegionPickerView.git", :tag => "#{s.version}" }
  s.source_files  = "LFRegionPickerView/LFRegionPickerView/*.{h,m}"
  s.resource  = "LFRegionPickerView/LFRegionPickerView/location.json"
  s.requires_arc = true
end
