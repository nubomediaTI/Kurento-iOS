Pod::Spec.new do |s|

  s.name         = "KurentoToolbox"
  s.version      = "0.2"
  s.summary      = "Kurento Toolbox for iOS"
  s.description  = <<-DESC
                   Kurento Toolbox for iOS provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.
                   DESC
  s.homepage     = "https://github.com/nubomediaTI/Kurento-iOS"

  s.license      = { :type => "GNU LGPL 2.1", :file => "LICENSE" }

  s.author = { "Marco Rossi" => "marco5.rossi@guest.telecomitalia.it" }
  s.platform = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/nubomediaTI/Kurento-iOS.git", :tag => "v0.2.1" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"

  s.public_header_files = "Classes/*.h"
  s.private_header_files = "Classes/Internals/*.h"
  s.prefix_header_contents = '#import "NBMLog.h"'

  s.requires_arc = true

  s.dependency "libjingle_peerconnection", "~> 10665.2.0"
  s.dependency "SBJson", "~> 4.0.2"
  s.dependency "SocketRocket", "~> 0.4.1"
  s.dependency "CocoaLumberjack"

end
