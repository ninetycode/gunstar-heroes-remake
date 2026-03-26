extends Area2D
signal golpe_acertado
signal choco_pared

@export var danio : int = 10

func _ready() -> void:
	# Nos aseguramos de conectar la señal de los cuerpos sólidos
	body_entered.connect(_on_body_entered)

func _on_area_entered(areachocada: Area2D) -> void:
	if areachocada.has_method("recibir_golpe"):
		areachocada.recibir_golpe(danio)
		golpe_acertado.emit()

func _on_body_entered(body: Node2D) -> void:
	# Magia acá: Usamos 'is' para saber si es el TileMap o chequeamos la capa de forma segura
	# Si el cuerpo está en la Capa 1 (Suelo/Paredes)
	if body is TileMapLayer or body.get_collision_layer_value(1):
		choco_pared.emit()
