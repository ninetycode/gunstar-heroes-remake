extends CanvasLayer

@onready var fondo_galaxia : TextureRect = $Galaxy
@onready var contenedor_ui = $CenterContainer
@onready var btn_si: Button = $CenterContainer/VBoxContainer/HBoxContainer/si
@onready var btn_no: Button = $CenterContainer/VBoxContainer/HBoxContainer/no
@onready var label_monedas: Label = $CenterContainer/VBoxContainer/LabelMonedas

# Reemplazá esto por la ruta real a tu pantalla de inicio
const RUTA_LOBBY = "res://Levels/Lobby.tscn" 

func _ready() -> void:
	
	fondo_galaxia.modulate.a = 0.0
	contenedor_ui.modulate.a = 0.0
	
	btn_si.pressed.connect(_on_btn_si_pressed)
	btn_no.pressed.connect(_on_btn_no_pressed)
	
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(1.0)
		
	_pacificar_enemigos()
	
	# --- CORRECCIÓN DEL BUG 2: EL CAJERO AUTOMÁTICO ---
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats = player.get_node_or_null("StatsComponent")
		if stats:
			# 1. Calculamos cuántas agarró en este ratito (Bolsillo - Banco inicial)
			var monedas_ganadas = stats.monedas_actuales - GameManager.monedas_totales
			if monedas_ganadas < 0: monedas_ganadas = 0 # Por las dudas
			
			# 2. Mostramos el mensaje en pantalla
			if label_monedas:
				label_monedas.text = "Monedas obtenidas: " + str(monedas_ganadas)
				
			# 3. Guardamos TODO en el banco para que viaje con vos al Lobby
			GameManager.monedas_totales = stats.monedas_actuales
			
			# 4. CRÍTICO: Reseteamos la "vida persistente" a -1. 
			# Si no hacemos esto, Blue va a nacer en el Lobby con 0 HP y va a morir infinitamente.
			GameManager.vida_persistente = -1
			GameManager.escudo_persistente = 0

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
	AudioManager.play_sfx("game_over_sound", -1.6)
	# Fase 2: Inmediatamente después de llegar a 1.0, aparecen los botones en 0.5 seg
	tween.tween_property(contenedor_ui, "modulate:a", 1.0, 0.5)
	
	# Fase 3: Le damos el foco al botón "NO" para que el jugador pueda elegir con joystick
	tween.tween_callback(btn_no.grab_focus)

func _on_btn_no_pressed() -> void:
	# Reiniciamos el nivel actual mágicamente
	get_tree().reload_current_scene()

func _on_btn_si_pressed() -> void:
	# Volvemos al menú
	get_tree().change_scene_to_file(RUTA_LOBBY)
