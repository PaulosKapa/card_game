extends Node3D
var money = 0
var cards_saved = []
var cards = [Global.card1,Global.card1,Global.card1,Global.card1,Global.card1]
var cards_bought = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("res://save.json", FileAccess.READ)
	#get the text
	var content = file.get_as_text()
	#parse as a dictionary
	var finish = JSON.parse_string(content)
	file.close()
	money = finish.get("money")
	cards_saved = finish.get("cards")
func save():
	cards_saved.append_array(cards_bought)
	cards_bought = []
	
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

func _on_characters_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and money>49:
		cards.shuffle()
		money -= 50
		var i = 0
		while i<5:
			#instance the card
			var card = cards[i].instantiate()
			#add to the cards bought
			if card.get_card_is_character() == true:
				cards_bought.append(card.get_card_id())
				i+=1
			

func _on_items_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and money>29:
		cards.shuffle()
		money -= 30
		var i = 0
		while i<5:
			#instance the card
			var card = cards[i].instantiate()
			#add to the cards bought
			if card.get_card_is_character() == false:
				cards_bought.append(card.get_card_id())
				i+=1
			
func _on_both_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and money>69:
		cards.shuffle()
		money -= 70
		var i = 0
		while i<5:
			#instance the card
			var card = cards[i].instantiate()
			#add to the cards bought
			if i<4:
				cards_bought.append(card.get_card_id())
				i+=1
			elif card.get_card_is_character() == true:
				cards_bought.append(card.get_card_id())
				i+=1
		


func _on_close_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		save()
		get_tree().change_scene_to_file("res://scenes/world.tscn")
