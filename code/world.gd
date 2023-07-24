extends Node
#see rpc
@onready var shop = preload("res://scenes/store.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
@onready var player_spawns = preload("res://scenes/player_spawns.tscn")
var maps = [Global.map1]
var env = [Global.env1, Global.env2]
# Called when the node enters the scene tree for the first time.

func _ready():
	#pick a random map out of the list
	var picked_map = maps.pick_random().instantiate()
	#make an instance
#	picked_map.instantiate()
	$map_spawner.add_child(picked_map)
	$WorldEnvironment.set_environment(env.pick_random())
func _on_button_pressed():
	#join
	$Control.hide()
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer
#	multiplayer.peer_connected.connect(add_player)

func _on_button_2_pressed():
	#host
	$Control.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())
	multiplayer.peer_disconnected.connect(remove_player)
	
	#upnp_setup()
func add_player(peer_id):
	
	var pl = player_spawns.instantiate()
	pl.name = str(peer_id)
	#spawn in map_point if it doesn't have childred
	
	var map_point = $spawners/map_point
	var map_point2 = $spawners/map_point2
	if map_point.get_child_count() == 0:
		map_point.add_child(pl)
	else:
		map_point2.add_child(pl)

func remove_player(peer_id):
	var pl = get_node_or_null(str(peer_id))
	if pl:
		pl.queue_free()

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())


func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://scenes/store.tscn")


func _on_multiplayer_spawner_2_spawned(node):
	if node.is_multiplayer_authority():
		node.set_turn(true)


