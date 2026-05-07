extends CanvasLayer

# Asegurate de que estas rutas coincidan con los nombres que le pusiste a tus nodos
@onready var label_monedas = $LabelMonedas
@onready var btn_vida = $VBoxContainer/BtnVida
@onready var btn_escudo = $VBoxContainer/BtnEscudo
@onready var btn_salir = $VBoxContainer/BtnSalir

var menu_abierto: bool = false

func _ready():
	hide()
	# Conectamos las señales de click a nuestras funciones automáticamente
	btn_vida.pressed.connect(_on_btn_vida_pressed)
	btn_escudo.pressed.connect(_on_btn_escudo_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

func abrir_menu():
	actualizar_etiquetas()
	show()
	menu_abierto = true
	
	# Congelamos a Blue igual que en el otro menú
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(false)
		
	# Fundamental para jugar con Joystick/Teclado: le damos el foco al primer botón
	btn_vida.grab_focus()

func cerrar_menu():
	hide()
	menu_abierto = false
	
	# Descongelamos a Blue
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(true)

func actualizar_etiquetas():
	# Mostramos la guita que sacamos del Autoload
	label_monedas.text = "Monedas Disponibles: " + str(GameManager.monedas_totales)
	
	# Actualizamos el texto de los botones para mostrar en qué nivel está la mejora
	btn_vida.text = "+10 Vida Máx (Nivel " + str(GameManager.nivel_mejora_vida) + ") - Costo: 50"
	btn_escudo.text = "+20 Escudo Inicial (Nivel " + str(GameManager.nivel_mejora_escudo) + ") - Costo: 30"

# --- LÓGICA DE TRANSACCIÓN ---

func _on_btn_vida_pressed():
	if GameManager.monedas_totales >= 50:
		GameManager.monedas_totales -= 50
		GameManager.nivel_mejora_vida += 1
		
		AudioManager.play_sfx("buy_success") # <--- Cambiá por tu sonido de compra
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error") # <--- Sonido de "No tenés plata"

func _on_btn_escudo_pressed():
	if GameManager.monedas_totales >= 30:
		GameManager.monedas_totales -= 30
		GameManager.nivel_mejora_escudo += 1
		
		# Como el escudo sí nos lo pueden romper, le cargamos el tanque al Autoload
		GameManager.escudo_persistente += 20
		
		AudioManager.play_sfx("buy_success")
		actualizar_etiquetas()
	else:
		AudioManager.play_sfx("error")

func _on_btn_salir_pressed():
	AudioManager.play_sfx("ui_cancel")
	cerrar_menu()

# Permitimos salir con Escape
func _input(event):
	if not menu_abierto: return
	
	if event.is_action_pressed("ui_cancel"):
		_on_btn_salir_pressed()
		get_viewport().set_input_as_handled()
