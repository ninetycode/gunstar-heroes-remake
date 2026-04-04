extends Node

signal game_paused(is_paused: bool)

func _ready() -> void:
	# Fundamental: El GameManager nunca debe congelarse
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle_pause() -> void:
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	game_paused.emit(nuevo_estado)

func restart_current_level() -> void:
	# 1. Despausar siempre antes de reiniciar
	get_tree().paused = false
	
	# 2. Frenar la música (recuperamos tu lógica original)
	# (Verificamos que el Singleton exista para no crashear por las dudas)
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(0.0)
	
	# 3. Reinicio a prueba de F6 (Play Scene)
	if get_tree().current_scene != null:
		get_tree().call_deferred("reload_current_scene")
	else:
		# PLAN B: Si current_scene es null, buscamos la escena "a la fuerza".
		# En el Root de Godot, los primeros hijos son los Autoloads, 
		# y el ÚLTIMO hijo siempre es la escena que estás jugando.
		var root = get_tree().root
		var escena_actual = root.get_child(root.get_child_count() - 1)
		get_tree().call_deferred("change_scene_to_file", escena_actual.scene_file_path)

func _input(event: InputEvent) -> void:
	# Agregamos "not event.is_echo()" para que solo reaccione al primer toque de la tecla,
	# ignorando la ametralladora del sistema operativo si dejás el dedo apretado.
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			toggle_pause()
		elif event.keycode == KEY_R:
			restart_current_level()
