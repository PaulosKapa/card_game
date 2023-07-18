extends card
class_name equipement
@export var strength = 10
@export var defend = 10
@export var accucary = 10
@export var reflexes = 10
@export var rank = "defend"

func get_strength():
	return strength
func get_defend():
	return defend
func get_accucary():
	return accucary
func get_reflexes():
	return reflexes
func get_ranked():
	return rank
