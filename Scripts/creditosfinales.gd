extends Control

# Ruta de tu menú principal
const MAIN_MENU_PATH: String = "res://UI/mainmenu.tscn"

# Referencia al nodo del plugin que está adentro de tu escena
@onready var credits_plugin: CT_Credits = $CreditsRoll

func _ready() -> void:
	# === LIMPIEZA ABSOLUTA DE AUDIO ANTES DE LOS CRÉDITOS ===
	# Le clavamos 0.0 para que fulmine la música del jefe al instante
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(0.0)
		
		# [Opcional] Si con Facu quieren poner un tema lindo y tranquilo de fondo:
		# AudioManager.play_music("end", 0.0, 1.0)

	# Nos conectamos a la señal del plugin para saber cuándo terminan de subir los créditos
	if credits_plugin:
		credits_plugin.credits_finished.connect(_on_credits_finished)
	else:
		printerr("¡Ojo Mathi! No encontré el nodo hijo del plugin. Verificá el nombre en el @onready.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("disparo") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		ir_al_menu_principal()

func _on_credits_finished() -> void:
	ir_al_menu_principal()

func ir_al_menu_principal() -> void:
	var error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if error != OK:
		printerr("Hubo un problema al cargar el menú principal. Código de error: ", error)
