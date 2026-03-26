extends Node

@export var arma_actual: WeaponResource = preload("res://Resources/arma_laser.tres")

@onready var cooldown_timer = $CooldownTimer
@onready var player = owner

# Agregamos un contador para las ráfagas
var balas_disparadas : int = 0

func _ready():
	if arma_actual:
		cooldown_timer.wait_time = arma_actual.fire_rate
		BulletPool.initialize_pool(arma_actual.bullet_scene)

func disparar():
	if cooldown_timer.is_stopped() and arma_actual:
		var direccion = obtener_direccion_apuntado()
		
		# Disparamos normalmente, sea el arma que sea
		BulletPool.get_bullet(
			player.muzzle.global_position, 
			direccion, 
			arma_actual,
			false 
		)
		
		# --- LÓGICA DE RÁFAGAS ---
		if arma_actual.balas_por_rafaga > 0:
			balas_disparadas += 1
			
			if balas_disparadas >= arma_actual.balas_por_rafaga:
				cooldown_timer.wait_time = arma_actual.tiempo_entre_rafagas
				balas_disparadas = 0 
			else:
				cooldown_timer.wait_time = arma_actual.fire_rate
		else:
			cooldown_timer.wait_time = arma_actual.fire_rate
			
		cooldown_timer.start()

func obtener_direccion_apuntado() -> Vector2:
	var v = Input.get_axis("ui_up", "ui_down")
	var h = Input.get_axis("ui_left", "ui_right")
	var dir = Vector2(h, v)
	
	if dir == Vector2.ZERO:
		return Vector2.LEFT if player._animated_sprite.flip_h else Vector2.RIGHT
	return dir.normalized()
	
func cambiar_arma(nuevo_recurso: WeaponResource):
	if nuevo_recurso == null: return
	
	arma_actual = nuevo_recurso
	balas_disparadas = 0 # Reseteamos la ráfaga al cambiar de arma
	cooldown_timer.wait_time = arma_actual.fire_rate
	
	BulletPool.initialize_pool(arma_actual.bullet_scene)
