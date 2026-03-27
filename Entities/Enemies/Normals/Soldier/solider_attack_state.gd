extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a ATTACK")
	enemy.velocity = Vector2.ZERO 
	enemy.sprite.play("attack")
	
	# Prendemos la Hitbox al empezar el ataque
	enemy.hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	await enemy.sprite.animation_finished
	state_machine.transition_to("Chase")

func exit() -> void:
	# La apagamos al salir del estado para que no lastime por accidente mientras camina
	enemy.hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
