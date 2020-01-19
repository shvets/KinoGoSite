swift_version = File.new('.swift-version').read

Pod::Spec.new do |s|
  s.name         = "KinoGoSite"
  s.version      = "1.0.0"
  s.summary      = "KinoGo Site"
  s.description  = "KinoGo Site."

  s.homepage     = "https://github.com/shvets/KinoGoSite"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"

  s.ios.deployment_target = "12.2"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "12.2"
  #s.watchos.deployment_target = "2.0"

  s.source = { :git => "https://github.com/shvets/KinoGoSite.git", :tag => s.version }
  s.source_files = "Sources/**/*.swift"
  #s.resources = "Sources/Assets/**/*.xcassets"

  s.resource_bundles = {
    'com.rubikon.KinoGoSite' => ['Sources/**/*.{storyboard,strings}']
  }

  s.dependency 'MediaApis', '~> 1.0.0'
  s.dependency 'Runglish', '~> 1.0.0'
  #s.dependency 'AudioPlayer', '~> 1.0.7'
  s.dependency 'TVSetKit', '~> 1.0.13'

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => swift_version }
end
