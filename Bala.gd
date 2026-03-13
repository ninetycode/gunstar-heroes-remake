extends Area2D

# --- CONFIGURACIÓN DE TIPOS ---
enum WeaponType { FORCE, LIGHTNING, CHASER, FIRE }

# --- VARIABLES ---
@export var speed: float = 800.0
@export var type: WeaponType = WeaponType.FORCE

var direction: Vector2 = Vector2.RIGHT # Valor por defecto para evitar errores

@onready var sprite = $Sprite2D

# --- CARGA DE TEXTURAS ---
# Asegurate de que esta ruta sea exacta (ojo con los espacios)
var tex_force = preload("res://Sprite Sheets/Bullets/Force_bullet.png")

func _ready():
	# 1. Ajustamos la apariencia según el tipo
	match type:
		WeaponType.FORCE:
			if sprite:
				sprite.texture = tex_force
				scale = Vector2(1, 1)
		# Aquí irán los demás tipos (Lightning, etc) cuando los tengamos

	# 2. Rotamos la bala para que "mire" hacia donde viaja
	rotation = direction.angle()

func _physics_process(delta):
	# Movimiento constante en la dirección asignada
	position += direction * speed * delta

# --- SEÑALES (Asegurate de conectarlas en el editor) ---

# Se borra al salir de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Se borra al chocar con el suelo o paredes (opcional pero recomendado)
func _on_body_entered(body):
	if body.name != "GunstarBlue": # No queremos que Blue se dispare a sí mismo
		queue_free()
