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
	if cinematic_ui:
		cinematic_ui.mostrar_barras()
	
	var camara_activa = get_viewport().get_camera_2d()
	var hud = find_child("player_hud", true, false)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if camara_activa:
		tween.tween_property(camara_activa, "zoom", Vector2(1.5, 1.5), 2.0)
		
	if hud:
		hud.hide()
