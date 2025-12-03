#
# Be sure to run `pod lib lint Spotzee.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Spotzee'
  s.version          = '0.3.0'
  s.summary          = 'Spotzee iOS SDK for event tracking and push notifications.'

  s.description      = <<-DESC
  Spotzee iOS SDK provides user identification, event tracking, push notification
  handling, and in-app messaging for your iOS applications.
                       DESC

  s.homepage         = 'https://github.com/spotzee-marketing/ios-sdk'
  s.license          = { :type => 'Proprietary', :file => 'LICENSE' }
  s.author           = { 'Roshan Jonnalagadda' => 'roshan@spotzee.com' }
  s.source           = { :git => 'https://github.com/spotzee-marketing/ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.7'

  s.source_files = 'Sources/**/*.swift'
  s.frameworks = ['UIKit', 'WebKit', 'Foundation']
end
