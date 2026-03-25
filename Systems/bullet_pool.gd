extends Node2D

@export var max_bullets : int = 50
var _pool = []
var _current_index = 0

func initialize_pool(bullet_scene: PackedScene, damage: int):
	for i in range(max_bullets):
		var bullet_instance = bullet_scene.instantiate()
		add_child(bullet_instance)
		_pool.append(bullet_instance)
		bullet_instance.desactivar() # Usamos la función que ya tiene la bala

# CAMBIO: Renombramos a 'get_bullet' y aceptamos el parámetro 'de_enemigo'
func get_bullet(pos: Vector2, dir: Vector2, data: WeaponResource, de_enemigo: bool = false):
	if _pool.is_empty(): 
		print("ERROR: Pool vacío")
		return
		
	var bala = _pool[_current_index]
	# Pasamos el recurso 'arma_laser.tres' y si es de enemigo
	bala.activar(pos, dir, data, de_enemigo)
	
	_current_index = (_current_index + 1) % _pool.size()
