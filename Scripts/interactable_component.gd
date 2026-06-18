class_name InteractableComponent
extends Area2D

# Señal que el objeto padre (ej. la compu) va a escuchar 
signal interaccion_activada

# Referencia al Sprite del objeto padre para prenderle el shader 
@export var sprite_visual: CanvasItem


func _ready() -> void:
	# --- LA MAGIA NUEVA ESTÁ ACÁ ---
	# Conectamos las señales nativas del Area2D para detectar cercanía
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func enfocar():
	# El jugador está cerca. Prendemos el shader a 2.0 de grosor.
	if sprite_visual and sprite_visual.material:
		sprite_visual.material.set_shader_parameter("line_thickness", 2.0) 

func desenfocar():
	# El jugador se alejó. Apagamos el outline (grosor 0).
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
				interactuar() # ¡Disparamos la señal! 
				
				# Consumimos el input para que el juego no intente hacer otra cosa 
				get_viewport().set_input_as_handled()


# --- FUNCIONES DE SEÑAL NUEVAS ---

func _on_body_entered(body: Node2D) -> void:
	# Si el cuerpo que entró a nuestra zona es el jugador, lo enfocamos
	if body.is_in_group("Player"):
		enfocar()

func _on_body_exited(body: Node2D) -> void:
	# Si el jugador salió de nuestra zona, lo desenfocamos
	if body.is_in_group("Player"):
		desenfocar()
