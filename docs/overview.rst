Overview
________
**Kurento Toolbox for iOS** provides a set of basic components that have been found useful during the native development of the WebRTC applications with Kurento.

It contains:

* a JSON-RPC 2.0 client over websocket; it draws inspiration from javascript implementation found in `kurento-jsonrpc-js <https://github.com/kurento/kurento-jsonrpc-js>`_.

* a WebRTCPeer manager aimed to simplify WebRTC interactions (i.e. handle multiple peer connections, manage SDP offer-answer dance, retrieve local or remote streams …). This class is implemented based on the native WebRTC library `libjingle_peerconnection <http://www.webrtc.org/native-code/ios>`_ packaged as a CocoaPod.

System Requirements
===================
The KurentoToolbox supports the next:

* iOS 8+
* Armv7, Arm64 architectures

No support for iOS 32/64 bit simulator (no access to camera yet)