extends BossEnemy

@export var arma_espora: WeaponResource
@export var enemy_scene: PackedScene # Arrastrá el .tscn del drone acá
@export var spawn_timer_max: float = 5.0

@onready var muzzle_marker: Marker2D = $MuzzleMarker
@onready var state_machine: StateMachineBoss = $StateMachinePapaya
@onready var hurtbox_col: CollisionShape2D = $HurtboxComponent/CollisionShape2D

var spawn_timer: float = 0.0
var active_enemies: Array = []
var pelea_activa: bool = false
var esta_muerto: bool = false

func _ready():
	super()
	if hurtbox_col:
		hurtbox_col.disabled = true
	if stats:
		stats.health_changed.connect(_on_mi_vida_cambio)

func empezar_pelea():
	await get_tree().create_timer(0.5).timeout
	pelea_activa = true
	if hurtbox_col:
		hurtbox_col.disabled = false
	if stats:
		GameEvents.boss_fight_started.emit("Papaya Boss", stats.vida_maxima, stats.vida_actual)

func _process(delta):
	# Manejo de drones solo si la pelea está activa
	if pelea_activa and not esta_muerto:
		actualizar_spawner(delta)

func actualizar_spawner(delta):
	# Limpieza de enemigos muertos
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy))
	
	if active_enemies.size() < 2:
		spawn_timer += delta
		if spawn_timer >= spawn_timer_max:
			spawn_drone()
			spawn_timer = 0.0
	else:
		spawn_timer = 0.0

func spawn_drone():
	for i in range(2):
		if enemy_scene:
			var new_enemy = enemy_scene.instantiate()
			new_enemy.global_position = muzzle_marker.global_position
			get_parent().add_child(new_enemy)
			active_enemies.append(new_enemy)

func _on_death():
	if esta_muerto or not pelea_activa: return 
	
	esta_muerto = true
	pelea_activa = false
	
	# --- CÁMARA LIBERADA ---
	var camara = get_viewport().get_camera_2d()
	if camara and camara.has_method("desbloquear_camara"):
		camara.desbloquear_camara()
	
	if hurtbox_col:
		hurtbox_col.set_deferred("disabled", true)
		
	GameEvents.boss_died.emit()
	
	# --- GENERACIÓN DE LOOT ---
	# Llamamos a la función que heredó del BaseEnemy
	generar_drop(true)
	
	if state_machine:
		state_machine.transition_to("DeathState")

func _on_mi_vida_cambio(_maxima: int, actual: int, _escudo: int):
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
		
func obtener_punto_apuntado() -> Vector2:
	# En vez de devolver el Area2D, devolvemos la posición global 
	# exacta de la caja de colisión (CollisionShape2D) que está en la cabeza.
	if hurtbox_col:
		return hurtbox_col.global_position
		
	# Plan B por si acaso
	return global_position
