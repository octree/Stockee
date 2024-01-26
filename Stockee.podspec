Pod::Spec.new do |s|
  s.name             = 'Stockee'
  s.version          = '1.1.3'
  s.summary          = 'Swift k-line chart'
  s.description      = <<-DESC
  Highly customizable performant k-line chart written in swift.
  DESC

  s.homepage         = 'https://github.com/octree/Stockee'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Octree' => 'fouljz@gmail.com' }
  s.source           = { :git => 'https://github.com/octree/Stockee.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.8'

  s.source_files = 'Sources/Stockee/**/*.swift'
  s.frameworks = 'UIKit'
end
