extends Node
class_name StateMachineBoss 

@export var initial_state: NodePath
var state: Node = null

func _ready() -> void:
	# 1. Usamos get_parent() que es 100% seguro para encontrar al Jefe Papaya
	var boss = get_parent()
	if not boss.is_node_ready():
		await boss.ready
	
	# 2. Le pasamos las referencias a los estados (hijos)
	for child in get_children():
		child.enemy = boss
		child.state_machine = self
	
	# 3. Asignamos el estado inicial SOLO si existe la ruta
	if initial_state and has_node(initial_state):
		state = get_node(initial_state)
	
	# 4. Esperamos un frame para que todo el juego termine de cargar
	await get_tree().process_frame
	
	# 5. Entramos al estado inicial (si es válido)
	if is_instance_valid(state) and state.has_method("enter"):
		state.enter()

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	
	# Salimos del estado actual (si es válido)
	if is_instance_valid(state) and state.has_method("exit"):
		state.exit()
	
	# Cambiamos al nuevo estado
	state = get_node(target_state_name)
	
	# Entramos al nuevo estado (si es válido)
	if is_instance_valid(state) and state.has_method("enter"):
		state.enter(msg)

func _physics_process(delta: float) -> void:
	# EL BLINDAJE DEFINITIVO: Si el estado no es una instancia válida, no hace NADA.
	if is_instance_valid(state):
		if state.has_method("physics_update"):
			state.physics_update(delta)
