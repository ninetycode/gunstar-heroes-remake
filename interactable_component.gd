class_name InteractableComponent
extends Area2D

# Señal que el objeto padre (ej. la compu) va a escuchar
signal interaccion_activada

# Referencia al Sprite del objeto padre para prenderle el shader
@export var sprite_visual: Sprite2D 

func enfocar():
	# El jugador lo está mirando. Prendemos el shader de outline.
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("width", 1.0) # O el nombre que tenga tu parámetro

func desenfocar():
	# El jugador miró para otro lado. Apagamos el outline.
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("width", 0.0)

func interactuar():
	# El jugador apretó la tecla. Disparamos la señal.
	interaccion_activada.emit()
