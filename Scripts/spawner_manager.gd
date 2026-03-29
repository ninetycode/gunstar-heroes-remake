class_name SpawnerManager
extends Node2D

signal wave_finished
signal all_waves_completed

@export_category("Configuración de Oleadas")
## Arreglo de recursos creados en la Fase 3
@export var waves: Array[WaveConfig]
## Límite de enemigos simultáneos en pantalla para evitar saturación
@export var max_concurrent_enemies: int = 5
## Nodo o grupo donde se instanciarán los enemigos para mantener limpio el árbol
@export var enemy_container: Node2D

var current_wave_index: int = 0
var enemies_spawned_current_wave: int = 0
var active_enemies: int = 0

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# [Inferencia] Si no defines un contenedor específico, usamos la escena actual
	if not enemy_container:
		enemy_container = get_tree().current_scene

# Método público que llamará el ArenaManager al bloquear la cámara
func start_spawning() -> void:
	current_wave_index = 0
	_start_current_wave()

func _start_current_wave() -> void:
	if current_wave_index >= waves.size():
		all_waves_completed.emit()
		return
		
	enemies_spawned_current_wave = 0
	var current_wave = waves[current_wave_index]
	
	spawn_timer.wait_time = current_wave.time_between_spawns
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	var current_wave = waves[current_wave_index]
	
	# Pausa el spawn si se alcanzó el límite concurrente
	if active_enemies >= max_concurrent_enemies:
		return 
		
	if enemies_spawned_current_wave < current_wave.enemy_count:
		_spawn_enemy(current_wave)
		enemies_spawned_current_wave += 1
		active_enemies += 1
		
	# Si ya salieron todos los de esta oleada, detenemos el reloj
	if enemies_spawned_current_wave >= current_wave.enemy_count:
		spawn_timer.stop()

func _spawn_enemy(config: WaveConfig) -> void:
	var enemy = config.enemy_scene.instantiate() as BaseEnemy
	if not enemy: return
	
	# Suscripción a la señal de muerte
	enemy.enemy_died.connect(_on_enemy_died)
	
	# Cálculo de posición dinámica
	enemy.global_position = _calculate_spawn_position(config)
	
	enemy_container.add_child(enemy)
	
	# --- NUEVA INYECCIÓN DE ESTADO ---
	# Obligamos al enemigo a volverse agresivo al spawnear en una arena
	if enemy.get("state_machine") and enemy.state_machine.has_node("Chase"):
		enemy.state_machine.transition_to("Chase")

func _calculate_spawn_position(config: WaveConfig) -> Vector2:
	var cam = get_viewport().get_camera_2d()
	var spawn_pos = Vector2.ZERO
	
	if cam:
		var screen_size = get_viewport_rect().size / cam.zoom
		var cam_pos = cam.get_screen_center_position()
		
		# Determinar lado aleatorio (0 = izquierda, 1 = derecha)
		var is_left = randi() % 2 == 0
		var offset_x = (screen_size.x / 2) + 60 # 60 píxeles fuera del límite visual
		
		spawn_pos.x = cam_pos.x - offset_x if is_left else cam_pos.x + offset_x
		
		if config.is_flying_enemy:
			var techo = cam_pos.y - screen_size.y / 2
			spawn_pos.y = techo + config.spawn_height_offset
		else:
			# Para unidades terrestres, se toma la altura Y del propio nodo SpawnerManager
			spawn_pos.y = global_position.y 
			
	return spawn_pos

func _on_enemy_died(_enemy_node: Node) -> void:
	active_enemies -= 1
	var current_wave = waves[current_wave_index]
	
	# Verificamos si la oleada actual fue eliminada por completo
	if enemies_spawned_current_wave >= current_wave.enemy_count and active_enemies <= 0:
		wave_finished.emit()
		current_wave_index += 1
		_start_current_wave()
