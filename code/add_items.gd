extends Control

var name_item
var inhereted_class
var location

func _process(delta):
	pass
	
func get_name_of_item():
	name_item = $name.text
	return name_item
	
func get_loc():
	location = $location.text
	return location
	
func get_class_of_item():
	inhereted_class = $class.text
	return(inhereted_class)


func _on_add_pressed():
	print(get_class_of_item())
	print(get_name_of_item())
	print(get_loc())
	$name.text =""
	$location.text=""
	$class.text=""
