extends Node

var enemy: BossEnemy
var state_machine: StateMachineBoss

@export var tiempo_espera: float = 2.0
var timer: float = 0.0

func enter(_msg := {}) -> void:
	timer = tiempo_espera
	if is_instance_valid(enemy) and enemy.sprite:
		enemy.sprite.play("Idle")

func physics_update(delta: float) -> void:
	if not is_instance_valid(enemy) or not enemy.pelea_activa:
		return
		
	timer -= delta
	if timer <= 0:
		state_machine.transition_to("PreAttackState")
