extends CharacterBody2D
class_name BaseEnemy # Esto le dice a Godot que este script es una nueva clase reconocida

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null

# [Inferencia] Esta lógica asume que todos tus futuros enemigos tendrán 
# un nodo llamado exactamente "AnimatedSprite2D" y otro "StatsComponent".
@onready var sprite = $AnimatedSprite2D
@onready var stats = $StatsComponent

func _ready():
	# Buscamos al jugador una sola vez al nacer
	player = get_tree().get_first_node_in_group("Player")
	
	# Conectamos las señales genéricas de vida y daño
	if stats:
		stats.salud_agotada.connect(_on_death)
		stats.danio_recibido.connect(_on_danio_recibido)

func _on_danio_recibido(_cantidad: int):
	# El parpadeo blanco genérico para cualquier enemigo
	if sprite:
		sprite.modulate = Color(10, 10, 10)
		await get_tree().create_timer(0.05).timeout
		sprite.modulate = Color(1, 1, 1)

func _on_death():
	# Destrucción genérica (después acá podés sumar explosiones o score)
	queue_free()
