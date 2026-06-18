extends State

func enter(_msg := {}) -> void:
	owner.velocity.x = 0 # Frena en el lugar para atacar
	owner.sprite.play("attack_zarpazo")
	
	# Nos conectamos de forma segura para saber cuándo termina el golpe
	owner.sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if owner.sprite.animation_finished.is_connected(_on_animation_finished):
		owner.sprite.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished() -> void:
	if owner.sprite.animation == "attack_zarpazo":
		owner.zarpazos_realizados += 1 # Sumamos 1 punto al combo
		state_machine.transition_to("Idle")
