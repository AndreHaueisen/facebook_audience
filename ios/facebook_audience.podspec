#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'facebook_audience'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'FBAudienceNetwork'
  s.swift_version = '4.2'
  s.preserve_paths = 'FBAudienceNetwork.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FBAudienceNetwork' }
  s.vendored_frameworks = 'FBAudienceNetwork.framework'
  s.static_framework = true

  s.ios.deployment_target = '9.0'
end

