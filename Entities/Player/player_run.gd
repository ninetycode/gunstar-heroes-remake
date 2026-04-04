extends State

@onready var player = owner

func physics_update(_delta: float) -> void:
	# PRIORIDAD: Si aprieta disparar, frenamos y cambiamos de estado
	# Usamos 'disparo' o 'disparo_fijo' según tu Input Map

	if Input.is_action_pressed("move_down") and player.is_on_floor():
		state_machine.transition_to("Crouch")
		return

	if Input.is_action_pressed("disparo") or Input.is_action_pressed("disparo_fijo"):
		state_machine.transition_to("FixedShoot")
		return



	# Movimiento normal
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		player.velocity.x = direction * player.speed
		player._animated_sprite.flip_h = direction < 0
		player._animated_sprite.play("Run")
	else:
		state_machine.transition_to("Idle")

	# Salto
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
