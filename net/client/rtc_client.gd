extends Node

var ws := WebSocketPeer.new()

signal lobby_joined(lobby: String)
signal connected(id: int, host: bool)
signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal offer_received(id: int, offer: String)
signal answer_received(id: int, answer: String)
signal candidate_received(id: int, mid: String, index: int, sdp: String)
signal disconnected()


func connect_to_url(url: String) -> void:
	ws.connect_to_url(url)

func is_open() -> bool:
	return ws.get_ready_state() == WebSocketPeer.STATE_OPEN

func join_lobby(lobby: String) -> void:
	_send_msg(Msg.Message.JOIN, 0, lobby)


func close() -> void:
	ws.close()


func _process(_delta: float) -> void:
	ws.poll()

	while ws.get_ready_state() == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count():
		_parse_msg()

	if ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		disconnected.emit()


func _parse_msg() -> void:
	var parsed = JSON.parse_string(ws.get_packet().get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var type = int(parsed.type)
	var id = int(parsed.id)
	var data = parsed.data

	match type:
		Msg.Message.ID:
			connected.emit(id, data == "true")

		Msg.Message.JOIN:
			lobby_joined.emit(data)

		Msg.Message.PEER_CONNECT:
			peer_connected.emit(id)

		Msg.Message.PEER_DISCONNECT:
			peer_disconnected.emit(id)

		Msg.Message.OFFER:
			offer_received.emit(id, data)

		Msg.Message.ANSWER:
			answer_received.emit(id, data)

		Msg.Message.CANDIDATE:
			var c = data.split("\n")
			if c.size() == 3:
				candidate_received.emit(id, c[0], int(c[1]), c[2])


func send_offer(id: int, offer: String) -> void:
	_send_msg(Msg.Message.OFFER, id, offer)


func send_answer(id: int, answer: String) -> void:
	_send_msg(Msg.Message.ANSWER, id, answer)


func send_candidate(id: int, mid: String, index: int, sdp: String) -> void:
	_send_msg(Msg.Message.CANDIDATE, id, "%s\n%d\n%s" % [mid, index, sdp])


func _send_msg(type: int, id: int, data: String) -> void:
	ws.send_text(JSON.stringify({
		"type": type,
		"id": id,
		"data": data,
	}))
