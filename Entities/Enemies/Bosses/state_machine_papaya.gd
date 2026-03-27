extends Node
class_name StateMachineBoss 

@export var initial_state: NodePath
@onready var state: Node = get_node(initial_state)

func _ready() -> void:
	# Esperamos a que el nodo padre (Papaya) esté totalmente cargado en el árbol
	await owner.ready
	
	for child in get_children():
		if "enemy" in child:
			child.enemy = owner
		if "state_machine" in child:
			child.state_machine = self
	
	# Un pequeño delay extra para seguridad total
	await get_tree().process_frame
	if state:
		state.enter()

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)

func _physics_process(delta: float) -> void:
	if state and state.has_method("physics_update"):
		state.physics_update(delta)
