extends CanvasLayer

@export var coin_hud: CanvasLayer 
@onready var btn_vida = $VBoxContainer/BtnVida
@onready var btn_escudo = $VBoxContainer/BtnEscudo
@onready var btn_doble_salto = $VBoxContainer/BtnDobleSalto # <-- NUEVA REFERENCIA
@onready var btn_salir = $VBoxContainer/BtnSalir

var menu_abierto: bool = false

func _ready():
	hide()
	btn_vida.pressed.connect(_on_btn_vida_pressed)
	btn_escudo.pressed.connect(_on_btn_escudo_pressed)
	btn_doble_salto.pressed.connect(_on_btn_doble_salto_pressed) # <-- CONEXIÓN
	btn_salir.pressed.connect(_on_btn_salir_pressed)

func abrir_menu():
	actualizar_etiquetas()
	show()
	menu_abierto = true
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(true)
		
	if coin_hud and coin_hud.has_method("forzar_visibilidad"):
		coin_hud.forzar_visibilidad(true)

	btn_vida.grab_focus()

func cerrar_menu():
	hide()
	menu_abierto = false
	
	if coin_hud and coin_hud.has_method("forzar_visibilidad"):
		coin_hud.forzar_visibilidad(false)
		
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(false)

func actualizar_etiquetas():
	var vida_max_actual = 100 + (GameManager.nivel_mejora_vida * 10)
	var escudo_comprado = GameManager.nivel_mejora_escudo * 20
	
	btn_vida.text = "+10 Vida Máx (Nivel " + str(GameManager.nivel_mejora_vida) + ") - Costo: 10"
	
	if escudo_comprado >= vida_max_actual:
		btn_escudo.text = "Escudo AL MÁXIMO (" + str(escudo_comprado) + ")"
		btn_escudo.disabled = true
	else:
		btn_escudo.text = "+20 Escudo Inicial (Nivel " + str(GameManager.nivel_mejora_escudo) + ") - Costo: 5"
		btn_escudo.disabled = false
		
	# --- INTERFAZ DEL DOBLE SALTO AAA ---
	if GameManager.doble_salto_desbloqueado:
		btn_doble_salto.text = "Doble Salto: ADQUIRIDO"
		btn_doble_salto.disabled = true
	else:
		btn_doble_salto.text = "Comprar Doble Salto - Costo: 5"
		btn_doble_salto.disabled = false

func _on_btn_vida_pressed():
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return
	
	var wallet = player.get_node_or_null("WalletComponent")
	var stats = player.get_node_or_null("StatsComponent")
	
	if wallet and wallet.gastar_monedas(10):
		GameManager.nivel_mejora_vida += 1
		if stats:
			stats.aumentar_vida_maxima(10)
		AudioManager.play_sfx("buy_success") 
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error") 

func _on_btn_escudo_pressed():
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return
		
	var wallet = player.get_node_or_null("WalletComponent")
	var stats = player.get_node_or_null("StatsComponent")
	
	if wallet and wallet.gastar_monedas(5):
		GameManager.nivel_mejora_escudo += 1
		if stats:
			stats.agregar_escudo(20)
		AudioManager.play_sfx("buy_success")
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error")

# --- NUEVA FUNCIÓN DE COMPRA ---
func _on_btn_doble_salto_pressed():
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return
	
	var wallet = player.get_node_or_null("WalletComponent")
	
	if wallet and wallet.gastar_monedas(5):
		GameManager.doble_salto_desbloqueado = true
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
