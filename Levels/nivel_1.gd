extends Node2D

@onready var cinematic_ui = $CinematicUI
@onready var pyramid_trigger = $PyramidTrigger

func _ready() -> void:
	# SOLUCIÓN A LA PAUSA:
	# Le decimos a este script que funcione SIEMPRE (para poder escuchar la tecla P)
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Y obligamos a todos los hijos (jugador, enemigos, etc.) a que sí se frenen con la pausa
	for hijo in get_children():
		hijo.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_pyramid_trigger_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "GunstarBlue" or body.is_in_group("Player"):
		iniciar_momento_epico()
		pyramid_trigger.set_deferred("monitoring", false)

func iniciar_momento_epico() -> void:
	if cinematic_ui:
		cinematic_ui.mostrar_barras()
	
	var camara_activa = get_viewport().get_camera_2d()
	var hud = find_child("player_hud", true, false)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if camara_activa:
		tween.tween_property(camara_activa, "zoom", Vector2(1.5, 1.5), 2.0)
		
	if hud:
		hud.hide()

func _input(event):
	# REINICIAR CON LA R
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().paused = false
		
		# --- NUEVA LÍNEA DE AUDIO ---
		# Le decimos al AudioManager que frene la música al instante (0.0 segundos de fade out)
		AudioManager.stop_music(0.0) 
		
		get_tree().call_deferred("reload_current_scene")
	
	# PAUSAR CON LA P
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		get_tree().paused = !get_tree().paused
