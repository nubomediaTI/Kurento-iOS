Pod::Spec.new do |s|

  s.name         = "KurentoToolbox"
  s.version      = "0.3.0"
  s.summary      = "Kurento Toolbox for iOS"
  s.description  = <<-DESC
                   Kurento Toolbox for iOS provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.
                   DESC
  s.homepage     = "https://github.com/nubomediaTI/Kurento-iOS"

  s.license      = { :type => "GNU LGPL 2.1", :file => "LICENSE" }

  s.author = { "Marco Rossi" => "marco5.rossi@guest.telecomitalia.it" }
  s.platform = :ios, "8.0"

  s.source       = { :git => "https://github.com/nubomediaTI/Kurento-iOS.git", :tag => "v#{s.version}" }

  s.default_subspecs = 'Default'

  s.subspec 'Default' do |ss|
    ss.source_files = 'Classes/KurentoToolbox.h'
    ss.dependency 'KurentoToolbox/WebRTC'
    ss.dependency 'KurentoToolbox/JSON-RPC'
    ss.dependency 'KurentoToolbox/Room'
    ss.dependency 'KurentoToolbox/Tree'
    ss.ios.vendored_frameworks = 'WebRTC.framework'
  end

  s.subspec 'WebRTC' do |ss|
    ss.source_files = 'Classes/WebRTC/**/*.{h,m}'
    ss.public_header_files = 'Classes/WebRTC/*.h'
    ss.dependency 'KurentoToolbox/Utils'
  end

  s.subspec 'JSON-RPC' do |ss|
    ss.source_files = 'Classes/JSON-RPC/**/*.{h,m}'
    ss.public_header_files = 'Classes/JSON-RPC/*.h'
    ss.dependency 'SocketRocket', '~> 0.4.1'
    ss.dependency 'SBJson', '~> 4.0.2'
    ss.dependency 'KurentoToolbox/Utils'
  end
  
  s.subspec 'Room' do |ss|
      ss.source_files = 'Classes/Room/**/*.{h,m}'
      ss.public_header_files = 'Classes/Room/*.h'
      ss.dependency 'KurentoToolbox/JSON-RPC'
      ss.dependency 'KurentoToolbox/WebRTC'
      ss.dependency 'KurentoToolbox/Utils'
  end

  s.subspec 'Tree' do |ss|
      ss.source_files = 'Classes/Tree/**/*.{h,m}'
      ss.public_header_files = 'Classes/Tree/*.h'
      ss.dependency 'KurentoToolbox/JSON-RPC'
      ss.dependency 'KurentoToolbox/WebRTC'
      ss.dependency 'KurentoToolbox/Utils'
  end

  s.subspec 'Utils' do |ss|
      ss.source_files = 'Classes/Utils/*.{h,m}'
      ss.private_header_files = 'Classes/Utils/*.h'
      ss.dependency 'CocoaLumberjack', '~> 2.2.0'
  end

  s.requires_arc = true

end