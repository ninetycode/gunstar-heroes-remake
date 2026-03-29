extends Node
class_name StatsComponent 

signal salud_agotada
signal danio_recibido(cantidad)
signal health_changed(vida_maxima, vida_actual) # <-- 1. NUEVA SEÑAL

@export var vida_maxima : int = 100 
var vida_actual : int

func _ready():
	vida_actual = vida_maxima
	# 2. Avisamos al HUD cómo arrancamos
	health_changed.emit(vida_maxima, vida_actual) 

func recibir_danio(cantidad):
	vida_actual -= cantidad
	danio_recibido.emit(cantidad)
	
	# 3. Avisamos al HUD que la vida bajó
	health_changed.emit(vida_maxima, vida_actual) 
	
	if vida_actual <= 0:
		salud_agotada.emit()
