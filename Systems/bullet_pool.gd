extends Node

const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")
var pool_size = 200
var balas_guardadas = []

func _ready():
	# Cuando arranca el juego, fabricamos las balas y las escondemos
	for i in range(pool_size):
		var bala = BULLET_SCENE.instantiate()
		add_child(bala) # Al agregarla, la bala ejecuta su propio _ready() y se apaga sola
		balas_guardadas.append(bala)

# El arma va a llamar a esta función en vez de instanciar
# (El resto del código de bullet_pool.gd queda igual)

func disparar_bala(pos: Vector2, dir: Vector2, data: WeaponResource):
	for bala in balas_guardadas:
		if not bala.visible:
			# Le pasamos el objeto 'data' entero a la bala
			bala.activar(pos, dir, data)
			return
