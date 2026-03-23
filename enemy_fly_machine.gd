extends CharacterBody2D

@export var velocidad = 100.0
@export var distancia_ideal = 250.0  # La distancia que quiere mantener de Blue
@export var margen_error = 50.0      # Para que no esté vibrando constantemente
@onready var player = get_tree().get_first_node_in_group("player")

var tiempo_onda = 0.0

func _physics_process(delta):
	if not player: return

	# 1. Calculamos la distancia actual en el eje X
	var vector_al_jugador = player.global_position - global_position
	var distancia_x = abs(vector_al_jugador.x)
	var dir_h = sign(vector_al_jugador.x)

	# 2. Lógica de "Mantener Distancia"
	if distancia_x > distancia_ideal + margen_error:
		# Está muy lejos -> Se acerca
		velocity.x = dir_h * velocidad
	elif distancia_x < distancia_ideal - margen_error:
		# Está muy cerca -> Retrocede (huye)
		velocity.x = -dir_h * velocidad
	else:
		# Está en la zona ideal -> Se queda quieto en X
		velocity.x = move_toward(velocity.x, 0, velocidad * delta)

	# 3. Flote visual (Onda suave en Y para que no parezca una estatua)
	tiempo_onda += delta * 3.0
	velocity.y = sin(tiempo_onda) * 30.0 

	# 4. Mirar siempre hacia el jugador
	$AnimatedSprite2D.flip_h = dir_h > 0
	
	move_and_slide()
