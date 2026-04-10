class_name SpawnerManager
extends Node2D

signal all_waves_completed

@export_category("Configuración de la Arena")
## Arreglo de recursos (ahora todos saldrán al mismo tiempo)
@export var waves: Array[WaveConfig]
## Límite global de enemigos simultáneos en pantalla
@export var max_concurrent_enemies: int = 5
@export var enemy_container: Node2D

@export_category("Dirección de Spawn")
## Si ambas están marcadas, salen aleatoriamente de cualquier lado.
@export var spawn_lado_izquierdo: bool = true
@export var spawn_lado_derecho: bool = true

var active_enemies: int = 0
var is_spawning: bool = false

# Array de diccionarios para llevar el control independiente de cada WaveConfig
var wave_trackers: Array[Dictionary] = []

func _ready() -> void:
	if not enemy_container:
		enemy_container = get_tree().current_scene

func start_spawning() -> void:
	# Inicializamos los rastreadores para cada tipo de enemigo
	wave_trackers.clear()
	for config in waves:
		wave_trackers.append({
			"config": config,
			"spawned_count": 0,
			"timer": 0.0
		})
	
	is_spawning = true

func _process(delta: float) -> void:
	if not is_spawning:
		return
		
	var all_spawns_finished = true
	
	for tracker in wave_trackers:
		# Verificamos si este tipo de enemigo en particular ya terminó de spawnear
		if tracker["spawned_count"] < tracker["config"].enemy_count:
			all_spawns_finished = false
			
			# Avanzamos su temporizador individual
			tracker["timer"] += delta
			
			# Si pasó su tiempo de espera y no superamos el límite global
			if tracker["timer"] >= tracker["config"].time_between_spawns and active_enemies < max_concurrent_enemies:
				tracker["timer"] = 0.0 # Reiniciamos su reloj
				tracker["spawned_count"] += 1
				active_enemies += 1
				_spawn_enemy(tracker["config"])
				
	# Si TODOS los recursos ya instanciaron su cantidad máxima y no quedan enemigos vivos
	if all_spawns_finished and active_enemies <= 0:
		is_spawning = false
		all_waves_completed.emit()

func _spawn_enemy(config: WaveConfig) -> void:
	var enemy = config.enemy_scene.instantiate() as BaseEnemy
	if not enemy: return
	
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.global_position = _calculate_spawn_position(config)
	
	enemy.is_ambush = true 
	
	enemy_container.add_child(enemy)

func _calculate_spawn_position(config: WaveConfig) -> Vector2:
	var cam = get_viewport().get_camera_2d()
	var spawn_pos = Vector2.ZERO
	
	if cam:
		var screen_size = get_viewport_rect().size / cam.zoom
		var cam_pos = cam.get_screen_center_position()
		
		# --- LÓGICA DE DIRECCIÓN ---
		var is_left = true
		
		if spawn_lado_izquierdo and spawn_lado_derecho:
			# Si ambos están marcados, tiramos la moneda (50/50)
			is_left = randi() % 2 == 0
		elif spawn_lado_izquierdo:
			is_left = true
		elif spawn_lado_derecho:
			is_left = false
		else:
			# Por seguridad, si te olvidás de marcar ambos en el inspector, 
			# forzamos a que salgan aleatorios para que el juego no se rompa.
			is_left = randi() % 2 == 0
			
		var offset_x = (screen_size.x / 2) + 60 
		
		# Aplicamos la posición en base a la decisión anterior
		spawn_pos.x = cam_pos.x - offset_x if is_left else cam_pos.x + offset_x
		
		# Lógica de altura (tu booleano is_flying_enemy en acción)
		if config.is_flying_enemy:
			var techo = cam_pos.y - screen_size.y / 2
			spawn_pos.y = techo + config.spawn_height_offset
		else:
			spawn_pos.y = global_position.y 
			
	return spawn_pos

func _on_enemy_died(_enemy_node: Node) -> void:
	active_enemies -= 1
	
# Función pública para que el ArenaManager corte el chorro de enemigos
func stop_spawning() -> void:
	is_spawning = false
	all_waves_completed.emit()
