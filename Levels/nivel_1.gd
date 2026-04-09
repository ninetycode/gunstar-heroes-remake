extends Node2D

@onready var cinematic_ui = $CinematicUI
@onready var pyramid_trigger = $PyramidTrigger

# Ajustalo acá directamente. 1.0 es normal, 1.2 es un poquito de zoom.
@export var zoom_nivel: float = 1.2 

func _ready() -> void:
	# Llamamos al AudioManager para que empiece a sonar el tema del nivel
	# El nombre "nivel_1" tiene que ser igual al que pusiste en el diccionario del AudioManager
	AudioManager.play_music("nivel_1", -5.0)

func _on_pyramid_trigger_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "GunstarBlue":
		iniciar_momento_epico()
		pyramid_trigger.set_deferred("monitoring", false)

func iniciar_momento_epico() -> void:
	var camara_activa = get_viewport().get_camera_2d()
	
	# Eliminamos la parte de ocultar el HUD para que se siga viendo
	
	if camara_activa:
		if camara_activa.has_method("activar_diagonal"):
			camara_activa.activar_diagonal()
			
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		# Zoom suave usando la variable de arriba
		tween.tween_property(camara_activa, "zoom", Vector2(zoom_nivel, zoom_nivel), 2.5)
		
		# Un offset pequeño para subir un poco la vista sin pasarse
		tween.tween_property(camara_activa, "offset", Vector2(0, -60), 2.0)
		

# Conectá la señal del nuevo trigger a esta función
func _on_final_piramide_trigger_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "GunstarBlue":
		finalizar_momento_epico()

func finalizar_momento_epico() -> void:
	var camara_activa = get_viewport().get_camera_2d()
	if camara_activa:
		if camara_activa.has_method("desactivar_diagonal"):
			camara_activa.desactivar_diagonal()
		
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camara_activa, "zoom", Vector2(1.0, 1.0), 2.0)
		tween.tween_property(camara_activa, "offset", Vector2(0, -199), 2.0) # Vuelve al centro
