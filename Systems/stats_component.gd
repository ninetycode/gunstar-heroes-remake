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
	# 1. Si ya estamos muertos, ignoramos las balas (Chau zombies)
	if vida_actual <= 0:
		return 
		
	vida_actual -= cantidad
	
	# 2. Clampeamos a 0 para que la UI no muestre números negativos
	if vida_actual < 0:
		vida_actual = 0 
		
	danio_recibido.emit(cantidad)
	health_changed.emit(vida_maxima, vida_actual) # (La señal de tu HUD)
	
	# 3. Solo emitimos la muerte si llegamos EXACTAMENTE a 0
	if vida_actual == 0:
		salud_agotada.emit()
