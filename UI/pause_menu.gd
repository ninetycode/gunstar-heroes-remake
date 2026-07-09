extends CanvasLayer

@onready var contenedor_botones: VBoxContainer = $FondoOscuro/ContenedorBotones
@onready var contenedor_confirmacion: VBoxContainer = $FondoOscuro/ContenedorConfirmacion
@onready var btn_reanudar: Button = $FondoOscuro/ContenedorBotones/BtnReanudar
@onready var btn_confirmar_no: Button = $FondoOscuro/ContenedorConfirmacion/Label/HBoxContainer/BtnConfirmarNo

func _ready() -> void:
	# Nos aseguramos de que empiece oculto de entrada
	hide()
	contenedor_botones.show()
	contenedor_confirmacion.hide()
	
	# === CONEXIÓN DESACOPLADA AAA ===
	# Escuchamos al GameManager de forma segura sin romper el ciclo de carga
	GameManager.pausa_estado_cambiado.connect(_on_game_manager_pausa_cambiada)

# Esta función se ejecutará sola cada vez que el GameManager emita el cambio
func _on_game_manager_pausa_cambiada(esta_pausado: bool) -> void:
	if esta_pausado:
		abrir_pausa()
	else:
		cerrar_pausa()

# === NUEVA FUNCIÓN CONTROLADA DE APERTURA ===
func abrir_pausa() -> void:
	show()
	contenedor_botones.show()
	contenedor_confirmacion.hide()
	
	# CRÍTICO PARA TECLADO/JOYSTICK: Le damos el foco al primer botón al instante
	btn_reanudar.grab_focus()

# === NUEVA FUNCIÓN CONTROLADA DE CIERRE ===
func cerrar_pausa() -> void:
	hide()

# --- BOTONES DEL MENÚ PRINCIPAL DE PAUSA ---

func _on_btn_reanudar_pressed() -> void:
	AudioManager.play_sfx("ui_cancel")
	GameManager.toggle_pause()

func _on_btn_reiniciar_pressed() -> void:
	AudioManager.play_sfx("ui_accept")
	GameManager.restart_current_level()

func _on_btn_salir_pressed() -> void:
	AudioManager.play_sfx("ui_move")
	contenedor_botones.hide()
	contenedor_confirmacion.show()
	btn_confirmar_no.grab_focus()

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
