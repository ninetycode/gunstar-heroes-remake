extends State # O Node, según cómo hereden tus otros estados

@onready var player = owner
@onready var anim_player = player.get_node_or_null("AnimationPlayer") # Asegurate de que el nombre coincida

var tocando_suelo: bool = false

func enter() -> void:
	tocando_suelo = false
	
	# 1. Teletransportamos a Blue arriba en el cielo al aparecer en la escena
	# (Podés subir o bajar este número según la altura de tus techos/mapas)
	player.global_position.y -= 350
	
	# 2. Reproducimos la animación pero la CONGELAMOS en el frame 1 (speed_scale = 0)
	if anim_player:
		anim_player.play("Intro")
		anim_player.speed_scale = 0.0

func physics_update(delta: float) -> void:
	if not tocando_suelo:
		# 3. Caída vertical ultra rápida (fuerza de rayo)
		player.velocity.x = 0 # Evitamos que se mueva de costado al caer
		player.velocity.y = 1200 
		player.move_and_slide()
		
		# 4. Detectamos el impacto contra el suelo
		if player.is_on_floor():
			tocando_suelo = true
			player.velocity = Vector2.ZERO
			
			# 5. Descongelamos la animación para que se reproduzca el impacto y el resto de la intro
			if anim_player:
				anim_player.speed_scale = 1.0 
				# Nos conectamos a la señal para saber cuándo termina el despliegue
				if not anim_player.animation_finished.is_connected(_on_intro_terminada):
					anim_player.animation_finished.connect(_on_intro_terminada)

func _on_intro_terminada(anim_name: String) -> void:
	if anim_name == "Intro":
		# Desconectamos la señal por seguridad
		if anim_player.animation_finished.is_connected(_on_intro_terminada):
			anim_player.animation_finished.disconnect(_on_intro_terminada)
		
		# 6. ¡Listo! Le pasamos el control al Idle normal
		state_machine.transition_to("Idle")
