extends CharacterBody2D

@onready var hitbox: Area2D = $HitboxComponent

@export var speed: float = 150.0
@export var attack_range: float = 40.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D
@onready var stats = $StatsComponent
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	stats.salud_agotada.connect(_on_death)

func _physics_process(delta):
	
	
	# Gravedad para que no flote
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()

func recibir_danio(cantidad):
	stats.recibir_danio(cantidad)
	sprite.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	sprite.modulate = Color(1, 1, 1)

func _on_death():
	queue_free()
