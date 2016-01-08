source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

def common_target_pods
    pod 'CocoaLumberjack', :configurations => ['Debug']
    pod 'SBJson', '~> 4.0.2'
    pod 'libjingle_peerconnection', '~> 10763.2.0'
    pod 'SocketRocket', '~> 0.4.1'
end

target 'KurentoToolbox' do
    common_target_pods
end

target 'KurentoToolboxTests' do
    common_target_pods
end


