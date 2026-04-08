extends Node2D

@onready var cinematic_ui = $CinematicUI
@onready var pyramid_trigger = $PyramidTrigger

func _ready() -> void:
	pass

func _on_pyramid_trigger_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "GunstarBlue" or body.is_in_group("Player"):
		iniciar_momento_epico()
		pyramid_trigger.set_deferred("monitoring", false)

func iniciar_momento_epico() -> void:
	var camara_activa = get_viewport().get_camera_2d()
	var hud = find_child("player_hud", true, false)
	
	if hud: 
		hud.hide()

	if camara_activa:
		# ¡Le avisamos a TU script que empiece a subir con Blue!
		if camara_activa.has_method("activar_diagonal"):
			camara_activa.activar_diagonal()
			
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		# Zoom táctico
		tween.tween_property(camara_activa, "zoom", Vector2(1.4, 1.4), 2.0)
		
		# Como la cámara ahora SÍ sigue a Blue hacia arriba, usamos un offset moderado
		# (-100 en Y) para que la cámara mire por encima de su cabeza hacia la cima.
		tween.tween_property(camara_activa, "offset", Vector2(0, -100), 2.0)
