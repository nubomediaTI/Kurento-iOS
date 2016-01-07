Installation guide
__________________

Installation with CocoaPods
===========================

`CocoaPods <https://cocoapods.org/>`_
is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party frameworks or libraries like KurentoToolbox.framework in your projects.

Coming soon (still working on that)

Manual installation
===================

Step 1: Download & unzip the framework
--------------------------------------
Download the latest KurentoToolbox.framework (v.0.2) below

`KurentoToolbox.framework <https://github.com/nubomediaTI/Kurento-iOS/releases/download/v0.2/KurentoToolbox.framework.zip>`_


Step 2: Add the framework to your Xcode project
-----------------------------------------------
Drag the KurentoToolbox.framework into your Xcode project. Make sure the “Copy items to destination’s group folder” checkbox is checked.

Step 3: Link Binary With Library Frameworks
-------------------------------------------

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
-----------------------------

Click on Project → Select Target of interest → Choose Build Settings tab → Other Linker Flags and add the ``-ObjC`` linker flag.

Step 5: Import header(s)
------------------------

Just :obj-c:`#import` the umbrella header wherever you need to use Kurento toolbox, usually in <YourProjectName-Prefix>.pch file

.. code-block:: obj-c

    #import <KurentoToolbox/KurentoToolbox.h>
