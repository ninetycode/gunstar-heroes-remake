extends Sprite2D

@export var recurso_dialogo: DialogueResource
@export var titulo_dialogo: String = "Intro"

# Esta es la variable que va a leer el archivo .dialogue
var intro_terminada: bool = false

@onready var interactable_component = $InteractableComponent

func _ready() -> void:
	interactable_component.interaccion_activada.connect(_on_interaccion_activada)
	DialogueManager.dialogue_ended.connect(_on_dialogo_terminado)

func _on_interaccion_activada() -> void:
	if recurso_dialogo:
		# Congelamos al jugador[cite: 2]
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("set_congelado"):
			player.set_congelado(true)
		
		interactable_component.process_mode = Node.PROCESS_MODE_DISABLED
		
		# --- EL CAMBIO ESTÁ ACÁ ---
		# El tercer parámetro le dice al plugin: "Buscá las variables adentro de este NPC"
		DialogueManager.show_dialogue_balloon(recurso_dialogo, titulo_dialogo, [self])

func _on_dialogo_terminado(_resource: DialogueResource) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_congelado"):
		player.set_congelado(false)
		
	interactable_component.process_mode = Node.PROCESS_MODE_INHERIT
