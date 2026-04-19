extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	if player._animated_sprite.animation != "Jump":
		player._animated_sprite.play("Jump")

func physics_update(_delta: float) -> void:
	# Movimiento horizontal...
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * player.speed if direction != 0 else move_toward(player.velocity.x, 0, player.speed)
	if direction != 0: player._animated_sprite.flip_h = direction < 0

	# --- EL COMBO MORTAL: BUFFER + COYOTE ---
	if player.jump_buffer_counter > 0.0 and player.coyote_timer_counter > 0.0:
		player.jump_buffer_counter = 0.0 # Consumimos el buffer
		player.coyote_timer_counter = 0.0 # ¡CRÍTICO! Consumimos el coyote para no hacer doble salto
		state_machine.transition_to("Jump")
		return

	# Lógica de tocar el piso (con el Buffer)
	if player.is_on_floor():
		if player.jump_buffer_counter > 0.0:
			player.jump_buffer_counter = 0.0
			state_machine.transition_to("Jump")
		else:
			state_machine.transition_to("Idle")

	if player.is_on_floor():
		# Si tocó el piso y tenía el salto guardado en la memoria...
		if player.jump_buffer_counter > 0.0:
			player.jump_buffer_counter = 0.0 # Consumimos el buffer
			state_machine.transition_to("Jump") # ¡Rebota al instante!
		else:
			# Si no había apretado nada, cae normal
			state_machine.transition_to("Idle")
