extends Area3D

class_name card
var card_id = 1
var use = 0

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Global.instance.set_card(card_id)
		
		
func _process(delta):
	if (Global.get_delete_card() == card_id && Global.get_delete_card()==1):
		Global.set_delete_card(0)
		self.queue_free()
