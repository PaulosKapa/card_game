extends Node3D

const ray_length = 1000

var perform_raycast = false
#make a list with all the cards
var cards = [Global.card1]
#make a list with all the characters
var chars = [Global.char1]
var card_id = null
var selected_card = ""
var card_deck = []

func _ready():
	#instance 5 card for the deck
	var file = FileAccess.open("res://save.json", FileAccess.READ)
	var content = file.get_as_text()
	print(file.get("cards"))
	

func _physics_process(_delta):
	if perform_raycast == true:
		
		# Setup a Raycast
		var ray_length = 1000
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = $Camera3D
		var space_state = get_world_3d().get_direct_space_state()
		
		#var from = camera.project_ray_origin(event.position)
		#var to = from + camera.project_ray_normal(event.position) * ray_length
		var params = PhysicsRayQueryParameters3D.new()
		params.from = camera.project_ray_origin(mouse_pos)
		params.to = params.from + camera.project_ray_normal(mouse_pos) * ray_length
		# Send the raycast into the scene and react if it collided with something
		var result = space_state.intersect_ray(params)
		# Make sure the raycast hit something
		if result.size()>0:
			#player spawner
			if str(result.get("collider")).find("spawner")!=-1:
				#get the id of the selected card
				match card_id:
					null:
						pass
					_:
						#instance the character from the selected card
						var char = chars[card_id].instantiate()
						#add the character to the spawner
						result.get("collider").add_child(char)
						card_id = null
						#delete the selected card
						selected_card.queue_free()
						selected_card = ""
			#card
			elif str(result.get("collider")).find("card")!=-1:
				#get the id of the card
				card_id = result.get("collider").get_card_id()
				#save the card, to be deleted later
				selected_card = result.get("collider")
		perform_raycast = false

func _input(event):
	if Input.is_action_pressed("click"):
		perform_raycast = true


