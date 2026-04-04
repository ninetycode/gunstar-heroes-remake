extends Node

signal game_paused(is_paused: bool)

# 1. Cargamos la escena de la UI
const PAUSE_MENU_SCENE = preload("res://UI/pause_menu.tscn") # <- ¡Chequeá esta ruta!
var pause_menu_instance: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Instanciamos el menú, lo agregamos al juego y lo ocultamos
	pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu_instance)
	pause_menu_instance.hide()

func toggle_pause() -> void:
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	
	# 3. Prendemos o apagamos el menú visual
	if pause_menu_instance:
		pause_menu_instance.visible = nuevo_estado
		
	game_paused.emit(nuevo_estado)

# ... (El resto de tus funciones restart_current_level e _input quedan exactamente igual)

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
