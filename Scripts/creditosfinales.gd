extends Control

# Ruta de tu menú principal
const MAIN_MENU_PATH: String = "res://UI/mainmenu.tscn"

# Referencia al nodo del plugin que está adentro de tu escena
# Nota: Asegurate de que el nombre coincida con cómo se llama el hijo en tu escena
@onready var credits_plugin: CT_Credits = $CreditsRoll

func _ready() -> void:
	# Nos conectamos a la señal del plugin para saber cuándo terminan de subir los créditos
	
	if credits_plugin:
		credits_plugin.credits_finished.connect(_on_credits_finished)
	else:
		printerr("¡Ojo Mathi! No encontré el nodo hijo del plugin. Verificá el nombre en el @onready.")

func _input(event: InputEvent) -> void:
	# Si el jugador presiona el botón de disparo (X) o aceptar (Enter/Espacio)...
	if event.is_action_pressed("disparo") or event.is_action_pressed("ui_accept"):
		# Consumimos el evento para que no interfiera con nada más
		get_viewport().set_input_as_handled()
		# Nos vamos directo al Main Menu
		ir_al_menu_principal()

func _on_credits_finished() -> void:
	# Esta función se ejecuta sola cuando los créditos terminan de subir completos
	ir_al_menu_principal()

func ir_al_menu_principal() -> void:
	# Cambiamos a la escena de tu menú principal
	var error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if error != OK:
		printerr("Hubo un problema al cargar el menú principal. Código de error: ", error)
