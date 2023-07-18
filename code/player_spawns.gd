extends Node3D

var attacker
var character = true
var perform_raycast = false
#make a list with all the cards
var cards = [Global.card1, Global.card2]
#make a list with all the characters
var chars = [Global.char1,""]
var card_id = null
var card = null
var selected_card = ""
var card_deck = []
var initial_hand = []
var card_index = null
var end_turn = true
var otherPlayerID = -1
var health = 100
var attack = false
var play = true
var money = 0
var end_game = false
var damage = 0 
var result_signal = false
var previous_result = null

@onready var card_spawners = [$card_spawner1,$card_spawner2,$card_spawner3,$card_spawner4,$card_spawner5]

signal enemy_damage

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	
	if not is_multiplayer_authority(): return
	$Camera3D.current = true
	load_data()
	
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
		var card_item = cards[item].instantiate()
		#the first 5 cards add on hand
		if card_item.get_card_is_character() == true and i<5:
			initial_hand.append(card_item)
			i+=1
		#else add on deck
		else:
			card_deck.append(card_item)
	i = 0
	#place the initial hand
	for item in initial_hand:
		card_spawners[i].add_child(item)
		i+=1
func get_turn():
	return(end_turn)
func set_turn(turn):
	end_turn = turn
@rpc("any_peer")
func end_turn_func():
	#var peer_id = multiplayer.get_remote_sender_id()
	#if peer_id == get_multiplayer_authority():
#		# The authority is not allowed to call this function.
		#return
	set_turn(!get_turn())
	print(get_turn())
	#print(get_multiplayer_authority() == peer_id)
	
		
	#print("RPC called by: ",peer_id, " ", end_turn)
func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	# Get the IDs of the connected players
	if otherPlayerID == -1:
		var connectedPlayers = get_tree().get_multiplayer().get_peers()
# Find the ID of the other player
		for playersID in connectedPlayers:
				play = true
				otherPlayerID = playersID
				break
	if play == true:
		raycast_function()
func _process(_delta):
	$Label3D.text = str(health)
	
func raycast_function():
	
	if Input.is_action_just_pressed("click"):
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
		#testing for enemy functions
		
		# Make sure the raycast hit something
		if result.size()>0:
			
			var parentString = str(result.get("collider").get_parent())
			var startIndex = parentString.find(":")
			var playerID = parentString.substr(0, startIndex)
			#for the character, because it is child of spawner
			var parentString1 = str(result.get("collider").get_parent().get_parent())
			var startIndex1 = parentString1.find(":")
			var playerID1 = parentString1.substr(0, startIndex1)
			#player spawner, only when the player has clicked a card firs
			print(result.get("collider").name)
			if str(result.get("collider")).find("spawner")!=-1:
				attack = false
				#get the id of the selected card
				match card_id:
					null:
						pass
					_:
						#get the parent of the spawner (the id of the player)
						#if the spawner doesnt have children and the spawners are owned by the player
						if result.get("collider").get_child_count() == 2 and playerID == str(name) and character == true:
							#instance the character from the selected card
							
							#add the character to the spawner
							rpc("add_char", str(result.get("collider")), card_id)
							card = null
							card_id = null
							#delete the index from the initial_hand
							initial_hand.remove_at(card_index)
							card_index = null
							#delete the selected card
							selected_card.queue_free()
							selected_card = ""
							character = true
							#end_turn_func.rpc()
							#end_turn_func.rpc_id(otherPlayerID)
							
							#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
							
#							if playerID == str(1):
#								end_turn_func.rpc_id(otherPlayerID)
#							else:
#								end_turn_func.rpc_id(1)
						
			#attacking
			elif str(result.get("collider")).find("character")!=-1 and attack == false and playerID1== str(name):
				if character == false:
					attack = false
					#get the id of the selected card
					match card_id:
						null:
							pass
						_:
							
							#instance the character from the selected card
							
							#add the character to the spawner
							#rpc("add_char", str(result.get("collider")), card_id)
								var attribute = null
								var mode = null
								#the cards are called only on the client not on both peers
								match card.get_ranked():
									"defend":
										attribute = card.get_defend()
										mode = "defend"
										
								rpc("add_equip",str(result.get("collider").get_parent()), attribute, mode)
								card = null
								card_id = null
							#delete the index from the initial_hand
								initial_hand.remove_at(card_index)
								card_index = null
							#delete the selected card
								selected_card.queue_free()
								selected_card = ""
								character = true
								#end_turn_func.rpc_id(otherPlayerID)
				else:
					attack = true
					attacker = result.get("collider")
					
			elif str(result.get("collider")).find("character")!=-1 and attack == true:
					if playerID1 != str(name):
						
						
						
						#print("attack: " + playerID1+ " "+  result.get("collider").name)
						#receive_damage.rpc_id(result1.get("collider").get_multiplayer_authority())
						#check if the characters are both on row 1. In this case only ranged characters can attack
						if result.get("collider").get_row() == 1 and attacker.get_row() == 1:
							if attacker.get_ranked() == "range":
								attack_func(result.get("collider").get_parent(),attacker.get_parent())
								
							
						else:
							rpc("attack_func", str(result.get("collider")), str(attacker))
					attack = false
			#card
			elif str(result.get("collider")).find("card")!=-1:
				attack = false
				#get the id of the card
				card = result.get("collider")
				card_id = result.get("collider").get_card_id()
				character = result.get("collider").get_card_is_character()
				#print(character)
				#save the card, to be deleted later
				selected_card = result.get("collider")
				#save the index to be deeleted later
				card_index = initial_hand.find(result.get("collider"))
				
			#deck
			elif str(result.get("collider")).find("deck")!=-1:
				attack = false
				add_card()
		perform_raycast = false

#add equipement
@rpc("call_local")
func add_equip(result, attribute, mode):
	var res = get_node(result).get_child(2)
	#based on the mode add the attribute
	match  mode:
		"defend":
			res.set_defend(res.get_defend()+attribute)


	
	
	
@rpc("call_local")
func add_char(result, card_id_f):
	var character_inst = chars[card_id_f].instantiate()
	#add the character
	get_node(result).add_child(character_inst)
	#set the row that the character is spawned
	match get_node(result).name:
		"spawner1":
			character_inst.set_row(1)
		"spawner2":
			character_inst.set_row(1)
		"spawner3":
			character_inst.set_row(1)
		"spawner4":
			character_inst.set_row(2)
		"spawner5":
			character_inst.set_row(2)
		"spawner6":
			character_inst.set_row(2)


func _input(_event):
	if not is_multiplayer_authority(): return

func attack_func(result, attacker_f):
		var res = result.get_child(2)
		previous_result = res
		print(previous_result.get_parent().get_parent())
		previous_result.get_parent().get_parent().test.rpc_id(previous_result.get_parent().get_parent().get_multiplayer_authority(), 2)
		result_signal = true
		var att = attacker_f.get_child(2)
		#print(att.name+ "attacked: "+ res.name)
		var hit_chance = 0
		#check if the attacker's attack will be dodged or not
		hit_chance = res.get_reflexes() - att.get_accucary()
		hit_chance = 1
		#if attack isn't dodged
		if hit_chance>0:
			damage = res.get_defend() - att.get_attack()

		#if attack is dodged the enemy attacks
		else:
			if res.get_row() == 1 and att.get_row() == 1:
				if att.get_ranked() == "range":
					att.set_health(att.get_health() - (res.get_attack()-res.get_accucary()))
					if att.get_health()<=0:
						money+=res.get_health()
						health+=att.get_health()
						if health<0:
							end_game == true
							print(end_game)
						att.queue_free()	
			else:
				att.set_health(att.get_health() - (res.get_attack()-res.get_accucary()))
				if att.get_health()<=0:
					#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
					#rpc_id(res.get_multiplayer_authority(), 'res.enemy_character_health', str(res), damage)
					health+=att.get_health()
					if health<0:
						end_game == true
						print(end_game)
					att.queue_free()	
		#if damage is more than zero deduct it from the enemy
		damage = 5
		if damage>0:
		
			var enemy = res.get_parent().get_parent()
			rpc_id(enemy.get_multiplayer_authority(), "enemy_money", money, str(enemy))
			#rpc_id(res.get_multiplayer_authority(), "enemy_character_health ", money, str(res))
			rpc_id(res.get_multiplayer_authority(), "enemy_character_health", damage, str(res.get_parent()))
			#if the enemy dies, deduct the rest from the enemy's total health
			if res.get_health() <= 0:
				
				rpc_id(enemy.get_multiplayer_authority(), "enemy.enemy_hp ", money, str(enemy))
				money+=att.get_health()
				res.queue_free()

	
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
#enemy hp and death
@rpc("any_peer")
func enemy_hp(health_f, att):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == get_multiplayer_authority():
		# The authority is not allowed to call this function.
		return
	health_f+=get_node(att).get_health()
	if health_f<0:
		end_game == true 
		print(end_game)

#enemy money
@rpc("any_peer")
func enemy_money(money_f, res):
	#print(res)
	money+=get_node(res).get_health()
#decrease enemy's character health
@rpc("any_peer")
func enemy_character_health(damage, res):
	var res_child = get_node(res).get_child(2)
	res_child.set_health(res_child.get_health() - damage)
	if res_child.get_health()<=0:
		res_child.queue_free()
#end game money
@rpc("any_peer")
func end_game_money(money_f, health):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == get_multiplayer_authority():
		# The authority is not allowed to call this function.
		return
	money_f+=health
@rpc("any_peer")
func test(attack_num):
	
	set_health(get_health()-attack_num)
	print(get_health())
func set_health(h):
	health = h
func get_health():
	return(health)


