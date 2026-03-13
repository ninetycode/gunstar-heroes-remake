extends Area2D

@export var danio : int = 10


func _ready() -> void:
	pass

func _on_area_entered(areachocada: Area2D) -> void:
	if areachocada.has_method("recibir_golpe"):
		areachocada.recibir_golpe(danio)
