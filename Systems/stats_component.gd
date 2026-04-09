extends Node
class_name StatsComponent 

signal salud_agotada
signal danio_recibido(cantidad)
signal health_changed(vida_maxima, vida_actual) # <-- 1. NUEVA SEÑAL
signal salud_recuperada(cantidad)
@export var vida_maxima : int = 100 
var vida_actual : int
@export var tiempo_invulnerabilidad: float# 1 segundo de protección por defecto
var es_invulnerable: bool = false

func _ready():
	vida_actual = vida_maxima
	# 2. Avisamos al HUD cómo arrancamos
	health_changed.emit(vida_maxima, vida_actual) 

func recibir_danio(cantidad):
	# 1. Si ya estamos muertos o tenemos el escudo activo, la bala rebota (se ignora)
	if vida_actual <= 0 or es_invulnerable:
		return 
		
	# 2. Activamos el escudo temporal
	if tiempo_invulnerabilidad > 0.0:
		es_invulnerable = true
		# Programamos que el escudo se apague solo cuando pase el tiempo
		get_tree().create_timer(tiempo_invulnerabilidad).timeout.connect(_apagar_escudo)
		
	# 3. Aplicamos el daño normalmente
	vida_actual -= cantidad
	
	if vida_actual < 0:
		vida_actual = 0 
		
	danio_recibido.emit(cantidad)
	health_changed.emit(vida_maxima, vida_actual) 
	
	if vida_actual == 0:
		salud_agotada.emit()

# Función de seguridad para apagar el escudo
func _apagar_escudo():
	# Verificamos que el nodo siga existiendo (por si el jugador murió y desapareció)
	if is_instance_valid(self):
		es_invulnerable = false
		
func curar(cantidad: int) -> void:
	# Si ya tiene la vida al máximo, no hacemos nada
	if vida_actual >= vida_maxima:
		return 
		
	vida_actual += cantidad
	
	# Clampeamos para no pasarnos de la vida máxima
	if vida_actual > vida_maxima:
		vida_actual = vida_maxima
		
	salud_recuperada.emit(cantidad)
	# Avisamos al HUD para que actualice la barra/números
	health_changed.emit(vida_maxima, vida_actual)
