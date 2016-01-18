Pod::Spec.new do |s|

  s.name         = "KurentoToolbox"
  s.version      = "0.2.5"
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
    ss.source_files = 'Classes/*.{h,m}'
    ss.dependency 'KurentoToolbox/Connection'
    ss.dependency 'KurentoToolbox/JSON-RPC'
    ss.dependency 'KurentoToolbox/Room'
  end

  s.subspec 'Connection' do |ss|
    ss.source_files = 'Classes/Connection/**/*.{h,m}', 'Classes/Internals/*.{h,m}'
    ss.public_header_files = 'Classes/Connection/*.h'
    ss.dependency 'libjingle_peerconnection', '~> 10763.2.0'
    ss.dependency 'KurentoToolbox/Utils'
  end

  s.subspec 'JSON-RPC' do |ss|
    ss.source_files = 'Classes/JSON-RPC/**/*.{h,m}', 'Classes/Internals/*.{h,m}'
    ss.public_header_files = 'Classes/JSON-RPC/*.h'
    ss.dependency 'SocketRocket', '~> 0.4.1'
    ss.dependency 'SBJson', '~> 4.0.2'
    ss.dependency 'KurentoToolbox/Utils'
  end
  
  s.subspec 'Room' do |ss|
      ss.source_files = 'Classes/Room/**/*.{h,m}', 'Classes/Internals/*.{h,m}'
      ss.public_header_files = 'Classes/Room/*.h'
      ss.dependency 'KurentoToolbox/JSON-RPC'
      ss.dependency 'KurentoToolbox/Connection'
      ss.dependency 'KurentoToolbox/Utils'
  end

  s.subspec 'Utils' do |ss|
      ss.source_files = 'Classes/Utils/*.{h,m}'
      ss.private_header_files = 'Classes/Utils/*.h'
      ss.dependency 'CocoaLumberjack', '~> 2.2.0'
  end

  s.requires_arc = true

end