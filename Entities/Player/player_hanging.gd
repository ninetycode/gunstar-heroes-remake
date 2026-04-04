extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	player.velocity = Vector2.ZERO
	player._animated_sprite.play("Hanging")
	# Desactivamos la gravedad mientras cuelga
	player.gravity_enabled = false 

func physics_update(_delta: float) -> void:
	# 1. Movimiento lateral mientras cuelga
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * (player.speed * 0.6) # Más lento al colgar
	
	if direction != 0:
		player._animated_sprite.flip_h = direction < 0

	# 2. SALIDA: Si presiona salto, se suelta hacia arriba
	if Input.is_action_just_pressed("jump"):
		player.gravity_enabled = true
		state_machine.transition_to("Jump")
		return

	# 3. SALIDA: Si presiona abajo, se deja caer
	if Input.is_action_just_pressed("move_down"):
		player.gravity_enabled = true
		state_machine.transition_to("Fall")
		return

	# 4. Disparo (Opcional: podés permitir disparar mientras cuelga)
	if Input.is_action_pressed("disparo"):
		player.get_node("WeaponComponent").disparar(Vector2.ZERO)
