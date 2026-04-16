extends CanvasLayer

@onready var fondo_galaxia : TextureRect = $Galaxy
@onready var contenedor_ui = $CenterContainer
@onready var btn_si: Button = $CenterContainer/VBoxContainer/HBoxContainer/si
@onready var btn_no: Button = $CenterContainer/VBoxContainer/HBoxContainer/no

# Reemplazá esto por la ruta real a tu pantalla de inicio
const RUTA_MENU_PRINCIPAL = "res://UI/pruebamenuinicio.tscn" 

func _ready() -> void:
	# 1. Hacemos todo invisible al arrancar
	fondo_galaxia.modulate.a = 0.0
	contenedor_ui.modulate.a = 0.0
	
	# Conectamos los botones
	btn_si.pressed.connect(_on_btn_si_pressed)
	btn_no.pressed.connect(_on_btn_no_pressed)
	
	# 2. Silenciamos el mundo (fade out de 1 segundo)
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(1.0)
		
	# 3. Mandamos a dormir a los enemigos
	_pacificar_enemigos()
	
	# 4. Arrancamos la secuencia visual
	_animar_aparicion()

func _pacificar_enemigos() -> void:
	# Buscamos a todos los que estén en el grupo "enemigos"
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	
	for enemigo in enemigos:
		# Filtramos a los jefes (asumiendo que tenés la clase BossEnemy)
		if enemigo is BossEnemy:
			continue
			
		# Si tiene máquina de estados, lo forzamos a un estado pasivo
		var sm = enemigo.get_node_or_null("StateMachine")
		if sm:
			# Reseteamos su velocidad para que no sigan patinando
			enemigo.velocity = Vector2.ZERO 
			
			if sm.has_node("IdleState") or sm.has_node("Idle"):
				sm.transition_to("Idle")
			elif sm.has_node("FlyState"):
				# Los voladores vuelven a su estado base de vuelo (sin atacar)
				sm.transition_to("FlyState")
				# Si querés que literalmente "se vayan de la pantalla", 
				# podés darle una velocidad hacia el cielo acá:
				# enemigo.velocity = Vector2(0, -500)

func _animar_aparicion() -> void:
	# Usamos un Tween encadenado
	var tween = create_tween()
	
	# Fase 1: Aparece la galaxia en 2 segundos
	tween.tween_property(fondo_galaxia, "modulate:a", 1.0, 2.0)
	AudioManager.play_sfx("game_over_sound")
	# Fase 2: Inmediatamente después de llegar a 1.0, aparecen los botones en 0.5 seg
	tween.tween_property(contenedor_ui, "modulate:a", 1.0, 0.5)
	
	# Fase 3: Le damos el foco al botón "NO" para que el jugador pueda elegir con joystick
	tween.tween_callback(btn_no.grab_focus)

func _on_btn_no_pressed() -> void:
	# Reiniciamos el nivel actual mágicamente
	get_tree().reload_current_scene()

func _on_btn_si_pressed() -> void:
	# Volvemos al menú
	get_tree().change_scene_to_file(RUTA_MENU_PRINCIPAL)
