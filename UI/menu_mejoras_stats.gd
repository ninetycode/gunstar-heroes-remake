extends CanvasLayer

@export var coin_hud: CanvasLayer 
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
	if player and player.has_method("set_congelado"):
		player.set_congelado(true)
	# --- NUEVO: Mostramos el HUD de monedas ---
	if coin_hud and coin_hud.has_method("forzar_visibilidad"):
		coin_hud.forzar_visibilidad(true)
	

	btn_vida.grab_focus()

func cerrar_menu():
	hide()
	menu_abierto = false
	
	# --- NUEVO: Escondemos el HUD de monedas ---
	if coin_hud and coin_hud.has_method("forzar_visibilidad"):
		coin_hud.forzar_visibilidad(false)
		
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(false)

func actualizar_etiquetas():
	# Ya no necesitamos actualizar el label de monedas acá, 
	# porque el CoinHUD se actualiza solo por señales.
	
	var vida_max_actual = 100 + (GameManager.nivel_mejora_vida * 10)
	var escudo_comprado = GameManager.nivel_mejora_escudo * 20
	
	btn_vida.text = "+10 Vida Máx (Nivel " + str(GameManager.nivel_mejora_vida) + ") - Costo: 50"
	
	if escudo_comprado >= vida_max_actual:
		btn_escudo.text = "Escudo AL MÁXIMO (" + str(escudo_comprado) + ")"
		btn_escudo.disabled = true
	else:
		btn_escudo.text = "+20 Escudo Inicial (Nivel " + str(GameManager.nivel_mejora_escudo) + ") - Costo: 30"
		btn_escudo.disabled = false

func _on_btn_vida_pressed():
	if GameManager.monedas_totales >= 50:
		GameManager.monedas_totales -= 50
		GameManager.nivel_mejora_vida += 1
		
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var stats = player.get_node_or_null("StatsComponent")
			if stats:
				stats.vida_maxima += 10
				stats.vida_actual += 10
				stats.health_changed.emit(stats.vida_maxima, stats.vida_actual, stats.escudo_actual)
				
		GameManager.monedas_globales_actualizadas.emit(GameManager.monedas_totales)
		AudioManager.play_sfx("buy_success") 
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error") 

func _on_btn_escudo_pressed():
	if GameManager.monedas_totales >= 30:
		GameManager.monedas_totales -= 30
		GameManager.nivel_mejora_escudo += 1
		
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var stats = player.get_node_or_null("StatsComponent")
			if stats:
				stats.escudo_actual += 20
				stats.health_changed.emit(stats.vida_maxima, stats.vida_actual, stats.escudo_actual)
				
		GameManager.monedas_globales_actualizadas.emit(GameManager.monedas_totales)
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
