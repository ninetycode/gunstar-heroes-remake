extends BaseEnemy
class_name BossEnemy

@onready var hurtbox: HurtboxComponent = $HurtboxComponent

@export var nombre_boss: String = "Boss Prueba"

func _ready():
	super() 
	
	# Usamos call_deferred para que espere al final del frame para avisar
	GameEvents.boss_fight_started.emit.call_deferred(nombre_boss, stats.vida_maxima, stats.vida_actual)

func _on_danio_recibido(cantidad: int):
	super(cantidad) # Mantenemos el parpadeo blanco
	
	# Avisamos a la UI cuánta vida nos queda
	GameEvents.boss_health_changed.emit(stats.vida_actual)

func _on_death():
	GameEvents.boss_died.emit() # Avisamos que ganaste
	super() # Nos destruimos
