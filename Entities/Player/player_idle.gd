extends State

# Referencia al jugador para poder moverlo y animarlo
@onready var player = owner

func enter() -> void:
	# Cuando entra a este estado, frena al personaje y reproduce la animación
	player.velocity.x = 0
	player._animated_sprite.play("Idle")

func physics_update(_delta: float) -> void:
	# Si apretamos izquierda o derecha, le decimos a la máquina que pase a "Run"
	if Input.get_axis("ui_left", "ui_right") != 0:
		state_machine.transition_to("Run")
		
	# Si apretamos saltar, pasamos a "Jump"
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		state_machine.transition_to("Jump")
