extends Node


var maps = [Global.map1]
# Called when the node enters the scene tree for the first time.
func _ready():
	#pick a random map out of the list
	var picked_map = maps.pick_random()
	#make an instance
	var map = picked_map.instantiate()
	##spawn it in map_point if it doesn't have childred
	if $spawners/map_point.get_child_count() == 0:
		$spawners/map_point.add_child(map)
	else:
		$spawners/map_point2.add_child(map)
