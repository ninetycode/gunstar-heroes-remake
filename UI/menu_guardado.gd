extends CanvasLayer

# --- REFERENCIAS A LA LISTA DE SLOTS ---
@onready var contenedor_slots = $ContenedorSlots/VBoxContainer
@onready var btn_slot_1 = $ContenedorSlots/VBoxContainer/BtnSlot1
@onready var btn_slot_2 = $ContenedorSlots/VBoxContainer/BtnSlot2
@onready var btn_slot_3 = $ContenedorSlots/VBoxContainer/BtnSlot3

# --- REFERENCIAS AL CARTEL DE CONFIRMACIÓN ---
@onready var popup = $PopupConfirmacion
@onready var texto_pregunta = $PopupConfirmacion/PanelCentro/VBoxContainer/TextoPregunta
@onready var btn_si = $PopupConfirmacion/PanelCentro/VBoxContainer/HBoxContainer/BtnSi
@onready var btn_no = $PopupConfirmacion/PanelCentro/VBoxContainer/HBoxContainer/BtnNo
@onready var btn_borrar = $PopupConfirmacion/PanelCentro/VBoxContainer/HBoxContainer/BtnBorrar

var slot_seleccionado: int = 0
var menu_abierto: bool = false

func _ready():
	hide()
	popup.hide()
	
	# 1. Automatizamos la conexión de los botones de Slot usando bind()
	btn_slot_1.pressed.connect(_on_btn_slot_pressed.bind(1))
	btn_slot_2.pressed.connect(_on_btn_slot_pressed.bind(2))
	btn_slot_3.pressed.connect(_on_btn_slot_pressed.bind(3))
	
	# 2. Conectamos los botones del cartel
	btn_si.pressed.connect(_on_btn_si_pressed)
	btn_no.pressed.connect(_on_btn_no_pressed)
	btn_borrar.pressed.connect(_on_btn_borrar_pressed)
	
	# 3. Le agregamos el sonidito de navegación a TODO
	_preparar_sonidos_navegacion(contenedor_slots)
	_preparar_sonidos_navegacion($PopupConfirmacion/PanelCentro/VBoxContainer/HBoxContainer)

# --- INICIO DEL MENÚ ---

func abrir_menu():
	actualizar_textos_slots()
	show()
	popup.hide()
	menu_abierto = true
	
	# Congelamos a Blue para que no camine por atrás
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(false)
		
	btn_slot_1.grab_focus()

func cerrar_menu():
	hide()
	menu_abierto = false
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(true)

# --- LÓGICA DE DIBUJADO DE TEXTOS ---

func actualizar_textos_slots():
	_configurar_texto_boton(1, btn_slot_1)
	_configurar_texto_boton(2, btn_slot_2)
	_configurar_texto_boton(3, btn_slot_3)

func _configurar_texto_boton(numero: int, boton: Button):
	var info = SaveManager.obtener_info_slot(numero)
	
	if info["vacio"]:
		boton.text = "PARTIDA N°%d   -   Espacio sin guardar" % numero
		boton.modulate = Color(0.6, 0.6, 0.6)
	else:
		# --- FIX: Usamos \n para mandar el Tiempo y las Veces abajo ---
		var texto = "PARTIDA N°%d   |   %s\nTIEMPO: %s   |   VECES GUARDADO: %d"
		boton.text = texto % [numero, info["fecha"], info["tiempo"], info["veces"]]
		boton.modulate = Color.WHITE

# --- LÓGICA DE INTERACCIÓN ---

func _on_btn_slot_pressed(numero: int):
	AudioManager.play_sfx("ui_accept")
	slot_seleccionado = numero
	var info = SaveManager.obtener_info_slot(numero)
	
	if info["vacio"]:
		texto_pregunta.text = "¿Guardar partida nueva en el Espacio " + str(numero) + "?"
		btn_borrar.hide() # Si está vacío, no hay nada que borrar
	else:
		texto_pregunta.text = "                                 ATENCIÓN:\n¿Querés sobreescribir o borrar la partida del Espacio " + str(numero) + "?"
		btn_borrar.show() # Si hay partida, mostramos el botón de borrar
		
	popup.show()
	btn_no.grab_focus() # Foco seguro en el NO

func _on_btn_si_pressed():
	AudioManager.play_sfx("ui_accept") # O un sonido glorioso de "Guardado con éxito"
	SaveManager.guardar_partida(slot_seleccionado)
	popup.hide()
	actualizar_textos_slots() # Refrescamos la pantalla para que aparezca la data nueva
	
	# Le devolvemos el control a la lista principal
	var boton_previo = contenedor_slots.get_node("BtnSlot" + str(slot_seleccionado))
	boton_previo.grab_focus()

func _on_btn_no_pressed():
	AudioManager.play_sfx("ui_cancel")
	popup.hide()
	var boton_previo = contenedor_slots.get_node("BtnSlot" + str(slot_seleccionado))
	boton_previo.grab_focus()

func _on_btn_borrar_pressed():
	AudioManager.play_sfx("error") # O el sonido de "eliminar" que prefieras
	SaveManager.borrar_partida(slot_seleccionado)
	popup.hide()
	actualizar_textos_slots() # Se va a volver a poner gris y decir "Espacio sin guardar"
	
	var boton_previo = contenedor_slots.get_node("BtnSlot" + str(slot_seleccionado))
	boton_previo.grab_focus()

# --- NAVEGACIÓN Y CANCELACIÓN ---

func _input(event):
	if not menu_abierto: return
	
	if event.is_action_pressed("ui_cancel"):
		# Si el cartel está abierto, cancelamos la acción y volvemos a la lista
		if popup.visible:
			_on_btn_no_pressed()
			get_viewport().set_input_as_handled()
		# Si estamos en la lista, cerramos el menú entero
		else:
			AudioManager.play_sfx("ui_cancel")
			cerrar_menu()
			get_viewport().set_input_as_handled()

func _preparar_sonidos_navegacion(contenedor: Control):
	for boton in contenedor.get_children():
		if boton is Button:
			boton.focus_entered.connect(func(): AudioManager.play_sfx("ui_move"))
