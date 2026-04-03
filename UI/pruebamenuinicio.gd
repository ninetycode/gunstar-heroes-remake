extends Control

func _input(event):
	# "ui_accept" es el Enter por defecto en Godot
	if event.is_action_pressed("ui_accept"):
		# [cite: 21] Asegurate que la ruta sea exactamente donde tenés tu nivel 1
		get_tree().change_scene_to_file("res://Levels/nivel1.tscn")
