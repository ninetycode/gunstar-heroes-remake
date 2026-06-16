extends CanvasLayer

@export_category("Niveles Disponibles")
@export var rutas_niveles: Array[String] 
@export var miniaturas: Array[Texture2D]
@export var nombres_niveles: Array[String]

var indice_actual: int = 0
var menu_abierto: bool = false

@onready var imagen_nivel = $VBoxContainer/TextureRect
@onready var texto_nivel = $VBoxContainer/Label

func _ready():
	hide()

func abrir_menu():
	# FIX: Cambiado niveles por rutas_niveles
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
	# FIX: Cambiado niveles por rutas_niveles
	if rutas_niveles.is_empty(): return 
	imagen_nivel.texture = miniaturas[indice_actual]
	texto_nivel.text = nombres_niveles[indice_actual]

func _input(event):
	if not menu_abierto: return 
	
	if event.is_action_pressed("move_right"):
		# FIX: Cambiado niveles por rutas_niveles
		indice_actual = (indice_actual + 1) % rutas_niveles.size()
		actualizar_visuales()
		AudioManager.play_sfx("ui_move")
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_left"):
		# FIX: Cambiado niveles por rutas_niveles
		indice_actual = (indice_actual - 1 + rutas_niveles.size()) % rutas_niveles.size()
		actualizar_visuales()
		AudioManager.play_sfx("ui_move")
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
		var wallet = player.get_node_or_null("WalletComponent") # <-- Agregamos la búsqueda de la billetera
		
		if stats:
			# Si por alguna razón no hay billetera (ej: estás probando algo), usamos la global como seguro
			var monedas_guardar = wallet.monedas_actuales if wallet else GameManager.monedas_totales
			
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, monedas_guardar)
			
	
	if LevelManager.has_method("iniciar_nivel"):
		LevelManager.iniciar_nivel()
	else:
		# Por si querés debuguear si el Autoload está bien puesto
		print("ERROR: No se encontró el LevelManager")
