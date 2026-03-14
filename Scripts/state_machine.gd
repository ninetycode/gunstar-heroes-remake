extends Node
class_name StateMachine

@export var initial_state : State

var current_state : State

func _ready() -> void:
	#le damos un rato para que los nodos carguen bien
	await owner.ready
	
	#recorremos todos los nodos hijos y le pasamos la referencia
	for child in get_children():
		if child is State:
			child.state_machine = self
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# Esta es la función mágica que usaremos para cambiar de estado
func transition_to(target_state_name: String) -> void:
	if not has_node(target_state_name):
		return
		
	var new_state = get_node(target_state_name)
	
	# Apagamos el estado actual
	current_state.exit()
	
	# Cambiamos al nuevo y lo prendemos
	current_state = new_state
	current_state.enter()
