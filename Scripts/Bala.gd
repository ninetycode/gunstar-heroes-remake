extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

@onready var sprite = $Sprite2D

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	desactivar()

func _physics_process(delta):
	global_position += direction * speed * delta

func activar(pos: Vector2, dir: Vector2, data: WeaponResource):
	global_position = pos
	direction = dir
	rotation = dir.angle()
	
	# Usamos los datos del recurso! 
	speed = data.velocidad_bala
	if sprite and data.textura_bala:
		sprite.texture = data.textura_bala
		
	visible = true
	set_physics_process(true)

func desactivar():
	visible = false
	set_physics_process(false)
	# Solo la mandamos al cementerio, sin tocar las colisiones
	global_position = Vector2(-9999, -9999)

func _on_visible_on_screen_notifier_2d_screen_exited():
	desactivar()
