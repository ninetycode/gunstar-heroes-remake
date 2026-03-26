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
	# Magia acá: Solo frena el fuego SI el cuerpo que tocamos está en la Capa 1 (Sólido)
	if body.get_collision_layer_value(1):
		choco_pared.emit()
