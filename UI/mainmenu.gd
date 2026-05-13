extends CanvasLayer

# --- REFERENCIAS A LAS COLUMNAS ---
@onready var col_principal = $MarginContainer/HBoxContainer/ColumnaPrincipal
@onready var col_jugar = $MarginContainer/HBoxContainer/ColumnaPrincipal/BtnJugar/MarginContainer/ColumnaJugar
@onready var col_partidas = $MarginContainer/HBoxContainer/ColumnaPrincipal/BtnJugar/MarginContainer/ColumnaJugar/BtnCargar/MarginContainer/ColumnaPartidas


# --- REFERENCIAS A BOTONES CLAVE ---
# Columna Principal
@onready var btn_jugar = col_principal.get_node("BtnJugar")
@onready var btn_opciones = col_principal.get_node("BtnOpciones")
@onready var btn_creditos = col_principal.get_node("BtnCreditos")
@onready var btn_salir = col_principal.get_node("BtnSalir")

# Columna Jugar
@onready var btn_nuevo = col_jugar.get_node("BtnNuevo")
@onready var btn_cargar = col_jugar.get_node("BtnCargar")

# Columna Partidas (Asegurate de que los nombres coincidan con los de tus nodos)
@onready var btn_partida_1 = col_partidas.get_node("BtnPartida1")
@onready var btn_partida_2 = col_partidas.get_node("BtnPartida2")
@onready var btn_partida_3 = col_partidas.get_node("BtnPartida3")

func _ready():
	# 1. Escondemos las sub-columnas
	col_jugar.hide()
	col_partidas.hide()
	
	# 2. Conectamos los botones principales
	btn_jugar.pressed.connect(_on_btn_jugar_pressed)
	btn_opciones.pressed.connect(_on_btn_opciones_pressed)
	btn_creditos.pressed.connect(_on_btn_creditos_pressed)
	btn_salir.pressed.connect(func(): get_tree().quit()) 
	
	# 3. Conectamos los botones de Jugar
	btn_nuevo.pressed.connect(_on_btn_nuevo_pressed)
	btn_cargar.pressed.connect(_on_btn_cargar_pressed)
	
	# 4. Conectamos los botones de Partida usando bind()
	# Le "pegamos" un número a la señal para saber cuál apretaron
	btn_partida_1.pressed.connect(_on_btn_partida_pressed.bind(1))
	btn_partida_2.pressed.connect(_on_btn_partida_pressed.bind(2))
	btn_partida_3.pressed.connect(_on_btn_partida_pressed.bind(3))
	
	btn_jugar.grab_focus()

# --- LÓGICA DE NAVEGACIÓN ENTRE COLUMNAS ---

func _on_btn_jugar_pressed():
	# AudioManager.play_sfx("ui_accept")
	col_jugar.show()
	col_partidas.hide()
	btn_nuevo.grab_focus()

func _on_btn_cargar_pressed():
	# AudioManager.play_sfx("ui_accept")
	col_partidas.show()
	btn_partida_1.grab_focus()

# --- FUNCIONALIDAD REAL ---

func _on_btn_nuevo_pressed():
	# AudioManager.play_sfx("ui_accept")
	print("Iniciando Nuevo Juego...")
	# Usamos el Autoload que creamos para que haga la transición con el shader
	TransitionManager.viajar_a("res://Levels/Lobby.tscn")

# --- PLACEHOLDERS (EN CONSTRUCCIÓN) ---

func _on_btn_opciones_pressed():
	print("Menú de Opciones: ¡Aún no se implementa esto!")
	# AudioManager.play_sfx("ui_error") # Podés poner un ruidito de error si querés

func _on_btn_creditos_pressed():
	print("Créditos: ¡Aún no se implementa esto!")

func _on_btn_partida_pressed(numero: int):
	# Gracias al bind(), esta función recibe el número 1, 2 o 3
	print("Cargando Partida ", numero, ": ¡Aún no se implementa esto!")


# --- LÓGICA PARA "VOLVER ATRÁS" ---
func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		if col_partidas.visible:
			# AudioManager.play_sfx("ui_cancel")
			col_partidas.hide()
			btn_cargar.grab_focus()
			get_viewport().set_input_as_handled()
			
		elif col_jugar.visible:
			# AudioManager.play_sfx("ui_cancel")
			col_jugar.hide()
			btn_jugar.grab_focus()
			get_viewport().set_input_as_handled()
