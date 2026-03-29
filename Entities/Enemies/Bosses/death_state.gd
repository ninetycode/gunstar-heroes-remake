extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	# 1. Desactivamos la física para que quede inerte
	enemy.set_physics_process(false)
	
	# (Borramos la desactivación de la Hurtbox acá, porque papaya_boss.gd ya lo hace perfecto)
	
	# 2. Cámara libre
	var camara = get_viewport().get_camera_2d()
	if camara and camara.has_method("desbloquear_camara"):
		camara.desbloquear_camara()
	
	# 3. Animación final (Con seguro anti-errores de mayúsculas)
	var anim_name = "Death"
	if not enemy.sprite.sprite_frames.has_animation(anim_name):
		anim_name = "death" # Probamos con minúscula por las dudas
		
	if enemy.sprite.sprite_frames.has_animation(anim_name):
		enemy.sprite.play(anim_name)
		await enemy.sprite.animation_finished
		enemy.sprite.stop()
		# Se queda en el último frame
		enemy.sprite.frame = enemy.sprite.sprite_frames.get_frame_count(anim_name) - 1
	
	# 4. Lo mandamos al fondo para que no tape al jugador
	enemy.z_index = -1
