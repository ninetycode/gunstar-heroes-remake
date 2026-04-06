extends BaseEnemy


enum States { WAITING, TAKEOFF, FLYING }
var current_state = States.WAITING

@onready var machine = $FlyingMachine # Tu escena de la mochila
@onready var anim = $AnimationPlayer

func _ready():
	# Estado inicial: Agachado y mochila apagada
	current_state = States.WAITING
	machine.visible = true 
	# Si la máquina tiene partículas o hélices, las pausamos:
	machine.set_process(false) 
	sprite.play("agachado") # El sprite de la primera captura

func preparar_despegue():
	if current_state != States.WAITING: return
	
	current_state = States.TAKEOFF
	# Pequeño shake o efecto de humo de la mochila
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2(randf_range(-1,1), 0), 0.1).set_loops(10)
	
	await get_tree().create_timer(1.0).timeout
	despegar()

func despegar():
	current_state = States.FLYING
	machine.set_process(true) # Encendemos la lógica de la mochila
	sprite.play("volando")     # El sprite de la segunda captura
	
	# Le damos un impulso inicial hacia arriba
	velocity = Vector2(200, -400) 

func _physics_process(delta):
	if current_state == States.FLYING:
		# Aquí podés usar la lógica de persecución que ya tenías
		# o una simple dirección diagonal
		move_and_slide()
		
