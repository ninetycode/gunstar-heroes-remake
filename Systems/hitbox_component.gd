extends Area2D
signal golpe_acertado # <--- NUEVA SEÑAL

@export var danio : int = 10

func _on_area_entered(areachocada: Area2D) -> void:
	if areachocada.has_method("recibir_golpe"):
		areachocada.recibir_golpe(danio)
		golpe_acertado.emit() # <--- AVISAMOS QUE IMPACTÓ
