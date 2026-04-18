extends Node

var peers := {}
var lobby_code_sent := false

func _ready():
	RTCClient.lobby_joined.connect(_on_lobby_joined)
	RTCClient.connected.connect(_on_connected)
	RTCClient.peer_connected.connect(_on_peer_connected)
	RTCClient.peer_disconnected.connect(_on_peer_disconnected)
	RTCClient.offer_received.connect(_on_offer)
	RTCClient.answer_received.connect(_on_answer)
	RTCClient.candidate_received.connect(_on_candidate)
	
	start()

func _process(_delta: float) -> void:
	if not lobby_code_sent and RTCClient.is_open():
		RTCClient.join_lobby("")
		lobby_code_sent = true

func start():
	RTCClient.connect_to_url("ws://localhost:7777")

func _on_lobby_joined(lobby: String):
	print("Joined ", lobby)

func _on_connected(_id: int, _host: bool):
	pass

func _on_peer_disconnected(id: int):
	print("peer ", id, " disconnected")

# webrtc stuff
func _on_peer_connected(id: int):
	var pc = WebRTCPeerConnection.new()
	peers[id] = pc

	pc.session_description_created.connect(func(type, sdp):
		if type == "offer":
			RTCClient.send_offer(id, sdp)
		else:
			RTCClient.send_answer(id, sdp)
	)

	pc.ice_candidate_created.connect(func(mid, index, sdp):
		RTCClient.send_candidate(id, mid, index, sdp)
	)

	pc.create_offer()

func _on_offer(id, offer):
	peers[id].set_remote_description("offer", offer)
	peers[id].create_answer()


func _on_answer(id, answer):
	peers[id].set_remote_description("answer", answer)


func _on_candidate(id, mid, index, sdp):
	peers[id].add_ice_candidate(mid, index, sdp)
