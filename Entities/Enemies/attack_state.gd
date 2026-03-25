# attack_state.gd
extends State

func enter(_msg := {}) -> void:
	owner.can_shoot = false # Bloqueamos el permiso apenas entra
	owner.velocity = Vector2.ZERO # Se frena
	owner.sprite.play("Attack") #
	
	# Esperamos un toque para que se vea la animación de carga
	await get_tree().create_timer(0.4).timeout
	
	# DISPARO ÚNICO
	if owner.has_method("disparar_a_jugador"):
		owner.disparar_a_jugador()
	
	# Esperamos a que termine la animación o un breve delay
	await get_tree().create_timer(0.3).timeout
	
	# VOLVEMOS A VOLAR (Esto reinicia el ciclo del ShootTimer)
	state_machine.transition_to("FlyState")
