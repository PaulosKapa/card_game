extends Area3D
class_name player_spawn
var char1 = preload("res://scenes/characters/test_char.tscn")
var chars = ["",char1]

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var character_picker = chars[Global.get_card()]
		if Global.get_card() == 0:
			print("choose a card")
		else:
			var character = character_picker.instantiate()
			self.add_child(character)
			Global.set_delete_card(Global.get_card())
			Global.set_card(0)
			
