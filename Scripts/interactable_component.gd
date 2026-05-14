class_name InteractableComponent
extends Area2D

# Señal que el objeto padre (ej. la compu) va a escuchar
signal interaccion_activada

# Referencia al Sprite del objeto padre para prenderle el shader
@export var sprite_visual: CanvasItem


func enfocar():
	# El jugador lo está mirando. Prendemos el shader a 1 píxel de grosor.
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("line_thickness", 1.5) 

func desenfocar():
	# El jugador miró para otro lado. Apagamos el outline (grosor 0).
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("line_thickness", 0.0)

func interactuar():
	# El jugador apretó la tecla. Disparamos la señal.
	interaccion_activada.emit()
	
func _input(event):
	# Si aprietan el botón de disparo...
	if event.is_action_pressed("disparo"):
		# Revisamos todos los cuerpos que están tocando esta Area2D
		for body in get_overlapping_bodies():
			# Si uno de esos cuerpos es el jugador...
			if body.is_in_group("Player"):
				interactuar() # ¡Disparamos la señal de la computadora!
				
				# Consumimos el input para que el juego no intente hacer otra cosa
				get_viewport().set_input_as_handled()
