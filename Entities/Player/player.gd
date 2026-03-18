extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 1200.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var muzzle = $AnimatedSprite2D/muzzle
@onready var shooter_time = $ShooterTime

func _physics_process(delta):
	# La gravedad se aplica siempre
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Movemos al personaje según lo que digan los estados
	move_and_slide()

# Le pasamos el Vector2 que nos calcula el WeaponComponent
# En player.gd, reemplazá actualizar_animacion_apuntado con esto:

# Posiciones del muzzle por dirección (ajustá los valores a tu sprite)
const MUZZLE_POSITIONS = {
	"derecha":          Vector2(26.0,  -26.0),
	"izquierda":        Vector2(-26.0, -26.0),
	"arriba":           Vector2(0.0,   -45.0),
	"abajo":            Vector2(0.0,    5.0),   # <-- este es el que faltaba
	"diagonal_arriba_der": Vector2(22.0, -40.0),
	"diagonal_arriba_izq": Vector2(-22.0, -40.0),
}

func actualizar_animacion_apuntado(dir: Vector2):
	if dir == Vector2.ZERO:
		_animated_sprite.play("Disparo recto")
		return

	if dir.x != 0:
		_animated_sprite.flip_h = dir.x < 0

	if dir.y < 0:
		if dir.x != 0:
			_animated_sprite.play("Disparo diagonal arriba")
			muzzle.position = MUZZLE_POSITIONS["diagonal_arriba_izq" if dir.x < 0 else "diagonal_arriba_der"]
		else:
			_animated_sprite.play("Disparo arriba")
			muzzle.position = MUZZLE_POSITIONS["arriba"]

	elif dir.y > 0:
		if is_on_floor():
			_animated_sprite.play("Crouch")
			# En crouch no dispara, pero igual actualizamos para que no quede mal
			muzzle.position = MUZZLE_POSITIONS["derecha"] # o lo que uses
		else:
			_animated_sprite.play("Disparo abajo")
			muzzle.position = MUZZLE_POSITIONS["abajo"]  # <-- el fix principal

	else:
		_animated_sprite.play("Disparo recto")
		muzzle.position = MUZZLE_POSITIONS["izquierda" if dir.x < 0 else "derecha"]
