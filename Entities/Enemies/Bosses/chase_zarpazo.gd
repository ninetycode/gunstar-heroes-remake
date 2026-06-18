extends State

var posicion_objetivo: Vector2

func enter(_msg := {}) -> void:
	owner.sprite.play("run")
	
	# Fijamos la ubicación actual del player en este instante exacto
	if is_instance_valid(owner.player):
		posicion_objetivo = owner.player.global_position
	else:
		posicion_objetivo = owner.global_position # Plan B por las dudas
		
	# Volteamos el sprite y la hitbox hacia la posición fijada
	owner.mirar_hacia(posicion_objetivo)

func physics_update(_delta: float) -> void:
	if owner.esta_muerto: return
	
	# Calculamos la dirección en el eje X hacia el punto fijado
	var direccion_x = sign(posicion_objetivo.x - owner.global_position.x)
	
	# Si todavía no llegamos a la ubicación, nos movemos
	if abs(owner.global_position.x - posicion_objetivo.x) > 15.0:
		owner.velocity.x = direccion_x * owner.speed
	else:
		# Llegamos a la ubicación fijada, pasamos al ataque inmediato
		state_machine.transition_to("AttackZarpazo")
