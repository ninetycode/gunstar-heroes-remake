extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

@export var tiempo_espera: float = 2.0
var timer: float = 0.0

func enter(_msg := {}) -> void:
	if enemy and enemy.sprite:
		enemy.sprite.play("Idle")
	timer = tiempo_espera

func physics_update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		state_machine.transition_to("PreAttackState")

func exit() -> void:
	pass
