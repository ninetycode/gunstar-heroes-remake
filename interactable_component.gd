class_name InteractableComponent
extends Area2D

# Señal que el objeto padre (ej. la compu) va a escuchar
signal interaccion_activada

# Referencia al Sprite del objeto padre para prenderle el shader
@export var sprite_visual: Sprite2D 

func enfocar():
	# El jugador lo está mirando. Prendemos el shader a 1 píxel de grosor.
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("line_thickness", 1.0) 

func desenfocar():
	# El jugador miró para otro lado. Apagamos el outline (grosor 0).
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("line_thickness", 0.0)

func interactuar():
	# El jugador apretó la tecla. Disparamos la señal.
	interaccion_activada.emit()
