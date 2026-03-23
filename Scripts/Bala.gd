extends Node2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
@onready var sprite = $Sprite2D
@onready var hitbox_colision = $HitboxComponent/CollisionShape2D

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(desactivar)
	# Nos conectamos a la señal que creamos antes en la Hitbox para reciclarnos
	$HitboxComponent.golpe_acertado.connect(desactivar)
	

func _physics_process(delta):
	global_position += direction * speed * delta

func activar(pos: Vector2, dir: Vector2, data: WeaponResource):
	global_position = pos
	direction = dir
	rotation = dir.angle()
	
	speed = data.velocidad_bala
	danio_actual = data.danio 
	scale = data.escala_bala 
	
	# Le pasamos el daño al componente
	$HitboxComponent.danio = danio_actual
		
	visible = true
	sprite.texture = data.textura_bala
	set_physics_process(true)
	hitbox_colision.set_deferred("disabled", false)
	

func desactivar():
	visible = false
	set_physics_process(false)
	hitbox_colision.set_deferred("disabled", true)
	global_position = Vector2(-9999, -9999)
