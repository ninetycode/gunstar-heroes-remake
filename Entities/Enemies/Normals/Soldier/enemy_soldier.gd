extends BaseEnemy

@onready var hitbox: Area2D = $HitboxComponent
@onready var state_machine = $StateMachine

@export var speed: float = 150.0
@export var attack_range: float = 40.0

var spawner_ref: SpawnerManager = null # Referencia al spawner
var esta_muerto: bool = false

# Llamada desde el SpawnerManager justo después de instanciar al enemigo
func init_enemy(spawner: SpawnerManager):
	spawner_ref = spawner

func _physics_process(delta):
	# Si está muerto, bloqueamos el movimiento y la lógica
	if esta_muerto:
		return

	# Gravedad estándar
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

func _on_death():
	if esta_muerto: 
		return
	
	esta_muerto = true
	
	# 1. Notificar al spawner si existe la referencia
	if spawner_ref:
		spawner_ref.enemy_died()
	
	# 2. Desactivar físicas de forma segura
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		var shape = hitbox.get_node_or_null("CollisionShape2D")
		if shape: 
			shape.set_deferred("disabled", true)
			
	# También desactivamos la colisión principal del enemigo para que no bloquee el paso
	var colision_principal = get_node_or_null("CollisionShape2D")
	if colision_principal:
		colision_principal.set_deferred("disabled", true)
	
	# 3. Transición de estado
	if state_machine:
		generar_drop()
		state_machine.transition_to("Death")
