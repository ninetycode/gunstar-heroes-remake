extends State

@onready var enemy = owner

func enter(_msg := {}) -> void:
	print("Soldado: Entrando a ATTACK")
	enemy.velocity = Vector2.ZERO 
	enemy.sprite.play("attack")
	await enemy.sprite.animation_finished
	state_machine.transition_to("Chase")
