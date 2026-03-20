extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var danio_actual: int = 0
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
	
	# Inyectamos los datos del recurso
	speed = data.velocidad_bala
	danio_actual = data.danio # <--- GUARDAMOS EL DAÑO
	scale = data.escala_bala # <--- CAMBIAMOS EL TAMAÑO
	
	if sprite and data.textura_bala:
		sprite.texture = data.textura_bala
		
	visible = true
	set_physics_process(true)
	$CollisionShape2D.set_deferred("disabled", false)

func desactivar():
	visible = false
	set_physics_process(false)
	# Solo la mandamos al cementerio, sin tocar las colisiones
	global_position = Vector2(-9999, -9999)

func _on_visible_on_screen_notifier_2d_screen_exited():
	desactivar()


func _on_area_entered(area: Area2D) -> void:
	# Si el área que tocamos es un HurtboxComponent...
	if area is HurtboxComponent:
		# Le pedimos al dueño del área que reciba el daño
		if area.get_parent().has_method("recibir_danio"):
			area.get_parent().recibir_danio(danio_actual)
		
		# La bala cumplió su misión: se recicla
		desactivar()
