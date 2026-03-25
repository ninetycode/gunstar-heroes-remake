extends Node
class_name StatsComponent 

signal salud_agotada
signal danio_recibido(cantidad)

@export var vida_maxima : int = 100 
var vida_actual : int

func _ready():
	vida_actual = vida_maxima

func recibir_danio(cantidad):
	vida_actual -= cantidad
	danio_recibido.emit(cantidad)
	if vida_actual <= 0:
		salud_agotada.emit()
