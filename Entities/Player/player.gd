extends CharacterBody2D

const BULLET_SCENE = preload("res://Bullet.tscn")

@export var speed = 300.0
@export var jump_velocity = -500.0
@export var gravity = 1200.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime

func _physics_process(delta):
	# La gravedad se aplica siempre
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Movemos al personaje según lo que digan los estados
	move_and_slide()
