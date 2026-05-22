class_name SpawnerManager
extends Node2D

signal all_waves_completed

@export_category("Configuración de la Arena")
@export var waves: Array[WaveConfig]
@export var max_concurrent_enemies: int = 5
@export var enemy_container: Node2D

@export_category("Dirección de Spawn")
@export var spawn_lado_izquierdo: bool = true
@export var spawn_lado_derecho: bool = true

# Variables de control interno
var active_enemies: int = 0
var current_wave_index: int = 0
var spawned_in_current_wave: int = 0
var timer: float = 0.0
var is_spawning: bool = false

func _ready() -> void:
	if not enemy_container:
		enemy_container = get_tree().current_scene

func start_spawning() -> void:
	current_wave_index = 0
	spawned_in_current_wave = 0
	active_enemies = 0
	is_spawning = true

func stop_spawning() -> void:
	is_spawning = false

# Llama a esto desde el script de tus enemigos cuando mueran
func enemy_died() -> void:
	active_enemies -= 1

func _process(delta: float) -> void:
	if not is_spawning: 
		return
	
	# Verificar si terminamos todas las oleadas configuradas
	if current_wave_index >= waves.size():
		if active_enemies <= 0:
			is_spawning = false
			all_waves_completed.emit()
		return
		
	# Obtener la oleada actual
	var current_wave = waves[current_wave_index]
	
	# Solo spawneamos si no alcanzamos el límite de simultáneos y aún quedan enemigos por spawnear
	if active_enemies < max_concurrent_enemies and spawned_in_current_wave < current_wave.enemy_count:
		timer += delta
		if timer >= current_wave.time_between_spawns:
			_spawn_enemy(current_wave)
			timer = 0.0
	
	# Pasar a la siguiente oleada si terminamos la actual y no quedan enemigos vivos
	if spawned_in_current_wave >= current_wave.enemy_count and active_enemies == 0:
		current_wave_index += 1
		spawned_in_current_wave = 0

func _spawn_enemy(config: WaveConfig) -> void:
	var enemy = config.enemy_scene.instantiate()
	enemy.global_position = _calculate_spawn_position(config)
	
	if enemy_container:
		enemy_container.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)
		
	# Si tu enemigo tiene una función para registrarse en el spawner, úsala aquí
	if enemy.has_method("set_spawner"):
		enemy.set_spawner(self)
		
	spawned_in_current_wave += 1
	active_enemies += 1

func _calculate_spawn_position(config: WaveConfig) -> Vector2:
	var cam = get_viewport().get_camera_2d()
	
	# Si no hay cámara, devolvemos una posición por defecto (0,0) para evitar errores
	if not cam:
		return Vector2.ZERO 
	
	var screen_size = get_viewport_rect().size / cam.zoom
	var cam_pos = cam.get_screen_center_position()
	
	# Lógica de posición horizontal
	var is_left = true
	if spawn_lado_izquierdo and spawn_lado_derecho:
		is_left = randi() % 2 == 0
	elif spawn_lado_izquierdo:
		is_left = true
	elif spawn_lado_derecho:
		is_left = false
		
	var offset_x = (screen_size.x / 2)
	var spawn_x = cam_pos.x - offset_x if is_left else cam_pos.x + offset_x
	var spawn_y = cam_pos.y # Ajusta esto según necesites la altura
	
	return Vector2(spawn_x, spawn_y)
