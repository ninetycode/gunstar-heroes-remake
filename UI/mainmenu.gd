extends CanvasLayer

# --- REFERENCIAS LIMPIAS (Asegurate de mover los nodos en el editor) ---
@onready var col_principal = $MarginContainer/HBoxContainer/ColumnaPrincipal
@onready var col_jugar = $MarginContainer/HBoxContainer/MarginContainer/ColumnaJugar
@onready var col_partidas = $MarginContainer/HBoxContainer/MarginContainer2/ColumnaPartidas

# Color para la columna activa y la inactiva
const COLOR_ACTIVO = Color.WHITE
const COLOR_APAGADO = Color(0.4, 0.4, 0.4)

func _ready():
	col_jugar.hide()
	col_partidas.hide()
	
	# 1. Conectamos los clics (Igual que antes)
	_conectar_clics()
	
	# 2. CONECTAMOS EL FOCUS (Para sonido y color dinámico)
	_preparar_navegacion(col_principal)
	_preparar_navegacion(col_jugar)
	_preparar_navegacion(col_partidas)
	
	col_principal.get_node("BtnJugar").grab_focus()

# Función para automatizar la escucha de todos los botones de una columna
func _preparar_navegacion(columna: VBoxContainer):
	for boton in columna.get_children():
		if boton is Button:
			# Cada vez que el recuadro de selección entre a este botón...
			boton.focus_entered.connect(_on_boton_enfocado.bind(columna))

func _on_boton_enfocado(columna_donde_estoy):
	# 1. Sonido de movimiento
	AudioManager.play_sfx("ui_move") # <--- Tu sonido de flechitas
	
	# 2. Lógica de colores: Iluminamos solo la columna donde está el focus
	col_principal.modulate = COLOR_ACTIVO if columna_donde_estoy == col_principal else COLOR_APAGADO
	col_jugar.modulate = COLOR_ACTIVO if columna_donde_estoy == col_jugar else COLOR_APAGADO
	col_partidas.modulate = COLOR_ACTIVO if columna_donde_estoy == col_partidas else COLOR_APAGADO

# --- LÓGICA DE CLICS ---

func _on_btn_jugar_pressed():
	AudioManager.play_sfx("ui_accept")
	col_jugar.show()
	col_partidas.hide()
	col_jugar.get_node("BtnNuevo").grab_focus()

func _on_btn_cargar_pressed():
	AudioManager.play_sfx("ui_accept")
	col_partidas.show()
	col_partidas.get_node("BtnPartida1").grab_focus()

# --- VOLVER ATRÁS (Actualizado para que el color reaccione) ---

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		if col_partidas.visible:
			AudioManager.play_sfx("ui_cancel")
			col_partidas.hide()
			col_jugar.get_node("BtnCargar").grab_focus() # Esto disparará el _on_boton_enfocado solo
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
	col_jugar.get_node("BtnNuevo").pressed.connect(func(): TransitionManager.viajar_a("res://Levels/Lobby.tscn"))
	col_jugar.get_node("BtnCargar").pressed.connect(_on_btn_cargar_pressed)
	# ... conectá acá el resto de tus botones de Opciones, Créditos, etc.
