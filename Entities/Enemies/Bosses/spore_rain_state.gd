extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

func enter(_msg := {}) -> void:
	if enemy.has_method("ataque_patron_lluvia_zigzag"):
		enemy.ataque_patron_lluvia_zigzag()
	
	await get_tree().create_timer(1.5).timeout
	state_machine.transition_to("IdleState")

func exit() -> void:
	pass
