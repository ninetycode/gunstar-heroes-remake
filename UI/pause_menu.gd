extends CanvasLayer

# Conectado a la señal 'pressed' del botón Reanudar
func _on_btn_reanudar_pressed() -> void:
	GameManager.toggle_pause()

# Conectado a la señal 'pressed' del botón Reiniciar
func _on_btn_reiniciar_pressed() -> void:
	# El GameManager ya se encarga de despausar antes de reiniciar
	GameManager.restart_current_level()

# Conectado a la señal 'pressed' del botón Salir
func _on_btn_salir_pressed() -> void:
	# Fundamental despausar el árbol antes de cambiar de escena o salir
	get_tree().paused = false
	# Por ahora cerramos el juego. A futuro acá irá:
	# get_tree().change_scene_to_file("res://Levels/menu_principal.tscn")
	get_tree().quit()
