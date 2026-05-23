class_name WaveConfig
extends Resource

@export_category("Enemy Setup")
@export var enemy_scene: PackedScene
@export var enemy_count: int = 10
@export var time_between_spawns: float = 1.0

@export_category("Spawn Rules")
## Si es true, aparecerá a la altura definida en spawn_height_offset. 
## Si es false, el spawner buscará el suelo automáticamente.
@export var is_flying_enemy: bool = false
## Altura desde el límite superior de la cámara (solo útil si is_flying_enemy es true)
@export var spawn_height_offset: float = 100.0
