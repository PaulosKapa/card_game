extends Node3D

var enemy_raycast = null
var attacker
var character = true
var perform_raycast = false
#make a list with all the cards
var cards = [Global.card1, Global.card2, Global.card3, Global.card4]
#make a list with all the characters
var chars = [Global.char1,"",Global.char2, Global.char3]
var card_id = null
var card = null
var selected_card = ""
var card_deck = []
var initial_hand = []
var card_index = null
var end_turn = false
var otherPlayerID = -1
var health = 100
var attack = false
var play = true
var money = 0
var end_game = false
var damage = 0 
var result_signal = false
var previous_result = null
var start = false
var moves = 0
var cards_saved = []
@onready var card_spawners = [$card_spawner1,$card_spawner2,$card_spawner3,$card_spawner4,$card_spawner5]



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
	set_turn(!get_turn())
	moves = 0
	print(get_turn())

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
		if start == false:
			start_raycast()
		else:
			raycast_function()
		
func _process(_delta):
	if not is_multiplayer_authority(): return
	$Label3D.text = str(health)
	show_menu.rpc()
	
func start_raycast():
	if Input.is_action_just_pressed("click"):
		perform_raycast = true
	if perform_raycast == true:
		# Setup a Raycast
		var ray_length = 10000
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = $Camera3D
		var space_state = get_world_3d().get_direct_space_state()
		var params = PhysicsRayQueryParameters3D.new()
		params.from = camera.project_ray_origin(mouse_pos)
		params.to = params.from + camera.project_ray_normal(mouse_pos) * ray_length
		# Send the raycast into the scene and react if it collided with something
		var result = space_state.intersect_ray(params)
		
		if result.size()>0:
			var parentString = str(result.get("collider").get_parent())
			var startIndex = parentString.find(":")
			var playerID = parentString.substr(0, startIndex)
			if result.get("collider").name == "start_game" and playerID != str(name):
				enemy_raycast = result.get("collider").get_parent()
				result.get("collider").queue_free()
				enemy_raycast.delete_start.rpc_id(enemy_raycast.get_multiplayer_authority(), str(result.get("collider")))
				start = true
		perform_raycast = false
@rpc("any_peer")
func delete_start(result):
	get_node(result).queue_free()
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
							moves +=1
							if moves == 2:
								enemy_raycast.end_turn_func.rpc_id(enemy_raycast.get_multiplayer_authority())
								set_turn(!get_turn())
							
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
							attack_func(result.get("collider").get_parent(),attacker.get_parent())
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


func attack_func(result, attacker_f):
		var res = result.get_child(2)
		#res.get_parent().get_parent().test.rpc_id(res.get_parent().get_parent().get_multiplayer_authority(), 2)
		var att = attacker_f.get_child(2)
		#print(att.name+ "attacked: "+ res.name)
		var hit_chance = 0
		#check if the attacker's attack will be dodged or not
		hit_chance = att.get_accucary() - res.get_reflexes()
		#if attack isn't dodged
		if hit_chance>0:
			damage = att.get_attack() - res.get_defend()

#		#if attack is dodged the enemy attacks
		else:
			play_dodge_animation(str(att.get_parent()))
			print("dodged")
		
		if damage>0:
			print("attacked")
			var enemy = res.get_parent().get_parent()
			rpc("play_attack_animation", str(att.get_parent()))
			enemy.enemy_character_health.rpc_id(enemy.get_multiplayer_authority(), damage, str(res.get_parent()))
			#res.get_parent().get_parent().test.rpc_id(res.get_parent().get_parent().get_multiplayer_authority(), 2)
			#rpc_id(res.get_multiplayer_authority(), "enemy_character_health ", money, str(res))		
			#if the enemy dies, deduct the rest from the enemy's total health
			res.set_health(res.get_health() - damage)
			if res.get_health() <= 0:
				await get_tree().create_timer(3.0).timeout
				#enemy.enemy_hp.rpc_id(enemy.get_multiplayer_authority(), health, damage)
				money+=att.get_health()
				res.queue_free()
				#rpc("delete_enemy",str(res.get_parent()))
		moves += 1
		if moves == 2:
			enemy_raycast.end_turn_func.rpc_id(enemy_raycast.get_multiplayer_authority())
			set_turn(!get_turn())
		
	
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


#decrease enemy's character health
@rpc("any_peer")
func enemy_character_health(damage, res):
	var res_child = get_node(res).get_child(2)
	res_child.set_health(res_child.get_health() - damage)
	#if the character dies
	if res_child.get_health()<=0:
		#delete the character
		res_child.queue_free()
		#give the money to the enemy
		set_money(get_money()+damage)
		set_health(get_health() + res_child.get_health())
		if get_health()<0:
			set_end_game(!get_end_game())
func set_health(h):
	health = h
func get_health():
	return(health)
func set_money(m):
	money = m
func get_money():
	return(money)
#end game money
@rpc("any_peer")
func end_game_money(money_f, health):
	money_f+=health
	
func get_end_game():
	return end_game
	
func set_end_game(end):
	end = end_game
	
@rpc("call_local")
func play_attack_animation(att):
	var att_child = get_node(att).get_child(2)
	att_child.get_attack_anim()
	
func play_dodge_animation(res):
	var res_child = get_node(res).get_child(2)
	res_child.get_attack_anim()
	#res_child.get_dodge_anim()

@rpc("call_local")
func show_menu():
	if get_end_game() == true:
		play = false
		$ColorRect/Label.text = money
		

func _on_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/store.tscn")


func _on_home_pressed():
	get_tree().reload_current_scene()

func save():
	cards_saved.append_array(initial_hand)
	cards_saved.append_array(card_deck)
	
	# Create a dictionary with the data to save
	var data = {
		"cards": cards_saved,
		"money": money  # Replace "money" with the variable you want to save
		# Add other variables and their values that you want to save
	}
	# Convert the data to a JSON string
	var jsonText = JSON.stringify(data)
	# Open the file in write mode and write the JSON string
	var file = FileAccess.open("res://save.json", FileAccess.WRITE)
	file.store_string(jsonText)
	file.close()
