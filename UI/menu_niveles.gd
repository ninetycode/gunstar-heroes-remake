extends CanvasLayer

@export_category("Niveles Disponibles")
@export var niveles: Array[PackedScene]
@export var miniaturas: Array[Texture2D]
@export var nombres_niveles: Array[String]

var indice_actual: int = 0
var menu_abierto: bool = false # <-- Candado de seguridad

@onready var imagen_nivel = $VBoxContainer/TextureRect
@onready var texto_nivel = $VBoxContainer/Label

func _ready():
	hide()

func abrir_menu():
	if niveles.is_empty(): return
	indice_actual = 0
	actualizar_visuales()
	show()
	menu_abierto = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# 1. Forzamos a Blue a estar quieto y en Idle antes de congelarlo
		player.velocity = Vector2.ZERO
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").play("Idle")
		
		# 2. MODO PROFESIONAL: Desactivamos el procesamiento completo del nodo
		# Esto apaga físicas, inputs y procesos normales de Blue y sus hijos (StateMachine)
		player.process_mode = Node.PROCESS_MODE_DISABLED 

func cerrar_menu():
	hide()
	menu_abierto = false
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Volvemos a activar a Blue para que pueda moverse de nuevo
		player.process_mode = Node.PROCESS_MODE_INHERIT

func actualizar_visuales():
	if niveles.is_empty(): return 
	imagen_nivel.texture = miniaturas[indice_actual]
	texto_nivel.text = nombres_niveles[indice_actual]

func _input(event):
	if not menu_abierto: return 
	
	if event.is_action_pressed("move_right"):
		indice_actual = (indice_actual + 1) % niveles.size()
		actualizar_visuales()
		AudioManager.play_sfx("ui_move") # <--- CAMBIAR POR TU SONIDO DE MOVER
		get_viewport().set_input_as_handled() # Consumimos el input
		
	elif event.is_action_pressed("move_left"):
		indice_actual = (indice_actual - 1 + niveles.size()) % niveles.size()
		actualizar_visuales()
		AudioManager.play_sfx("ui_move") # <--- CAMBIAR POR TU SONIDO DE MOVER
		get_viewport().set_input_as_handled()
		
	# Aceptamos con el botón de disparo
	elif event.is_action_pressed("disparo"):
		#AudioManager.play_sfx("ui_accept") # <--- CAMBIAR POR TU SONIDO DE ACEPTAR
		
		# 1. PRIMERO consumimos el input mientras el menú sigue vivo
		get_viewport().set_input_as_handled() 
		
		# 2. DESPUÉS viajamos y destruimos la escena
		viajar_al_nivel()
		
	# Cancelamos con Escape
	elif event.is_action_pressed("ui_cancel"): 
		AudioManager.play_sfx("ui_cancel") # <--- CAMBIAR POR TU SONIDO DE CANCELAR/SALIR
		cerrar_menu()
		get_viewport().set_input_as_handled()

func viajar_al_nivel():
	cerrar_menu()
	
	# --- PERSISTENCIA: Guardamos la guita antes de irnos ---
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats = player.get_node_or_null("StatsComponent")
		if stats:
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, stats.monedas_actuales)
			
	# --- VIAJE SEGURO ---
	# call_deferred espera a que el frame actual termine antes de destruir la escena
	get_tree().call_deferred("change_scene_to_packed", niveles[indice_actual])
