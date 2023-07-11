extends Node

var map1 = preload("res://scenes/battlefields/test.tscn")
var maps = [map1]
var card = preload("res://scenes/cards/test_card.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#pick a random map out of the list
	var picked_map = maps.pick_random()
	#make an instance
	var map = picked_map.instantiate()
	##spawn it in map_point
	$spawners/map_point.add_child(map)
	var car_picked = card.instantiate()
	$spawners/card_point1.add_child(car_picked)
