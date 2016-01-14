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
   //If necessary modify media configuration and use it to setup WebRTCPeer, 'nil' configuration means default values
   NBMWebRTCPeer *webRTCPeer = [[NBMWebrTCPeer alloc] initWithDelegate:self configuration:mediaConfig];

SDP negotiation #1 : Generate Offer
-----------------------------------
An Offer SDP (Session Description Protocol) is metadata that describes to the other peer the format to expect (video, formats, codecs, encryption, resolution, size, etc). An exchange requires an offer from a peer, then the other peer must receive the offer and provide back an answer:

.. code-block:: obj-c

   //Create a new offer for connection with specified identifier
   [webRTCPeer generateOffer:@"connectionId"];

When the offer is generated, the ``[webRTCPeer:didGenerateOffer:forConnection:]`` message is sent to webRTCPeer's delegate:

.. code-block:: obj-c
	
	#pragma mark -
	#pragma mark NBMWebRTCPeerDelegate

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

	#pragma mark -
	#pragma mark NBMWebRTCPeerDelegate

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

Kurento Room
************

Initialization
--------------
``NBMRoomClient`` is the main class that communicates with Kurento Room server using WebSocket API, the exchanged messages between server and client are JSON-RPC 2.0 requests and responses. To use it you must first create a ``NBMRoom`` object (providing a username, a room name and the server's URI for listening JSON-RPC requests) and a ``NBMRoomClientDelegate`` object to be informed about room's events. At the moment the client supports only one room:

.. code-block:: obj-c
	
	//NBMRoom

	//Local peer's identifier
	NSString *username = ...
	//Room name
	NSString *roomName = ...
	//WebSocket URI
	NSURL *wsURI = [NSURL URLWithString:@"http://localhost:8080/room"];
	NBMRoom *room = [[NBMRoom alloc] initWithUsername:username roomName:roomName roomURL:wsURI];

	//NBMRoomClient

	//NBMRoomClient with default timeout (5 sec)
	NBMRoomClient *roomClient = [[NBMRoomClient alloc] initWithRoom:room delegate:self];
	
	//Or

	//NBMRoomClient with custom timeout (10 sec)
	NSTimeInterval clientTimeout = 10; 
	NBMRoomClient *roomClient = [[NBMRoomClient alloc] initWithRoom:room timeout:clientTimeout delegate:self];

Once intialized, before start calling client APIs we have to call ``[connect]`` and wait the delegate ``[client:isConnected:]`` message sent when the WebSocket connection was established successfully or key-value observe ``connected`` property:

.. code-block:: obj-c

	[roomClient connect];

	#pragma mark -
	#pragma mark NBMRoomClientDelegate

	- (void)client:(NBMRoomClient *)client isConnected:(BOOL)connected {
		if (connected) {
			//TODO: Start using APIs, eg. "joinRoom"
			[client joinRoom];
		} else {
			//TODO: Handle client disconnection, eg. try to reconnect
			[client connect];
		}
	}

If the WebSocket initialization failed or, in any case, when a connection error occurred, the ``[client:didFailWithError:]`` message is sent to the client's delegate.

Room APIs
---------
The client provides two different types of signatures of its asynchronous API, these differ in the way they handle callbacks:

- the first type implements callbacks sending messages to the client's delegate
- the second type uses blocks as method parameters (no message is sent to delegate) 

**Join Room**
Call ``[joinRoom]`` or ``[joinRoom:]`` method to join the room:

.. code-block:: obj-c

	[roomClient joinRoom]

	#pragma mark -
	#pragma mark NBMRoomClientDelegate
	
	- (void)client:(NBMRoomClient *)client didJoinRoom:(NSError *)error {
		if (!error) {
			NSLog(@"Partecipants %@", [client.peers allKeys]);	
		} else {
			NSLog(@"Join room error: %@", error);
		}
	}

	//Or

	[roomClient joinRoom:^(NSDictionary *peers, NSError *error) {
		if (!error) {
			NSLog(@"Partecipants %@", [client.peers allKeys]);	
		} else {
			NSLog(@"Join room error: %@", error);
		}    
   }];


Documentation
=============

`Link <http://rawgit.com/nubomediaTI/Kurento-iOS/master/docs/html/index.html>`_ to API Reference (Apple style).