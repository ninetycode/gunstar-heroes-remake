extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	enemy.velocity = Vector2.ZERO 
	enemy.sprite.play("attack")
	
	# Solo prendemos si no está muerto (doble chequeo)
	if not enemy.esta_muerto:
		var shape = enemy.hitbox.get_node_or_null("CollisionShape2D")
		if shape: shape.set_deferred("disabled", false)
	
	await enemy.sprite.animation_finished
	
	# Si murió durante el ataque, no hacemos la transición a Chase
	if not enemy.esta_muerto:
		state_machine.transition_to("Chase")

func exit() -> void:
	# Apagamos SIEMPRE al salir
	var shape = enemy.hitbox.get_node_or_null("CollisionShape2D")
	if shape: shape.set_deferred("disabled", true)
