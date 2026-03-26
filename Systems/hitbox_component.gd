extends Area2D
signal golpe_acertado
signal choco_pared # <--- NUEVA SEÑAL PARA LAS PAREDES

@export var danio : int = 10

func _ready() -> void:
	# Nos conectamos a body_entered para detectar StaticBody2D o TileMaps (Paredes)
	body_entered.connect(_on_body_entered)

func _on_area_entered(areachocada: Area2D) -> void:
	if areachocada.has_method("recibir_golpe"):
		areachocada.recibir_golpe(danio)
		golpe_acertado.emit()

func _on_body_entered(_body: Node2D) -> void:
	# Si tocamos un cuerpo sólido de las físicas, gritamos que chocamos pared
	choco_pared.emit()
