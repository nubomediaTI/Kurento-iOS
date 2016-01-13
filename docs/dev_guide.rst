Developers Guide
________________

Usage
=====

WebRTC
******

Initialization
--------------
``NBMWebRTCPeer`` is the main component used to setup a WebRTC media session, it must be initialized with a delegate (``NBMWebRTCPeerDelegate``) and a media configuration object (``NBMMediaConfiguration``):

.. code-block:: obj-c
   
	/* 
	Default media constraints:

    Audio codec: Opus audio codec (higher quality)
    Audio bandiwidth limit: none
    Video codec: Software (VP8)
    Video renderer: OpenGLES 2.0
    Video bandwidth limit: none
    Video format: 640 x 480 @ 30fps
    */
   	NBMMediaConfiguration *mediaConfig = [NBMMediaConfiguration defaultConfiguration];
   	//If necessary modify media configuration and use it to setup WebRTCPeer, ``nil`` configuration means default values
   	NBMWebRTCPeer *webRTCPeer = [[NBMWebrTCPeer alloc] initWithDelegate:self configuration:mediaConfig];

SDP negotiation #1 : Generate Offer
-----------------------------------
An Offer SDP (Session Description Protocol) is metadata that describes to the other peer the format to expect (video, formats, codecs, encryption, resolution, size, etc).
An exchange requires an offer from a peer, then the other peer must receive the offer and provide back an answer:

.. code-block:: obj-c
	//Create a new offer for connection with specified identifier
	[webRTCPeer generateOffer:@"connectionId"];

When the offer is generated, the ``[webRTCPeer:didGenerateOffer:forConnection:]`` message is sent to webRTCPeer's delegate:

.. code-block:: obj-c
	//Handle SDP offer generation
	- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection {
    	//TODO: Signal SDP offer for connection
    }
	
SDP negotiation #2 : Process Answer
-----------------------------------
An Answer SDP is just like an offer but a response, we can only process an answer once we have generated an offer:

.. code-block:: obj-c
	//Process an answer from connection with specified identifier
	[webRTCPeer processAnswer:@"sdpAnswer" connectionId:@"connectionId"];

Tricke ICE #1 : Gathering local candidates
------------------------------------------
After creating the peer connection an event will be fired each time the ICE framework has found some local candidates, a ``[webRTCPeer:hasICECandidate:forConnection:]`` message is sent to webRTCPeer's delegate:

.. code-block:: obj-c
	//Handle the gathering of ICE candidate for connection with specified identifier
	- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
		//TODO: Signal ICE candidate for connection
	}

Tricke ICE #2 : Set remote candidates
-------------------------------------
When a new remote ICE candidate is received it is necessary to process it properly to achieve a successful media negotiation:

.. code-block:: obj-c
	//Set remote candidate for connection with specified identifier
	[webRTCPeer addICECandidate:candidate connectionId:@"connectionId"];

Documentation
=============

`Link <http://rawgit.com/nubomediaTI/Kurento-iOS/master/docs/html/index.html>`_ to API Reference (Apple style).