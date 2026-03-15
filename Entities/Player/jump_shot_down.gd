extends State

@onready var player = owner

func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	player.velocity.x = direction * player.speed if direction != 0 else move_toward(player.velocity.x, 0, player.speed)
	if direction != 0: player._animated_sprite.flip_h = direction < 0

	# Lógica de disparo y animación
	if Input.is_action_pressed("disparo"):
		var v = Input.get_axis("ui_up", "ui_down")
		
		if v > 0.5:
			# ACÁ EL CAMBIO: Nombre exacto según tu captura "Disparo abajo"
			if player._animated_sprite.animation != "Disparo abajo":
				player._animated_sprite.play("Disparo abajo")
			player.get_node("WeaponComponent").disparar(Vector2.DOWN)
		else:
			# Disparo normal en el aire (frente/arriba)
			if player._animated_sprite.animation != "Jump":
				player._animated_sprite.play("Jump")
			player.get_node("WeaponComponent").disparar(Vector2.ZERO)
	else:
		# Si soltamos disparo, volvemos a caer normal
		state_machine.transition_to("Fall")
		return

	if player.is_on_floor():
		state_machine.transition_to("Idle")
