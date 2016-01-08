Pod::Spec.new do |s|

  s.name         = "KurentoToolbox"
  s.version      = "0.2.3"
  s.summary      = "Kurento Toolbox for iOS"
  s.description  = <<-DESC
                   Kurento Toolbox for iOS provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.
                   DESC
  s.homepage     = "https://github.com/nubomediaTI/Kurento-iOS"

  s.license      = { :type => "GNU LGPL 2.1", :file => "LICENSE" }

  s.author = { "Marco Rossi" => "marco5.rossi@guest.telecomitalia.it" }
  s.platform = :ios, "8.0"

  s.source       = { :git => "https://github.com/nubomediaTI/Kurento-iOS.git", :tag => "v#{s.version}" }

  s.prefix_header_contents = '#import "NBMLog.h"'

  s.subspec 'Default' do |ss|
    ss.source_files = 'Classes/*.{h,m}', 'Classes/Utils/*.{h,m}'
    ss.private_header_files = 'Classes/Utils/*.h'
    ss.dependency 'KurentoToolbox/Connection'
    ss.dependency 'KurentoToolbox/JSON-RPC'
    ss.dependency 'KurentoToolbox/Room'
  end

  s.subspec 'Connection' do |ss|
    ss.source_files = 'Classes/Connection/**/*.{h,m}'
    ss.private_header_files = 'Classes/Connection/Internals/*.h'
  end

  s.subspec 'JSON-RPC' do |ss|
    ss.source_files = 'Classes/JSON-RPC/**/*.{h,m}'
    ss.private_header_files = 'Classes/JSON-RPC/Internals/*.h'
  end
  
  s.subspec 'Room' do |ss|
      ss.source_files = 'Classes/Room/*.{h,m}'
      ss.dependency 'KurentoToolbox/JSON-RPC'
      ss.private_header_files = 'Classes/Room/Internals/*.h'
  end

  s.requires_arc = true

  s.dependency "libjingle_peerconnection", "~> 10763.2.0"
  s.dependency "SBJson", "~> 4.0.2"
  s.dependency "SocketRocket", "~> 0.4.1"
  s.dependency "CocoaLumberjack"

end
