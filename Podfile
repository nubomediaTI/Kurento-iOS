source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

workspace 'Kurento-iOS'

def common_target_pods
    pod 'CocoaLumberjack', :configurations => ['Debug']
    pod 'SBJson', '~> 4.0.2'
#    pod 'libjingle_peerconnection', '~> 11177.2.0'
    #pod 'nighthawk-webrtc', :podspec => './nighthawk-webrtc-chrome-m45-capture-xcode.podspec'
    pod 'SocketRocket', '~> 0.4.2'
end

target 'KurentoToolbox-Static' do
    xcodeproj 'Kurento-iOS'
    common_target_pods
end

target 'KurentoToolbox-Tests' do
    xcodeproj 'Kurento-iOS'
    pod 'KurentoToolbox', :path => "."
end

target 'KurentoToolboxDemo' do
    xcodeproj 'KurentoToolboxDemo/KurentoToolboxDemo'
    pod 'KurentoToolbox', :path => "."
    pod 'MBProgressHUD', '~> 0.9.2'
    pod 'Reachability', '~> 3.2'
    pod 'DGActivityIndicatorView'
    pod 'Masonry', '~> 0.6.4'
end


