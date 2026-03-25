# attack_state.gd
extends State

func enter(_msg := {}) -> void:
	owner.can_shoot = false # Reseteamos la bandera
	owner.velocity = Vector2.ZERO
	owner.sprite.play("Attack")
	
	# Lógica de disparo (ejemplo)
	await get_tree().create_timer(0.5).timeout
	owner.disparar_a_jugador()
	
	state_machine.transition_to("FlyState")
