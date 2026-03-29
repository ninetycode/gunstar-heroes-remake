extends BaseEnemy # <-- ¡Acá está la magia de la herencia!

@onready var hitbox: Area2D = $HitboxComponent
@onready var state_machine: StateMachine = $StateMachine
# Estas variables son únicas del soldado
@export var speed: float = 150.0
@export var attack_range: float = 40.0

func _physics_process(delta):
	# La variable gravity la hereda directamente de BaseEnemy
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()
	
# Si el soldado necesita hacer algo extra en el _ready(), podés usar:
# func _ready():
# 	super() # <-- Esto llama al _ready() de BaseEnemy primero
#   print("El soldado está listo")
func _on_death():
	# En lugar de llamar a super(), que haría queue_free() directo,
	# forzamos la transición al estado de muerte.
	if state_machine:
		state_machine.transition_to("Death")
