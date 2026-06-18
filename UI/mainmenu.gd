extends CanvasLayer

# --- REFERENCIAS LIMPIAS ---
@onready var col_principal = $MarginContainer/HBoxContainer/ColumnaPrincipal
@onready var col_jugar = $MarginContainer/HBoxContainer/MarginContainer/ColumnaJugar
@onready var col_partidas = $MarginContainer/HBoxContainer/MarginContainer2/ColumnaPartidas

# Referencias directas a los botones de partida
@onready var btn_partida_1 = col_partidas.get_node("BtnPartida1")
@onready var btn_partida_2 = col_partidas.get_node("BtnPartida2")
@onready var btn_partida_3 = col_partidas.get_node("BtnPartida3")

# Color para la columna activa y la inactiva
const COLOR_ACTIVO = Color.WHITE
const COLOR_APAGADO = Color(0.4, 0.4, 0.4)

func _ready():
	col_jugar.hide()
	col_partidas.hide()
	
	_conectar_clics()
	
	_preparar_navegacion(col_principal)
	_preparar_navegacion(col_jugar)
	_preparar_navegacion(col_partidas)
	
	col_principal.get_node("BtnJugar").grab_focus()

func _preparar_navegacion(columna: VBoxContainer):
	for boton in columna.get_children():
		if boton is Button:
			boton.focus_entered.connect(_on_boton_enfocado.bind(columna))

func _on_boton_enfocado(columna_donde_estoy):
	AudioManager.play_sfx("ui_move") 
	col_principal.modulate = COLOR_ACTIVO if columna_donde_estoy == col_principal else COLOR_APAGADO
	col_jugar.modulate = COLOR_ACTIVO if columna_donde_estoy == col_jugar else COLOR_APAGADO
	col_partidas.modulate = COLOR_ACTIVO if columna_donde_estoy == col_partidas else COLOR_APAGADO

# --- LÓGICA DE DIBUJADO DE LAS PARTIDAS ---

func _actualizar_textos_partidas():
	_configurar_texto_boton(1, btn_partida_1)
	_configurar_texto_boton(2, btn_partida_2)
	_configurar_texto_boton(3, btn_partida_3)

func _configurar_texto_boton(numero: int, boton: Button):
	var info = SaveManager.obtener_info_slot(numero)
	
	if info["vacio"]:
		boton.text = "PARTIDA N°%d   -   Espacio sin guardar" % numero
		# Oscurecemos el texto de la partida vacía
		boton.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	else:
		var texto = "PARTIDA N°%d   |   %s   |   TIEMPO: %s"
		boton.text = texto % [numero, info["fecha"], info["tiempo"]]
		# Nos aseguramos de que el texto brille si hay partida
		boton.add_theme_color_override("font_color", Color.WHITE)

# --- LÓGICA DE CLICS ---

func _on_btn_jugar_pressed():
	AudioManager.play_sfx("ui_accept")
	col_jugar.show()
	col_partidas.hide()
	col_jugar.get_node("BtnNuevo").grab_focus()

func _on_btn_cargar_pressed():
	AudioManager.play_sfx("ui_accept")
	
	# Leemos el disco duro justo antes de mostrar la columna
	_actualizar_textos_partidas() 
	
	col_partidas.show()
	btn_partida_1.grab_focus()

func _on_btn_partida_pressed(slot: int):
	var info = SaveManager.obtener_info_slot(slot)
	
	if info["vacio"]:
		# Si intentan cargar la nada misma, ruidito de error y no hacemos nada
		AudioManager.play_sfx("error") 
	else:
		AudioManager.play_sfx("ui_accept")
		# 1. Cargamos los datos reales al GameManager
		SaveManager.cargar_partida(slot)
		
		# 2. Viajamos al Lobby con todos los stats recuperados
		TransitionManager.viajar_a("res://Levels/Lobby.tscn")

# --- VOLVER ATRÁS ---

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		if col_partidas.visible:
			AudioManager.play_sfx("ui_cancel")
			col_partidas.hide()
			col_jugar.get_node("BtnCargar").grab_focus() 
			get_viewport().set_input_as_handled()
			
		elif col_jugar.visible:
			AudioManager.play_sfx("ui_cancel")
			col_jugar.hide()
			col_principal.get_node("BtnJugar").grab_focus()
			get_viewport().set_input_as_handled()

# --- FUNCIONES DE APOYO ---

func _conectar_clics():
	col_principal.get_node("BtnJugar").pressed.connect(_on_btn_jugar_pressed)
	col_principal.get_node("BtnSalir").pressed.connect(func(): get_tree().quit())
	
	# Cambiamos la ruta directa por el inicio del sistema rogue-like
	col_jugar.get_node("BtnNuevo").pressed.connect(func(): TransitionManager.viajar_a("res://Tutorial.tscn"))
	
	col_jugar.get_node("BtnCargar").pressed.connect(_on_btn_cargar_pressed)
	
	# Conectamos los 3 botones de las partidas al mismo método usando bind()
	btn_partida_1.pressed.connect(_on_btn_partida_pressed.bind(1))
	btn_partida_2.pressed.connect(_on_btn_partida_pressed.bind(2))
	btn_partida_3.pressed.connect(_on_btn_partida_pressed.bind(3))


func _on_btn_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/creditosfinales.tscn")
