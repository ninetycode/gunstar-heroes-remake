extends Area2D
#ALERT ESTE SCRIPT VA A MANEJAR EL AREA DONDE SE RECIBE DAÑO
@export var stats_component : Node 

func recibir_golpe(damage):
	if stats_component != null:
		stats_component.recibir_danio(damage)
