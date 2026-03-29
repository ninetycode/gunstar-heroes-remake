extends BossEnemy

@export var arma_espora: WeaponResource
@onready var muzzle_marker: Marker2D = $MuzzleMarker
@onready var state_machine: StateMachineBoss = $StateMachinePapaya
@onready var hurtbox_col: CollisionShape2D = $HurtboxComponent/CollisionShape2D

var pelea_activa: bool = false
var esta_muerto: bool = false # <--- NUEVO: Control de muerte

func _ready():
	super()
	if hurtbox_col:
		hurtbox_col.disabled = true
		
	# NUEVO: Escuchamos nuestra propia vida para avisarle a la UI global
	if stats:
		stats.health_changed.connect(_on_mi_vida_cambio)

func empezar_pelea():
	print("LockZone activada, preparando jefe...")
	await get_tree().create_timer(0.5).timeout
	
	pelea_activa = true
	if hurtbox_col:
		hurtbox_col.disabled = false
	
	# NUEVO: Recién AHORA que se despertó, mandamos la señal para prender la UI
	if stats:
		GameEvents.boss_fight_started.emit("Papaya Boss", stats.vida_maxima, stats.vida_actual)
		
	print("¡Papaya lista para el combate!")

func _on_death():
	# Combinamos los seguros de vida: Evitamos que corra dos veces si ya está muerto o si la pelea ni arrancó
	if esta_muerto or not pelea_activa: return 
	
	esta_muerto = true
	pelea_activa = false
	
	# ¡VITAL! Le apagamos la hitbox YA MISMO para que los tiros lo atraviesen
	if hurtbox_col:
		hurtbox_col.set_deferred("disabled", true)
		
	# Le avisamos a la UI que desaparezca
	GameEvents.boss_died.emit()
	
	# Mandamos a la máquina a hacer la explosión final
	if state_machine:
		state_machine.transition_to("DeathState")

# Función puente: Pasa los datos de vida del stats a la barra del jefe
func _on_mi_vida_cambio(_maxima: int, actual: int):
	if pelea_activa:
		GameEvents.boss_health_changed.emit(actual)

func ataque_patron_lluvia_zigzag():
	if not arma_espora or not pelea_activa or esta_muerto: return # <--- Seguro extra
	
	var spawn_pos = muzzle_marker.global_position
	for i in range(20):
		var dir = Vector2.UP.rotated(randf_range(-1.2, 1.2))
		var recurso_temp = arma_espora.duplicate()
		recurso_temp.velocidad_bala = arma_espora.velocidad_bala * randf_range(0.7, 1.3)
		BulletPool.get_bullet(spawn_pos, dir, recurso_temp, true)
