Kurento ToolBox Ios
__________________________________________________


Installation Guide
============

Overview
--------
Kurento Toolbox for iOS provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.

It contains:

* a JSON-RPC 2.0 client over websocket; it draws inspiration from javascript implementation found in kurento-jsonrpc-js (https://github.com/kurento/kurento-jsonrpc-js)
* a WebRTCPeer manager aimed to simplify WebRTC interactions (i.e. handle multiple peer connections, manage SDP offer-answer dance, retrieve local or remote streams …). 

This class is implemented based on the native WebRTC library libjingle_peerconnection (http://www.webrtc.org/native-code/ios) packaged as a CocoaPod.

System Requirements
-------------------
The Kurento Toolbox supports the next:

* iOS 8+
* Armv7, Arm64 architectures

No support for iOS 32/64 bit simulator (no access to camera yet)

Installation with CocoaPods
---------------------------

CocoaPods (https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party frameworks or libraries like Kurento.framework in your projects.

Coming soon (still working on that)



Developers Guide
================

Add the framework to your Xcode project

Step 1: Download & unzip the framework
--------------------------------------

Step 2: Add the framework to your Xcode project
-----------------------------------------------
Drag the KurentoiOS.framework into your Xcode project. Make sure the “Copy items to destination’s group folder” checkbox is checked.

Step 3: Link Binary With Library Frameworks
---------------------------------------------

Click on Project → Select Target of interest → Choose Build Phases tab → Link Binary With Libraries → At the bottom of this list hit + to add libraries.

Here is the list of required Apple library frameworks/dylibs:

* libicucore.dylib
* libstdc++.dylib
* libc.dylib
* libsqlite3.dylib
* AVFoundation.framework
* AudioToolbox.framework
* CoreGraphics.framework
* CoreMedia.framework
* GLKit.framework
* UIKit.framework
* VideoToolbox.framework
* CFNetwork.framework
* Security.framework

Step 4: Add -ObjC linker flag
------------------------------

Click on Project → Select Target of interest → Choose Build Settings tab → Other Linker Flags and add the -ObjC linker flag.

Step 5: Import header(s)
------------------------

Just import the umbrella header wherever you need to use Kurento iOS Toolbox, usually in <YourProjectName-Prefix>.pch file:

* #import <Kurento/Kurento.h>

Apple Style Doc to be provided
------------------------


Architecture
================

+ WebRTC
	* NBMWebRTCPeer
	* NBMPeerConnection

+ JSON-RPC 

+ Objects
	* <NBMMessage>
	* NBMRequest
	*NBMResponse

+ Client
	* NBMJSONRPCClient
