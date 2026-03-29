extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	var tween = create_tween().set_loops(3)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.1, 1.3), 0.15)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.0, 1.0), 0.15)
	
	await tween.finished
	
	# <--- CHEQUEO CLAVE: Si se murió durante el temblor, no ataca
	if not enemy.esta_muerto:
		state_machine.transition_to("SporeRainState")

func exit() -> void:
	pass
