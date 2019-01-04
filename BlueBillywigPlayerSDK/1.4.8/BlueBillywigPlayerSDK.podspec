#
# Be sure to run `pod lib lint BlueBillywigPlayerSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlueBillywigPlayerSDK'
  s.version          = '1.4.8'
  s.summary          = 'This is the Blue Billywig player SDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Blue Billywig player SDK can be used to communicate with our player.
                       DESC

  s.homepage         = 'https://github.com/bluebillywig/playerSdkLibraries.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Floris Groenendijk' => 'f.groenendijk@bluebillywig.com' }
  s.source           = { :git => 'https://github.com/bluebillywig/playerSdkLibraries.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'BlueBillywigPlayerSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BlueBillywigPlayerSDK' => ['BlueBillywigPlayerSDK/Assets/*.png']
  # }

  s.public_header_files = 'BlueBillywigPlayerSDK/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
end
