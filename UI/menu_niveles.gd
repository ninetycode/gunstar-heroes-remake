extends CanvasLayer

@export_category("Niveles Disponibles")
@export var niveles_config: Array[LevelConfig]
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
	if niveles_config.is_empty(): return # Usamos la nueva variable
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
	if niveles_config.is_empty(): return 
	
	var config_actual = niveles_config[indice_actual]
	imagen_nivel.texture = config_actual.miniatura
	texto_nivel.text = config_actual.nombre_nivel
	
	# --- LÓGICA DE PROGRESIÓN (COLORES AAA) ---
	if indice_actual < GameManager.nivel_maximo_alcanzado:
		# Ya lo completaste: Verde brillante
		imagen_nivel.modulate = Color(0.0, 1.0, 0.0)
	elif indice_actual == GameManager.nivel_maximo_alcanzado:
		# Es tu nivel actual a superar: Normal
		imagen_nivel.modulate = Color.WHITE
	else:
		# Está bloqueado en el futuro: Gris oscuro
		imagen_nivel.modulate = Color(0.3, 0.3, 0.3)
	
	# --- LÓGICA DE FLECHAS ---
	var tope_izquierdo = (indice_actual == 0)
	var tope_derecho = (indice_actual == niveles_config.size() - 1)
	
	flecha_izq.disabled = tope_izquierdo
	flecha_der.disabled = tope_derecho
	
	flecha_izq.modulate = Color(0.3, 0.3, 0.3) if tope_izquierdo else Color.WHITE
	flecha_der.modulate = Color(0.3, 0.3, 0.3) if tope_derecho else Color.WHITE

func _input(event):
	if not menu_abierto: return 
	
	if event.is_action_pressed("move_right"):
		# FIX: Ahora usamos niveles_config.size() en vez de rutas_niveles
		if indice_actual < niveles_config.size() - 1:
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
	# --- BARRERA DE SEGURIDAD ---
	if indice_actual > GameManager.nivel_maximo_alcanzado:
		AudioManager.play_sfx("error")
		print("Nivel bloqueado.")
		return
	elif indice_actual < GameManager.nivel_maximo_alcanzado:
		AudioManager.play_sfx("error")
		print("Nivel ya completado.")
		return
	
	# Si pasamos los bloqueos, iniciamos la partida
	AudioManager.play_sfx("ui_accept") # Te sugiero agregar un sonido de éxito acá
	cerrar_menu()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats = player.get_node_or_null("StatsComponent")
		var wallet = player.get_node_or_null("WalletComponent")
		
		if stats:
			var monedas_guardar = wallet.monedas_actuales if wallet else GameManager.monedas_totales
			GameManager.guardar_estado_jugador(stats.vida_actual, stats.escudo_actual, monedas_guardar)
			
	if LevelManager.has_method("iniciar_nivel"):
		# Le pasamos el recurso Y el índice
		LevelManager.iniciar_nivel(niveles_config[indice_actual], indice_actual)
	else:
		print("ERROR: No se encontró el LevelManager")
