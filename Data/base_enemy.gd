extends CharacterBody2D
class_name BaseEnemy

signal enemy_died(enemy_node: Node) # NUEVA SEÑAL

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null
var is_ambush: bool = false 
@onready var sprite = $AnimatedSprite2D
@onready var stats = $StatsComponent

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if stats:
		stats.salud_agotada.connect(_on_death)
		stats.danio_recibido.connect(_on_danio_recibido)
	add_to_group("Enemies")

func _on_danio_recibido(_cantidad: int):
	if sprite:
		sprite.modulate = Color(10, 10, 10)
		await get_tree().create_timer(0.05).timeout
		sprite.modulate = Color(1, 1, 1)

func _on_death():
	# Emitimos la señal antes de hacer cualquier otra cosa
	enemy_died.emit(self) 
	queue_free()
