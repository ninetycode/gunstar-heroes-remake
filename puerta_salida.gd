extends Area2D

# Podés cambiar la ruta desde el inspector si tu Lobby está en otra carpeta
@export_file("*.tscn") var ruta_lobby: String = "res://Levels/Lobby.tscn"

func _ready() -> void:
	# Conectamos la señal automáticamente por código para evitar errores
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Cambiamos directamente a la escena del Lobby
		get_tree().change_scene_to_file(ruta_lobby)
