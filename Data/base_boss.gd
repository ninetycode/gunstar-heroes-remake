extends BaseEnemy
class_name BossEnemy # A partir de ahora, este es el molde oficial de los jefes

@export var nombre_boss: String = "Jefe Desconocido"

func _ready():
	super() # Ejecuta el _ready de BaseEnemy (busca al player, conecta señales)
	

func _on_danio_recibido(cantidad: int):
	super(cantidad) # Ejecuta el parpadeo blanco de BaseEnemy
	
	# Actualiza la barra del boss
	GameEvents.boss_health_changed.emit(stats.vida_actual)

func _on_death():
	GameEvents.boss_died.emit()
	super() # Ejecuta el queue_free() de BaseEnemy
