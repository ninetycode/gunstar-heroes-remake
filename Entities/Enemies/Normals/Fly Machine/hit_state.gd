extends State

func enter(_msg := {}) -> void:
	# 1. Animación de golpe
	owner.sprite.play("Hit")
	
	# 2. Efecto de cortocircuito (espejado)
	for i in range(6):
		owner.sprite.flip_h = !owner.sprite.flip_h
		owner.sprite.modulate = Color(10, 10, 10) if i % 2 == 0 else Color(1, 1, 1)
		await get_tree().create_timer(0.05).timeout
	
	owner.sprite.modulate = Color(1, 1, 1)
	
	# 3. Verificación de vida usando TUS variables
	if owner.stats.vida_actual > 0:
		state_machine.transition_to("FlyState")
	else:
		# Si muere, BaseEnemy debería detectar la señal 'salud_agotada' 
		# y hacer el queue_free() por vos.
		pass
