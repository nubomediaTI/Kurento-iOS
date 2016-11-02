Installation guide
__________________

Installation with CocoaPods
===========================

`CocoaPods <https://cocoapods.org/>`_
is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party frameworks or libraries like KurentoToolbox.framework in your projects.

Step 1: Downloading CocoaPods
-----------------------------
CocoaPods is distributed as a Ruby gem and is installable with the default Ruby available on OSX by running the following command:

.. code-block:: bash
  
  $ sudo gem install cocoapods
  $ pod setup

Step 2: Creating a Podfile
--------------------------
Project dependencies to be managed by CocoaPods are specified in a file called ``Podfile``. Create this file in the same directory as your Xcode project (``.xcodeproj``) file:

.. code-block:: bash

    $ touch Podfile
    $ open -a Xcode Podfile

You just created the pod file and opened it using Xcode, to add some content to the empty pod file copy and paste the following lines:

::

    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '8.0'
    pod 'KurentoToolbox', '~> 0.2.4'

Step 3: Installing Dependencies
-------------------------------
Now you can install the dependencies in your project:

.. code-block:: bash
  
  $ pod install

From now on, be sure to always open the generated Xcode workspace (``.xcworkspace``) instead of the project file when building your project:

.. code-block:: bash
  
  $ open <YourProjectName>.xcworkspace

At this point, everything is in place for you to start using KurentoToolbox. Just :obj-c:`#import` the umbrella header wherever you need to use it, usually in <YourProjectName-Prefix>.pch file:

.. code-block:: obj-c

   #import <KurentoToolbox/KurentoToolbox.h>

Manual installation
===================

Step 1: Download & unzip the framework
--------------------------------------
Download the latest KurentoToolbox.framework (v0.2.4) below:

`KurentoToolbox.framework <https://github.com/nubomediaTI/Kurento-iOS/releases/download/v0.2.4/KurentoToolbox.framework.zip>`_

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

Step 5: Importing Header(s)
---------------------------

Just :obj-c:`#import` the umbrella header wherever you need to use KurentoToolbox, usually in <YourProjectName-Prefix>.pch file

.. code-block:: obj-c

   #import <KurentoToolbox/KurentoToolbox.h>