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

func empezar_pelea():
	print("LockZone activada, preparando jefe...")
	await get_tree().create_timer(2.0).timeout
	
	pelea_activa = true
	if hurtbox_col:
		hurtbox_col.disabled = false
	
	print("¡Papaya lista para el combate!")

func _on_death():
	if esta_muerto: return # <--- Evita que muera dos veces
	esta_muerto = true
	
	state_machine.transition_to("DeathState")

func ataque_patron_lluvia_zigzag():
	if not arma_espora or not pelea_activa or esta_muerto: return # <--- Seguro extra
	
	var spawn_pos = muzzle_marker.global_position
	for i in range(20):
		var dir = Vector2.UP.rotated(randf_range(-1.2, 1.2))
		var recurso_temp = arma_espora.duplicate()
		recurso_temp.velocidad_bala = arma_espora.velocidad_bala * randf_range(0.7, 1.3)
		BulletPool.get_bullet(spawn_pos, dir, recurso_temp, true)
