extends State

func enter(_msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	if owner.sprite:
		# Si tenés animación de muerte la ponés acá, sino lo dejamos congelado
		owner.sprite.play("death")
