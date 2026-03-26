extends Area2D
class_name HurtboxComponent

@export var stats_component : Node 


func recibir_golpe(damage):
	if stats_component != null:
		stats_component.recibir_danio(damage)
