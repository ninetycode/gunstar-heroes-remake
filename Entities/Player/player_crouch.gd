extends State

@onready var player = owner

func enter() -> void:
	# 1. Frenamos el movimiento horizontal al instante
	player.velocity.x = 0
	
	# 2. Reproducimos la animación
	player._animated_sprite.play("Crouch")

func physics_update(_delta: float) -> void:
	
	# --- LÓGICA DE GIRO DE SPRITE ---
	# 1. Capturamos la dirección horizontal del input (-1, 0, 1)
	var direction = Input.get_axis("move_left", "move_right")
	
	# 2. Si el jugador está presionando izquierda o derecha
	if direction != 0:
		# Giramos el sprite horizontalmente: 
		# true si mira a la izquierda (direction < 0), false si mira a la derecha
		player._animated_sprite.flip_h = (direction < 0)

	# --- TRANSICIONES DE SALIDA ---
	
	# 1. Si soltamos la tecla de agacharse, volvemos a Idle
	if not Input.is_action_pressed("move_down"):
		state_machine.transition_to("Idle") 
		return # Siempre poné return después de cambiar de estado para cortar la ejecución
		
	# 2. Permitir saltar desde la posición de agachado
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
		return

	# 3. Si el piso desaparece, caemos
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
		return
