extends Node2D

@onready var cinematic_ui = $CinematicUI
@onready var pyramid_trigger = $PyramidTrigger

func _ready() -> void:
	# ERROR 1 ARREGLADO: Dejamos el _ready vacío. 
	# Facu ya conectó la señal desde el editor (la flechita verde en los nodos).
	# Si la intentamos conectar por código de nuevo acá, Godot tira error de duplicado y crashea.
	pass

func _on_pyramid_trigger_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "GunstarBlue" or body.is_in_group("Player"):
		iniciar_momento_epico()
		# Apagamos el trigger de forma segura para evitar las advertencias amarillas
		pyramid_trigger.set_deferred("monitoring", false)

func iniciar_momento_epico() -> void:
	if cinematic_ui:
		cinematic_ui.mostrar_barras()
	
	var camara_activa = get_viewport().get_camera_2d()
	var hud = find_child("player_hud", true, false)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if camara_activa:
		tween.tween_property(camara_activa, "zoom", Vector2(1.5, 1.5), 2.0)
		# BUG DE CÁMARA ARREGLADO: Ya no bloqueamos la cámara. 
		# Ahora va a hacer el zoom pero te va a seguir centrando para que las barras negras no te tapen.
		
	if hud:
		# ERROR 2 ARREGLADO: El HUD es un "CanvasLayer". 
		# Los CanvasLayer no tienen transparencia (modulate), por eso el juego explotaba cuando el tween intentaba volverlo invisible.
		# La forma correcta y segura es simplemente apagarlo de golpe así:
		hud.hide()
