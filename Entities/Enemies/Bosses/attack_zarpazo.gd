extends State

func enter(_msg := {}) -> void:
	owner.velocity.x = 0 # Frena en el lugar para atacar
	owner.sprite.play("attack_zarpazo")
	
	# SACAMOS el play_sfx de acá, porque ahora va a sonar por fotograma
	
	# Nos conectamos a las señales del sprite
	owner.sprite.animation_finished.connect(_on_animation_finished)
	owner.sprite.frame_changed.connect(_on_frame_changed)

func exit() -> void:
	# Desconectamos todo de forma segura al salir del estado
	if owner.sprite.animation_finished.is_connected(_on_animation_finished):
		owner.sprite.animation_finished.disconnect(_on_animation_finished)
	if owner.sprite.frame_changed.is_connected(_on_frame_changed):
		owner.sprite.frame_changed.disconnect(_on_frame_changed)

func _on_frame_changed() -> void:
	# Nos aseguramos de estar en la animación correcta
	if owner.sprite.animation == "attack_zarpazo":
		var frame_actual = owner.sprite.frame
		
		# [Inferencia] Supongamos que los arañazos son en el frame 1 y el frame 4.
		# ¡CAMBIÁ estos números por los frames reales de tu animación!
		if frame_actual == 2 or frame_actual == 6:
			AudioManager.play_sfx("boss2_attack")

func _on_animation_finished() -> void:
	if owner.sprite.animation == "attack_zarpazo":
		owner.zarpazos_realizados += 1 # Sumamos 1 punto al combo
		state_machine.transition_to("Idle")
