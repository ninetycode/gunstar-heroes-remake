extends State

@onready var player = owner

func enter() -> void:
	# Apenas entramos a este estado, clavamos la velocidad a 0
	player.velocity.x = 0

func physics_update(_delta: float) -> void:
	# 1. Leemos las flechitas para ver a dónde apunta
	var direccion = player.get_node("WeaponComponent").obtener_direccion_apuntado()
	
	# 2. Le pasamos esa dirección a la función visual que armamos antes
	player.actualizar_animacion_apuntado(direccion)
	
	# 3. Si además de apuntar, aprieta el gatillo normal, escupe balas
	if Input.is_action_pressed("disparo"):
		player.get_node("WeaponComponent").disparar()

	# 4. Condición de salida: Si suelta el botón de "freno de mano", volvemos a Idle
	if not Input.is_action_pressed("disparo_fijo"):
		state_machine.transition_to("Idle")
