extends card_class

var characters = [Global.char1, "", Global.char2, Global.char3]

func _ready():
	var instanced_char = characters[card_id].instantiate()
	
	$attack.text = str(instanced_char.get_attack())
	$defence.text = str(instanced_char.get_defend())
	$accucary.text = str(instanced_char.get_accucary())
	$reflexes.text = str(instanced_char.get_reflexes())
	$health.text = str(instanced_char.get_health())
	$class.text = str(instanced_char.get_ranked())
