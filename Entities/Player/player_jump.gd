extends State

@onready var player = owner

func enter() -> void:
	# Al entrar al estado, reproducimos animación y aplicamos la fuerza de salto hacia arriba
	player._animated_sprite.play("Jump")
	player.velocity.y = player.jump_velocity

func physics_update(_delta: float) -> void:
	# Permitimos control horizontal en el aire (Air Control)
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		player.velocity.x = direction * player.speed
		player._animated_sprite.flip_h = direction < 0
	else:
		# Si soltamos, se frena de a poco en el aire
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
		
	# Chequeamos si aterrizamos
	if player.is_on_floor():
		# Si aterrizamos y estamos tocando una flecha, pasamos a correr directo
		if direction != 0:
			state_machine.transition_to("Run")
		# Si aterrizamos sin tocar nada, pasamos a Idle
		else:
			state_machine.transition_to("Idle")
