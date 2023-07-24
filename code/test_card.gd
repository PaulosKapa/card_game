extends StaticBody3D

class_name card_class
@export var card_id = 0
@export var is_character = true

#get the card id
func get_card_id():
	return card_id
	
#get if the chard is a character
func get_card_is_character():
	return is_character
