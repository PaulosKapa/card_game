extends Node3D

var perform_raycast = false
#make a list with all the cards
var cards = [Global.card1]
#make a list with all the characters
var chars = [Global.char1]
var card_id = null
var selected_card = ""
var card_deck = []
var initial_hand = []
var card_index = null
var end_turn = true
var otherPlayerID = -1

@onready var card_spawners = [$card_spawner1,$card_spawner2,$card_spawner3,$card_spawner4,$card_spawner5]

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	if not is_multiplayer_authority(): return
	print(self)
	$Camera3D.current = true
	load_data()
	print(name, ":", end_turn)
func load_data():
	#read the file
	var file = FileAccess.open("res://save.json", FileAccess.READ)
	#get the text
	var content = file.get_as_text()
	#parse as a dictionary
	var finish = JSON.parse_string(content)
	file.close()
	var i = 0
	#shuffle the cards
	finish.get("cards").shuffle()
	#for all the cards in the save file
	for item in finish.get("cards"):
		#instance the card
		var card = cards[item].instantiate()
		#the first 5 cards add on hand
		if card.get_card_is_character() == true and i<5:
			initial_hand.append(card)
			i+=1
		#else add on deck
		else:
			card_deck.append(card)
	i = 0
	#place the initial hand
	for item in initial_hand:
		card_spawners[i].add_child(item)
		i+=1
@rpc("call_remote")
func end_turn_func():
	if end_turn == true:
		end_turn = false
	else:
		end_turn = true
	#print(name, ":", end_turn)
func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	

# Get the IDs of the connected players


	if otherPlayerID == -1:
		var connectedPlayers = get_tree().get_multiplayer().get_peers()
# Find the ID of the other player
		for playersID in connectedPlayers:
				
				otherPlayerID = playersID
				break
	
	
	raycast_function()
	

func raycast_function():
	
	if Input.is_action_pressed("click"):
		perform_raycast = true
		
	if perform_raycast == true and end_turn == true:
		
		# Setup a Raycast
		var ray_length = 1000
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = $Camera3D
		var space_state = get_world_3d().get_direct_space_state()
		var params = PhysicsRayQueryParameters3D.new()
		params.from = camera.project_ray_origin(mouse_pos)
		params.to = params.from + camera.project_ray_normal(mouse_pos) * ray_length
		# Send the raycast into the scene and react if it collided with something
		var result = space_state.intersect_ray(params)
		
		# Make sure the raycast hit something
		if result.size()>0:
			#player spawner
			#print(result.get("collider"))
			if str(result.get("collider")).find("spawner")!=-1:
				#get the id of the selected card
				match card_id:
					null:
						pass
					_:
						#get the parent of the spawner (the id of the player)
						var parentString = str(result.get("collider").get_parent())
						var startIndex = parentString.find(":")
						var playerID = parentString.substr(0, startIndex)
						#if the spawner doesnt have children and the spawners are owned by the player
						if result.get("collider").get_child_count() == 2 and playerID == str(name):
							#instance the character from the selected card
							var character = chars[card_id].instantiate()
							#add the character to the spawner
							rpc_id(int(playerID), "add_char", result.get("collider"), character)
#							if playerID == str(1):
#								rpc_id(otherPlayerID, "add_char", result.get("collider"), character)
#							else:
#								rpc_id(1, "add_char", result.get("collider"), character)
							card_id = null
							#delete the index from the initial_hand
							initial_hand.remove_at(card_index)
							card_index = null
							#delete the selected card
							selected_card.queue_free()
							selected_card = ""
							end_turn_func.rpc()
							if playerID == str(1):
								rpc_id(otherPlayerID, "end_turn_func")
							else:
								rpc_id(1, "end_turn_func")
			#card
			elif str(result.get("collider")).find("card")!=-1:
				#get the id of the card
				card_id = result.get("collider").get_card_id()
				#save the card, to be deleted later
				selected_card = result.get("collider")
				#save the index to be deeleted later
				card_index = initial_hand.find(result.get("collider"))
				
			#deck
			elif str(result.get("collider")).find("deck")!=-1:
				add_card()
		perform_raycast = false
@rpc("call_local")
func add_char(result, character):
	result.add_child(character)
	print(name, " spawned ", character)


func _input(_event):
	if not is_multiplayer_authority(): return
	

func add_card():
	if len(initial_hand)<5:
		var j = 0
		#for all the card_spawners
		while j<len(card_spawners):
			#if a card spawner is empty and there are cards on the deck
			if card_spawners[j].get_child_count()==0 and len(card_deck)>0:
				#add child to said spawner
				card_spawners[j].add_child(card_deck[0])
				#remove the card from the deck
				card_deck.remove_at(0)
				break
			j+=1

