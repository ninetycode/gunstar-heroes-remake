extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	if player._animated_sprite.animation != "Jump":
		player._animated_sprite.play("Jump")

func physics_update(_delta: float) -> void:
	# Movimiento horizontal en el aire...
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * player.air_speed if direction != 0 else move_toward(player.velocity.x, 0, player.speed)
	if direction != 0: player._animated_sprite.flip_h = direction < 0

	# Lógica al tocar el piso (Acá usamos la memoria del Buffer correctamente)
	if player.is_on_floor():
		# Si tocó el piso y tenía el salto guardado en la memoria (apretó un poquito antes)...
		if player.jump_buffer_counter > 0.0:
			player.jump_buffer_counter = 0.0 # Consumimos el buffer
			state_machine.transition_to("Jump") # ¡Rebota al instante!
		else:
			# Si no había apretado nada, cae normal y se queda quieto
			state_machine.transition_to("Idle")
