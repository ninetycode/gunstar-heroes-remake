extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	# Usamos un Tween que solo afecte la escala Y y un poquito la X para que no se mueva la base
	var tween = create_tween().set_loops(3)
	# Se estira hacia arriba (Y) y se ensancha apenas (X)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.1, 1.3), 0.15)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.0, 1.0), 0.15)
	
	await tween.finished
	state_machine.transition_to("SporeRainState")

func exit() -> void:
	pass
