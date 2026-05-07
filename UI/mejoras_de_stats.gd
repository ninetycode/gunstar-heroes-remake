extends Sprite2D

@export var menu_mejoras: CanvasLayer # Arrastrá tu Menú acá en el Inspector

func _ready():
	# 1. Buscamos el componente hijo
	var interactable = get_node_or_null("InteractableComponent")
	
	# 2. Si existe, le conectamos la señal por código
	if interactable:
		# Verificamos si ya está conectada para no duplicar
		if not interactable.interaccion_activada.is_connected(_on_interactable_component_interaccion_activada):
			interactable.interaccion_activada.connect(_on_interactable_component_interaccion_activada)

func _on_interactable_component_interaccion_activada():
	if menu_mejoras:
		menu_mejoras.abrir_menu()
