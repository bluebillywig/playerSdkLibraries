#
# Be sure to run `pod lib lint BlueBillywigPlayerSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlueBillywigPlayerSDK'
  s.version          = '1.4.3'

  s.summary          = '[DEPRECATED] Use BlueBillywigNativeShared-iOS instead.'

  s.description      = <<-DESC
This SDK is deprecated and no longer maintained.
Please migrate to the current Blue Billywig Native Player SDK: BlueBillywigNativeShared-iOS.
                       DESC

  s.homepage         = 'https://support.bluebillywig.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Blue Billywig' => 'tech@bluebillywig.com' }

  s.source           = { :git => 'https://github.com/bluebillywig/playerSdkLibraries.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.platform = :ios, "9.2"

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.vendored_frameworks = 'BlueBillywigPlayerSDK.framework'

  s.frameworks = 'WebKit', 'Foundation', 'CoreGraphics'

  s.deprecated = true
  s.deprecated_in_favor_of = 'BlueBillywigNativeShared-iOS'
end
