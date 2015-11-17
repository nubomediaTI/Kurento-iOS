.. role:: obj-c(code)
   :language: obj-c

=======================
Kurento Toolbox for iOS
=======================

Overview
========
**Kurento Toolbox for iOS** provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.

It contains:

* a JSON-RPC 2.0 client over websocket; it draws inspiration from javascript implementation found in `kurento-jsonrpc-js <https://github.com/kurento/kurento-jsonrpc-js>`_.

* a WebRTCPeer manager aimed to simplify WebRTC interactions (i.e. handle multiple peer connections, manage SDP offer-answer dance, retrieve local or remote streams …). This class is implemented based on the native WebRTC library `libjingle_peerconnection <http://www.webrtc.org/native-code/ios>`_ packaged as a CocoaPod.

System Requirements
-------------------
The KurentoToolbox supports the next:

* iOS 8+
* Armv7, Arm64 architectures

No support for iOS 32/64 bit simulator (no access to camera yet)

Installation guide
==================

Installation with CocoaPods
---------------------------

`CocoaPods <https://cocoapods.org/>`_
is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party frameworks or libraries like KurentoToolbox.framework in your projects.

Coming soon (still working on that)

Manual installation
-------------------

Step 1: Download & unzip the framework
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Download the latest KurentoToolbox.framework (v.0.2) below

`KurentoToolbox.framework <https://github.com/nubomediaTI/Kurento-iOS/releases/download/v0.2/KurentoToolbox.framework.zip>`_


Step 2: Add the framework to your Xcode project
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Drag the KurentoToolbox.framework into your Xcode project. Make sure the “Copy items to destination’s group folder” checkbox is checked.

Step 3: Link Binary With Library Frameworks
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Click on Project → Select Target of interest → Choose Build Phases tab → Link Binary With Libraries → At the bottom of this list hit + to add libraries.

Here is the list of required Apple library frameworks/dylibs:

* ``libicucore.dylib``
* ``libstdc++.dylib``
* ``libc.dylib``
* ``libsqlite3.dylib``
* ``AVFoundation.framework``
* ``AudioToolbox.framework``
* ``CoreGraphics.framework``
* ``CoreMedia.framework``
* ``GLKit.framework``
* ``UIKit.framework``
* ``VideoToolbox.framework``
* ``CFNetwork.framework``
* ``Security.framework``

Step 4: Add -ObjC linker flag
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Click on Project → Select Target of interest → Choose Build Settings tab → Other Linker Flags and add the ``-ObjC`` linker flag.

Step 5: Import header(s)
^^^^^^^^^^^^^^^^^^^^^^^^

Just :obj-c:`#import` the umbrella header wherever you need to use Kurento toolbox, usually in <YourProjectName-Prefix>.pch file

.. code-block:: obj-c

    #import <KurentoToolbox/KurentoToolbox.h>


Developers Guide
================


Documentation (Apple style)
---------------------------

Link to API reference


Architecture
================

+ WebRTC
	* NBMWebRTCPeer
	* NBMPeerConnection

+ JSON-RPC 

    Objects

    * <NBMMessage>
    * NBMRequest
    * NBMResponse
    
    Client
    
    * NBMJSONRPCClient