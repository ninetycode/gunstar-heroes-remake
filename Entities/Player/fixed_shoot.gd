extends State

@onready var player = owner

func enter() -> void:
	# Lo clavamos en el piso
	player.velocity.x = 0

func physics_update(_delta: float) -> void:
	# Si mantenemos apretado, usamos el arma
	if Input.is_action_pressed("disparo"):
		player.get_node("WeaponComponent").disparar()
		
		# Acá después le podés sumar tu lógica de _play_aim_animation
	else:
		# Si soltamos el botón, volvemos a la normalidad
		state_machine.transition_to("Idle")
