extends BossEnemy
class_name GrowlBoss

@onready var state_machine: StateMachine = $StateMachine 
@onready var hitbox: Area2D = $HitboxComponent 
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D

@export var speed: float = 180.0
@export var jump_range: float = 200.0 # Distancia para gatillar el salto

var esta_muerto: bool = false 
var zarpazos_realizados: int = 0 # Contador para el combo

func _ready() -> void:
	super() # Conecta señales de vida y busca al jugador [cite: 1, 2]
	
	# Aseguramos que la hitbox empiece completamente apagada 
	if hitbox_collision:
		hitbox_collision.set_deferred("disabled", true) 
		
	# Conectamos la señal de cambio de frame de tu Sprite 
	if sprite:
		sprite.frame_changed.connect(_on_sprite_frame_changed)
	
	# Iniciamos la interfaz del Boss mandando la señal global [cite: 15, 16]
	if stats:
		GameEvents.boss_fight_started.emit(nombre_boss, stats.vida_maxima, stats.vida_actual)

func _physics_process(delta: float) -> void:
	if esta_muerto:
		_aplicar_gravedad(delta)
		move_and_slide() 
		return

	_aplicar_gravedad(delta)
	move_and_slide() 

func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# Control de dirección (Mirar al jugador o al objetivo)
func mirar_hacia(posicion_objetivo: Vector2) -> void:
	if sprite:
		var hacia_la_izquierda = posicion_objetivo.x < global_position.x
		sprite.flip_h = hacia_la_izquierda 
		
		# [Inferencia] Deducido del requerimiento de posicionar la hitbox al frente:
		# Si el sprite se voltea, movemos la posición de la Hitbox horizontalmente.
		if hacia_la_izquierda:
			hitbox.position.x = -abs(hitbox.position.x)
		else:
			hitbox.position.x = abs(hitbox.position.x)

func _on_death() -> void:
	if esta_muerto: return 
	esta_muerto = true 
	
	# Apagamos los componentes de colisión de forma diferida 
	if hitbox:
		hitbox.set_deferred("monitoring", false) 
		hitbox.set_deferred("monitorable", false) 
	if hitbox_collision:
		hitbox_collision.set_deferred("disabled", true)
		
	generar_drop(true) # Tiramos loot VIP por ser el jefe [cite: 4, 5, 16]
	GameEvents.boss_died.emit() # Avisamos a la UI y puertas [cite: 1, 15, 16]
	
	if state_machine:
		state_machine.transition_to("Death") # Cambiamos al estado de muerte
		
func _on_sprite_frame_changed() -> void:
	if not hitbox_collision or esta_muerto: 
		return 
		
	match sprite.animation: 
		"attack_zarpazo":
			# Requerimiento: Toda la animación cuenta con la habilitación del ataque
			hitbox_collision.set_deferred("disabled", false) 
			
		"attack_jump":
			# Requerimiento: Solo a partir del frame 13 (de 17 en total)
			if sprite.frame >= 13: 
				hitbox_collision.set_deferred("disabled", false) 
			else:
				hitbox_collision.set_deferred("disabled", true) 
				
		_:
			# En cualquier otra animación ("idle", "run"), la hitbox se mantiene apagada 
			hitbox_collision.set_deferred("disabled", true)		
