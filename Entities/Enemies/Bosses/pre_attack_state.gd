extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	# El efecto de inflarse que pediste
	var tween = create_tween().set_loops(3)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(enemy.sprite, "scale", Vector2(1.0, 1.0), 0.15)
	
	await tween.finished
	state_machine.transition_to("SporeRainState")

func exit() -> void:
	pass
