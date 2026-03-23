extends Node2D

@export var max_bullets : int = 50
var _pool = []
var _current_index = 0

func initialize_pool(bullet_scene: PackedScene, damage: int):
	for i in range(max_bullets):
		var bullet_instance = bullet_scene.instantiate()
		add_child(bullet_instance)
		
		if bullet_instance.has_node("HitboxComponent"):
			bullet_instance.get_node("HitboxComponent").danio = damage
			
		bullet_instance.global_position = Vector2(-9999, -9999)
		bullet_instance.set_process(false)
		bullet_instance.hide()
		_pool.append(bullet_instance)
		
func disparar_bala(pos: Vector2, dir: Vector2, data: WeaponResource):
	if _pool.is_empty(): 
		print("ERROR: El pool está vacío. ¿Llamaste a initialize_pool()?")
		return
		
	# Agarramos la bala que toca según el índice
	var bala = _pool[_current_index]
	bala.activar(pos, dir, data)
	
	# Avanzamos el índice al siguiente. Si llega al máximo, vuelve a 0.
	_current_index = (_current_index + 1) % _pool.size()
