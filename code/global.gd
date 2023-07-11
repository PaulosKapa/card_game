extends Node
# Singleton instance
var instance
var card = 0
var delete = 0
func _init():
	instance = self
func set_card(card_value):
	card = card_value
	
func get_card():
	return card

func set_delete_card(delete_value):
	delete = delete_value
	
func get_delete_card():
	return(delete)
