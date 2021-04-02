#
# Be sure to run `pod lib lint BlueBillywigPlayerSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

zipfile = "#{__dir__}/BlueBillywigPlayerSDK.zip"

Pod::Spec.new do |s|
  s.name             = 'BlueBillywigPlayerSDK'
  s.version          = '1.4.1.31'

  s.summary          = 'This is the Blue Billywig player SDK.'

  s.description      = <<-DESC
The Blue Billywig player SDK can be used to communicate with our player.
                       DESC

  s.homepage         = 'https://github.com/bluebillywig/playerSdkLibraries.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Floris Groenendijk' => 'f.groenendijk@bluebillywig.com' }

  #system("rm -rf #{zipfile} && zip -r #{zipfile} LICENSE BlueBillywigPlayerSDK.podspec BlueBillywigPlayerSDK.framework > /dev/null")
  #s.source            = { :http => "file://#{zipfile}" }

  s.source           = { :git => 'https://github.com/bluebillywig/playerSdkLibraries.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.platform = :ios, "9.2"

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.vendored_frameworks = 'BlueBillywigPlayerSDK.framework'

  s.frameworks = 'WebKit', 'Foundation', 'CoreGraphics'
end
