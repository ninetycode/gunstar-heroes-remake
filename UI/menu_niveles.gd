extends CanvasLayer

@export_category("Niveles Disponibles")
@export var rutas_niveles: Array[String] 
@export var miniaturas: Array[Texture2D]
@export var nombres_niveles: Array[String]

var indice_actual: int = 0
var menu_abierto: bool = false

# --- NUEVAS REFERENCIAS ---
@onready var imagen_nivel = $HBoxContainer/VBoxContainer/TextureRect
@onready var texto_nivel = $HBoxContainer/VBoxContainer/Label
@onready var flecha_izq = $HBoxContainer/FlechaIzq
@onready var flecha_der = $HBoxContainer/FlechaDer

func _ready():
	hide()

func abrir_menu():
	if rutas_niveles.is_empty(): return
	indice_actual = 0
	actualizar_visuales()
	show()
	menu_abierto = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(true)

func cerrar_menu():
	hide()
	menu_abierto = false
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(false)

func actualizar_visuales():
	if rutas_niveles.is_empty(): return 
	
	imagen_nivel.texture = miniaturas[indice_actual]
	texto_nivel.text = nombres_niveles[indice_actual]
	
	# --- LÓGICA AAA DE UI (ILUMINACIÓN Y APAGADO DE FLECHAS) ---
	
	# 1. Evaluamos si estamos en los bordes
	var tope_izquierdo = (indice_actual == 0)
	var tope_derecho = (indice_actual == rutas_niveles.size() - 1)
	
	# 2. Deshabilitamos o habilitamos la interacción
	flecha_izq.disabled = tope_izquierdo
	flecha_der.disabled = tope_derecho
	
	# 3. Feedback Visual: Color normal (blanco) si está activo, gris oscuro si está inactivo
	flecha_izq.modulate = Color(0.3, 0.3, 0.3) if tope_izquierdo else Color.WHITE
	flecha_der.modulate = Color(0.3, 0.3, 0.3) if tope_derecho else Color.WHITE

func _input(event):
	if not menu_abierto: return 
	
	if event.is_action_pressed("move_right"):
		# Si no llegamos al final del arreglo, avanzamos
		if indice_actual < rutas_niveles.size() - 1:
			indice_actual += 1
			actualizar_visuales()
			AudioManager.play_sfx("ui_move")
		else:
			# Si intentamos chocar contra la pared derecha, suena error
			AudioManager.play_sfx("error")
			
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_left"):
		# Si no estamos en el primer nivel, retrocedemos
		if indice_actual > 0:
			indice_actual -= 1
			actualizar_visuales()
			AudioManager.play_sfx("ui_move")
		else:
			# Si intentamos ir a la izquierda del nivel 1, suena error
			AudioManager.play_sfx("error")
			
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("disparo"):
		get_viewport().set_input_as_handled() 
		viajar_al_nivel()
		
	elif event.is_action_pressed("ui_cancel"): 
		AudioManager.play_sfx("ui_cancel")
		cerrar_menu()
		get_viewport().set_input_as_handled()

func viajar_al_nivel():
	cerrar_menu()
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats = player.get_node_or_null("StatsComponent")
		var wallet = player.get_node_or_null("WalletComponent")
		
		if stats:
			var monedas_guardar = wallet.monedas_actuales if wallet else GameManager.monedas_totales
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, monedas_guardar)
			
	if LevelManager.has_method("iniciar_nivel"):
		LevelManager.iniciar_nivel()
	else:
		print("ERROR: No se encontró el LevelManager")
