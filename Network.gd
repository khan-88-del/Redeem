extends Node

const PORT = 7777
var enet_peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://Player.tscn")

func start_host():
	enet_peer.create_server(PORT, 20)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())

func start_join(ip_address: String = "127.0.0.1"):
	enet_peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	get_tree().root.get_node("Main/Players").add_child(player)

func remove_player(peer_id):
	var player = get_tree().root.get_node_or_null("Main/Players/" + str(peer_id))
	if player:
		player.queue_free()
