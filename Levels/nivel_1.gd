extends Node2D

@onready var cinematic_ui = $CinematicUI
@onready var pyramid_trigger = $PyramidTrigger # Asegurate que se llame así en la escena

func _ready() -> void:
	# Conexión limpia y segura
	if pyramid_trigger:
		pyramid_trigger.body_entered.connect(_on_pyramid_trigger_entered)

func _on_pyramid_trigger_entered(body: Node2D) -> void:
	# Verificamos que sea Blue (por nombre o por grupo)
	if body.name == "Player" or body.name == "GunstarBlue" or body.is_in_group("Player"):
		iniciar_momento_epico()
		# Desconectamos para que la cinemática no se repita si entrás y salís
		pyramid_trigger.body_entered.disconnect(_on_pyramid_trigger_entered)

func iniciar_momento_epico() -> void:
	# 1. Activamos las barras negras
	if cinematic_ui:
		cinematic_ui.mostrar_barras()
	
	# 2. Capturamos la cámara y el HUD
	var camara_activa = get_viewport().get_camera_2d()
	var hud = find_child("player_hud", true, false)
	
	# 3. Tween para zoom y ocultar interfaz
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if camara_activa:
		tween.tween_property(camara_activa, "zoom", Vector2(1.4, 1.4), 1.2)
	
	if hud:
		tween.tween_property(hud, "modulate:a", 0.0, 0.5)
	
	# Acá podés disparar la lógica de los enemigos voladores o el diálogo
	print("Evento: Comienza el ascenso a la pirámide.")
