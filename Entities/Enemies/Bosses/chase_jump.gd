extends State

func enter(_msg := {}) -> void:
	owner.sprite.play("run")

func physics_update(_delta: float) -> void:
	if owner.esta_muerto: return
	if not is_instance_valid(owner.player): 
		state_machine.transition_to("Idle")
		return
		
	# Persecución en tiempo real
	var direccion_x = sign(owner.player.global_position.x - owner.global_position.x)
	owner.velocity.x = direccion_x * owner.speed
	owner.mirar_hacia(owner.player.global_position)
	
	# Verificamos si entramos en rango para iniciar el salto preciso
	var distancia = owner.global_position.distance_to(owner.player.global_position)
	if distancia <= owner.jump_range:
		state_machine.transition_to("AttackJump")
