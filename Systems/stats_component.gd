extends Node
signal salud_agotada
signal danio_recibido(cantidad) # <-- Agregamos la señal acá

@export var vida_maxima = 100
@export var vida_actual = 100

func recibir_danio(cantidad):
	vida_actual -= cantidad
	danio_recibido.emit(cantidad) # <-- La emitimos para avisar que recibió daño
	if vida_actual <= 0:
		salud_agotada.emit()
