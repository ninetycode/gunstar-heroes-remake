extends CanvasLayer

@onready var label_monedas = $LabelMonedas
@onready var btn_vida = $VBoxContainer/BtnVida
@onready var btn_escudo = $VBoxContainer/BtnEscudo
@onready var btn_salir = $VBoxContainer/BtnSalir

var menu_abierto: bool = false

func _ready():
	hide()
	btn_vida.pressed.connect(_on_btn_vida_pressed)
	btn_escudo.pressed.connect(_on_btn_escudo_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

func abrir_menu():
	actualizar_etiquetas()
	show()
	menu_abierto = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(false)
	btn_vida.grab_focus()

func cerrar_menu():
	hide()
	menu_abierto = false
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(true)

func actualizar_etiquetas():
	label_monedas.text = "Monedas Disponibles: " + str(GameManager.monedas_totales)
	
	# Calculamos los topes actuales
	var vida_max_actual = 100 + (GameManager.nivel_mejora_vida * 10)
	var escudo_comprado = GameManager.nivel_mejora_escudo * 20
	
	btn_vida.text = "+10 Vida Máx (Nivel " + str(GameManager.nivel_mejora_vida) + ") - Costo: 50"
	
	# --- LÍMITE DE ESCUDO ---
	if escudo_comprado >= vida_max_actual:
		btn_escudo.text = "Escudo AL MÁXIMO (" + str(escudo_comprado) + ")"
		btn_escudo.disabled = true # Apagamos el botón visualmente
	else:
		btn_escudo.text = "+20 Escudo Inicial (Nivel " + str(GameManager.nivel_mejora_escudo) + ") - Costo: 30"
		btn_escudo.disabled = false

func _on_btn_vida_pressed():
	if GameManager.monedas_totales >= 50:
		GameManager.monedas_totales -= 50
		GameManager.nivel_mejora_vida += 1
		
		# --- FIX: ACTUALIZAR A BLUE EN VIVO ---
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var stats = player.get_node_or_null("StatsComponent")
			if stats:
				stats.vida_maxima += 10
				stats.vida_actual += 10 # Se cura instantáneamente el excedente
				stats.health_changed.emit(stats.vida_maxima, stats.vida_actual, stats.escudo_actual)
				
		AudioManager.play_sfx("buy_success") 
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error") 

func _on_btn_escudo_pressed():
	if GameManager.monedas_totales >= 30:
		GameManager.monedas_totales -= 30
		GameManager.nivel_mejora_escudo += 1
		
		# --- FIX: ACTUALIZAR A BLUE EN VIVO ---
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var stats = player.get_node_or_null("StatsComponent")
			if stats:
				stats.escudo_actual += 20
				stats.health_changed.emit(stats.vida_maxima, stats.vida_actual, stats.escudo_actual)
				
		AudioManager.play_sfx("buy_success")
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error")

func _on_btn_salir_pressed():
	AudioManager.play_sfx("ui_cancel")
	cerrar_menu()

func _input(event):
	if not menu_abierto: return
	if event.is_action_pressed("ui_cancel"):
		_on_btn_salir_pressed()
		get_viewport().set_input_as_handled()
