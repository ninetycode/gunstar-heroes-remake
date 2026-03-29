extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	var tween = create_tween()
	tween.tween_property(enemy.sprite, "skew", 0.2, 0.1)
	tween.tween_property(enemy.sprite, "skew", -0.2, 0.1)
	tween.tween_property(enemy.sprite, "skew", 0.0, 0.1)
	
	await get_tree().create_timer(0.5).timeout
	
	# <--- CHEQUEO CLAVE
	if not enemy.esta_muerto:
		state_machine.transition_to("IdleState")

func exit() -> void:
	pass
