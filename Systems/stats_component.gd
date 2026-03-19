extends Node
signal salud_agotada

@export var vida_maxima = 100
@export var vida_actual = 100

func recibir_danio(cantidad):
	vida_actual -= cantidad
	if vida_actual	 <= 0:
		salud_agotada.emit()
