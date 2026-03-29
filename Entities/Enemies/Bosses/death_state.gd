extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	# 1. Desactivamos todo para que sea un adorno
	enemy.set_physics_process(false)
	if enemy.has_node("HurtboxComponent/CollisionShape2D"):
		enemy.get_node("HurtboxComponent/CollisionShape2D").set_deferred("disabled", true)
	
	# 2. Cámara libre
	var camara = get_viewport().get_camera_2d()
	if camara and camara.has_method("desbloquear_camara"):
		camara.desbloquear_camara()
	
	# 3. Animación final
	if enemy.sprite.sprite_frames.has_animation("Death"):
		enemy.sprite.play("Death")
		await enemy.sprite.animation_finished
		enemy.sprite.stop()
		# Se queda en el último frame
		enemy.sprite.frame = enemy.sprite.sprite_frames.get_frame_count("Death") - 1
	
	# 4. Lo mandamos al fondo
	enemy.z_index = -1
