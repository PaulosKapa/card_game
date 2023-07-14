extends Node
# Singleton instance
#var instance
#var card = 0
#var delete = 0
#func _init():
#	instance = self
#func set_card(card_value):
#	card = card_value
#
#func get_card():
#	return card
#
#func set_delete_card(delete_value):
#	delete = delete_value
#
#func get_delete_card():
#	return(delete)
#make instances of everything that needs to be preloaded
#characters
var char1 = preload("res://scenes/characters/test_char.tscn")

#maps
var map1 = preload("res://scenes/battlefields/test.tscn")

#cards
var card1 = preload("res://scenes/cards/test_card.tscn")

