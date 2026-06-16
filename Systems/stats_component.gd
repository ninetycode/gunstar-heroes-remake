extends Node
class_name StatsComponent 

signal salud_agotada
signal danio_recibido(cantidad)
signal health_changed(vida_maxima, vida_actual, escudo_actual)
signal salud_recuperada(cantidad)

@export var vida_maxima: int = 100 
var vida_actual: int
var escudo_actual: int = 0

@export var tiempo_invulnerabilidad: float
var es_invulnerable: bool = false

func _ready():
	# Inicializa con valores estándar. 
	# Si un enemigo lo usa, arranca con la vida del inspector.
	vida_actual = vida_maxima
	# Emitimos el estado inicial
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)

func recibir_danio(cantidad):
	if vida_actual <= 0 or es_invulnerable:
		return 
		
	if tiempo_invulnerabilidad > 0.0:
		es_invulnerable = true
		get_tree().create_timer(tiempo_invulnerabilidad).timeout.connect(_apagar_escudo)
	
	var danio_restante = cantidad
	
	if escudo_actual > 0:
		if escudo_actual >= danio_restante:
			escudo_actual -= danio_restante
			danio_restante = 0
		else:
			danio_restante -= escudo_actual
			escudo_actual = 0
	
	vida_actual -= danio_restante
	if vida_actual < 0:
		vida_actual = 0 
		
	danio_recibido.emit(cantidad)
	health_changed.emit(vida_maxima, vida_actual, escudo_actual) 
	
	if vida_actual == 0:
		salud_agotada.emit()

func agregar_escudo(cantidad: int):
	escudo_actual += cantidad
	if escudo_actual > vida_maxima:
		escudo_actual = vida_maxima
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)

func curar(cantidad: int) -> void:
	if vida_actual >= vida_maxima:
		return 
		
	vida_actual += cantidad
	if vida_actual > vida_maxima:
		vida_actual = vida_maxima
		
	salud_recuperada.emit(cantidad)
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)

func _apagar_escudo():
	if is_instance_valid(self):
		es_invulnerable = false
		
func aumentar_vida_maxima(cantidad: int) -> void:
	vida_maxima += cantidad
	vida_actual += cantidad # Le damos esa vida extra al momento de comprar
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)
