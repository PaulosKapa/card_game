extends character
var anim_name


func get_default_anim():
	$char/AnimationPlayer.play("default")
	
func get_attack_anim():
	$char/AnimationPlayer.play("attack")
	$GPUParticles3D.emitting = true
func get_dodge_anim():
	$char/AnimationPlayer.play("dodge")




