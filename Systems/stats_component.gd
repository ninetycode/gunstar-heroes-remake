extends Node
signal salud_agotada
signal danio_recibido(cantidad)

@export var vida_maxima : int = 100 # Le damos un valor por las dudas
var vida_actual : int

func _ready():
	# El _ready se ejecuta cuando el Inspector ya cargó todo,
	# así que acá vida_maxima ya vale los 8000 (o lo que le pongas).
	vida_actual = vida_maxima

func recibir_danio(cantidad):
	vida_actual -= cantidad
	danio_recibido.emit(cantidad)
	if vida_actual <= 0:
		salud_agotada.emit()
