extends StaticBody3D

@export var character_id = 0 
@export var attack = 10
@export var defend = 10
@export var reflexes = 10
@export var accucary = 10
@export var rank = "range" #tank, range, magic
@export var health = 10
var row = 1
func _process(_delta):
	$Label3D.text = str(get_health())
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
func get_ranked():
	return rank
func get_health():
	return health
func get_row():
	return row
	
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
func set_row(r):
	row = r
