extends BaseEnemy

@onready var hitbox: Area2D = $HitboxComponent
@onready var state_machine = $StateMachine

@export var speed: float = 150.0
@export var attack_range: float = 40.0

var esta_muerto: bool = false

func _physics_process(delta):
	if esta_muerto:
		# Si está muerto, solo cae por gravedad, nada de seguir al player
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_death():
	super()
	if esta_muerto: return
	esta_muerto = true
	enemy_died.emit(self)
	
	# --- SOLUCIÓN POST-MORTEM (CON SET_DEFERRED) ---
	if hitbox:
		# Le decimos al motor que lo apague en el próximo frame seguro
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		
		var shape = hitbox.get_node_or_null("CollisionShape2D")
		if shape: shape.set_deferred("disabled", true)
	
	if state_machine:
		state_machine.transition_to("Death")
