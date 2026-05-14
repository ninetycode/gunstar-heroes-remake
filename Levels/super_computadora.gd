extends Sprite2D

@export var menu_selector: CanvasLayer # Te va a aparecer en el Inspector



func _on_interactable_component_interaccion_activada():
	if menu_selector:
		menu_selector.abrir_menu()
