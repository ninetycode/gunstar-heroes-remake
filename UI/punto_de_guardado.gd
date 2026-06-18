extends AnimatedSprite2D
@onready var pc: AnimatedSprite2D = $"."

@export var menu_guardado: CanvasLayer 

func _ready() -> void:
	pc.play("play")
	
func _on_interactable_component_interaccion_activada():
	if menu_guardado:
		menu_guardado.abrir_menu()
