extends CanvasLayer

@onready var contenedor_botones: VBoxContainer = $FondoOscuro/ContenedorBotones
@onready var contenedor_confirmacion: VBoxContainer = $FondoOscuro/ContenedorConfirmacion
@onready var contenedor_opciones: VBoxContainer = $FondoOscuro/ContenedorOpciones

@onready var btn_reanudar: Button = $FondoOscuro/ContenedorBotones/BtnReanudar
@onready var btn_confirmar_no: Button = $FondoOscuro/ContenedorConfirmacion/Label/HBoxContainer/BtnConfirmarNo

@onready var btn_volver_opciones: Button = $FondoOscuro/ContenedorOpciones/BtnVolverOpciones

# Sliders de audio
@onready var slider_musica: HSlider = $FondoOscuro/ContenedorOpciones/HSlider
@onready var slider_sfx: HSlider = $FondoOscuro/ContenedorOpciones/HSlider2


# Variables para guardar las IDs de tus canales/buses del mezclador
var bus_musica_idx: int
var bus_sfx_idx: int

func _ready() -> void:
	hide()
	contenedor_botones.show()
	contenedor_confirmacion.hide()
	contenedor_opciones.hide()
	
	# Buscamos los índices de tus canales en el AudioServer por su nombre exacto.
	# [Inferencia] Si en tu mezclador los llamaste distinto (ej: "Musica" o "Music"), poné ese string acá.
	bus_musica_idx = AudioServer.get_bus_index("Music")
	bus_sfx_idx = AudioServer.get_bus_index("SFX")
	
	# Conectamos las señales de movimiento de los sliders por código
	slider_musica.value_changed.connect(_on_slider_musica_value_changed)
	slider_sfx.value_changed.connect(_on_slider_sfx_value_changed)
	
	# Conectamos tu GameManager de forma desacoplada
	GameManager.pausa_estado_cambiado.connect(_on_game_manager_pausa_cambiada)

func _on_game_manager_pausa_cambiada(esta_pausado: bool) -> void:
	if esta_pausado:
		abrir_pausa()
	else:
		cerrar_pausa()

func abrir_pausa() -> void:
	show()
	contenedor_botones.show()
	contenedor_confirmacion.hide()
	contenedor_opciones.hide()
	btn_reanudar.grab_focus()

func cerrar_pausa() -> void:
	hide()

# --- GESTIÓN DE LOS SLIDERS DE AUDIO (TIEMPO REAL) ---

func _on_slider_musica_value_changed(valor: float) -> void:
	# Convertimos el porcentaje de 0 a 1 en Decibelios logarítmicos
	var db = linear_to_db(valor)
	AudioServer.set_bus_volume_db(bus_musica_idx, db)

func _on_slider_sfx_value_changed(valor: float) -> void:
	var db = linear_to_db(valor)
	AudioServer.set_bus_volume_db(bus_sfx_idx, db)
	# [Inferencia] Hacemos sonar un ruidito rápido para que el jugador tenga feedback de qué tan fuerte quedó
	AudioManager.play_sfx("ui_move", -4.0, 1.0)

# --- BOTONES DEL MENÚ PRINCIPAL DE PAUSA ---

func _on_btn_reanudar_pressed() -> void:
	AudioManager.play_sfx("ui_cancel")
	GameManager.toggle_pause()

func _on_btn_reiniciar_pressed() -> void:
	AudioManager.play_sfx("ui_accept")
	GameManager.restart_current_level()

func _on_btn_opciones_pressed() -> void:
	AudioManager.play_sfx("ui_accept")
	contenedor_botones.hide()
	contenedor_opciones.show()
	# Le damos el foco a la barra deslizante para que se pueda mover con teclado/joystick
	slider_musica.grab_focus()

func _on_btn_salir_pressed() -> void:
	# Método conectado nativamente en tu tscn desde el editor 
	AudioManager.play_sfx("ui_move")
	contenedor_botones.hide()
	contenedor_confirmacion.show()
	btn_confirmar_no.grab_focus()

# --- BOTÓN VOLVER DE LAS OPCIONES ---

func _on_btn_volver_opciones_pressed() -> void:
	AudioManager.play_sfx("ui_cancel")
	contenedor_opciones.hide()
	contenedor_botones.show()
	btn_reanudar.grab_focus()

# --- BOTONES DEL CARTEL DE CONFIRMACIÓN ---

func _on_btn_confirmar_si_pressed() -> void:
	AudioManager.play_sfx("ui_accept")
	get_tree().paused = false
	hide()
	contenedor_botones.show()
	contenedor_confirmacion.hide()
	TransitionManager.viajar_a("res://UI/mainmenu.tscn")

func _on_btn_confirmar_no_pressed() -> void:
	AudioManager.play_sfx("ui_cancel")
	contenedor_confirmacion.hide()
	contenedor_botones.show()
	btn_reanudar.grab_focus()
