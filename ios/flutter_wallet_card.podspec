#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_wallet_card.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_wallet_card'
  s.version          = '1.0.0'
  s.summary          = 'Flutter wallet card for iOS & android devices.'
  s.license          = 'MIT'
  s.description      = 'Flutter wallet card for iOS & android devices.'
  s.homepage         = 'https://github.com/WebEferen/flutter_wallet_card'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mike Makowski' => 'michal.makowski97@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
