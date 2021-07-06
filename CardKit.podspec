#
#  Be sure to run `pod spec lint CardKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "CardKit"
  spec.version      = "0.0.6"
  spec.summary      = "CardKit SDK."
  spec.homepage     = "https://github.com/Runet-Business-Systems/CardKit"
  spec.license      = "MIT"
  spec.author             = { "RBS" => "rbssupport@bpc.ru" }
  spec.source       = { :git => "https://github.com/Runet-Business-Systems/CardKit.git", :tag => "#{spec.version}" }

  spec.resources =  "CardKit/banks-info", "CardKit/**/*.lproj/*.strings", "CardKit/CardKit/Images.xcassets", "CardKit/ThreeDSSDK.xcframework"

  spec.exclude_files = "CardKit/Carthage/*.{h,m}", "CardKit/Carthage/**/**/*.lproj/*.strings", 'CardKit/CardKitCore/CardKitCore.{h,m}'

  spec.source_files = 'CardKit/CardKit/*.{h,m}', 'CardKit/CardKit/PaymentFlow/*.{h,m,swift}', 'CardKit/CardKitCore/*.{h.m}'

  spec.ios.deployment_target  = '10.0'
end
