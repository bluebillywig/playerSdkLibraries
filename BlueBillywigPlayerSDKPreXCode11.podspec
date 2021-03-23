Pod::Spec.new do |s|
  s.name             = 'BlueBillywigPlayerSDKPreXCode11'
  s.version          = '1.4.1.28'

  s.summary          = 'This is the Blue Billywig player SDK for xcode 10 and below.'

  s.description      = <<-DESC
The Blue Billywig player SDK can be used to communicate with our player.
                       DESC

  s.homepage         = 'https://github.com/bluebillywig/playerSdkLibraries.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Floris Groenendijk' => 'f.groenendijk@bluebillywig.com' }
  s.source           = { :git => 'https://github.com/bluebillywig/playerSdkLibraries.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'

  s.source_files = 'BlueBillywigPlayerSDK/Classes/**/*'
  s.public_header_files = 'BlueBillywigPlayerSDK/Classes/**/*.h'
  s.vendored_libraries = "bin/lib/universal/lib#{s.name}.a"

  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
end
