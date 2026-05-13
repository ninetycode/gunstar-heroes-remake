extends AnimatedSprite2D

@export var menu_guardado: CanvasLayer 

func _on_interactable_component_interaccion_activada():
	if menu_guardado:
		menu_guardado.abrir_menu()
