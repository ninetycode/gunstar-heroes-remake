extends State

# Referencia al jugador para poder moverlo y animarlo
@onready var player = owner

func enter() -> void:
	# Cuando entra a este estado, frena al personaje y reproduce la animación
	player.velocity.x = 0
	player._animated_sprite.play("Idle")

func physics_update(_delta: float) -> void:

	if Input.is_action_pressed("move_down") and player.is_on_floor():
		state_machine.transition_to("Crouch")
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
		return

	if Input.is_action_pressed("disparo_fijo"):
		state_machine.transition_to("FixedShoot")
		return
	
	# Si apretamos izquierda o derecha, le decimos a la máquina que pase a "Run"
	if Input.get_axis("move_left", "move_right") != 0:
		state_machine.transition_to("Run")

	# --- LÓGICA DE DISPARO ---
	if Input.is_action_pressed("disparo"):
		# Obtenemos la dirección desde nuestro componente de armas
		var direccion = player.get_node("WeaponComponent").obtener_direccion_apuntado()
		
		# Disparamos (creamos la bala)
		player.get_node("WeaponComponent").disparar()
		
		# Actualizamos el sprite
		player.actualizar_animacion_apuntado(direccion)
	else:
		# Si no dispara, vuelve a la animación normal de Idle
		player._animated_sprite.play("Idle")
