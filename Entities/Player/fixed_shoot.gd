extends State

@onready var player = owner

func enter(_msg := {}) -> void:
	# Freno total para que no patine
	player.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	# Si suelta el botón de disparo, volvemos a Idle
	if not Input.is_action_pressed("disparo") and not Input.is_action_pressed("disparo_fijo"):
		state_machine.transition_to("Idle")
		return

	# Obtenemos la dirección de la palanca/teclado para las 8 direcciones
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si no hay dirección (solo aprieta disparo), disparamos al frente según el flip
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT

	# 1. Actualizamos la animación (esta es la función que vos ya tenés)
	player.actualizar_animacion_apuntado(input_dir)
	
	# 2. Ejecutamos el disparo a través del componente
	player.get_node("WeaponComponent").disparar(input_dir)
