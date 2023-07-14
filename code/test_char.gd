extends StaticBody3D

var character_id = 0 
var attack = 10
var defend = 10
var reflexes = 10
var accucary = 10
var ranged = true
var health = 10

func get_character_id():
	return character_id
func get_attack():
	return attack
func get_defend():
	return defend
func get_reflexes():
	return reflexes
func get_accucary():
	return accucary
func get_ranged():
	return ranged
func get_health():
	return health
	
func set_attack(att):
	attack = att
func set_defend(def):
	defend = def
func set_reflexes(ref):
	reflexes = ref
func set_accucary(acc):
	accucary = acc
func set_health(hp):
	health = hp
