extends Node
class_name StatsComponent 

signal salud_agotada
signal danio_recibido(cantidad)
signal health_changed(vida_maxima, vida_actual, escudo_actual)
signal salud_recuperada(cantidad)
@export var vida_maxima : int = 100 
var vida_actual : int
@export var tiempo_invulnerabilidad: float# 1 segundo de protección por defecto
var es_invulnerable: bool = false
var escudo_actual : int = 0 # El escudo empieza en 0 hasta que agarres uno

func _ready():
	vida_actual = vida_maxima
	# 2. Avisamos al HUD cómo arrancamos
	health_changed.emit(vida_maxima, vida_actual, escudo_actual) 

func recibir_danio(cantidad):
	if vida_actual <= 0 or es_invulnerable:
		return 
		
	if tiempo_invulnerabilidad > 0.0:
		es_invulnerable = true
		get_tree().create_timer(tiempo_invulnerabilidad).timeout.connect(_apagar_escudo)
	
	# --- LÓGICA DE ABSORCIÓN DE ESCUDO ---
	var danio_restante = cantidad
	
	if escudo_actual > 0:
		if escudo_actual >= danio_restante:
			# El escudo absorbe todo
			escudo_actual -= danio_restante
			danio_restante = 0
		else:
			# El escudo se rompe y el resto pasa a la vida
			danio_restante -= escudo_actual
			escudo_actual = 0
	
	# Aplicamos lo que haya sobrado a la vida
	vida_actual -= danio_restante
	
	if vida_actual < 0:
		vida_actual = 0 
		
	danio_recibido.emit(cantidad)
	# Mandamos el escudo actual también a la señal
	health_changed.emit(vida_maxima, vida_actual, escudo_actual) 
	
	if vida_actual == 0:
		salud_agotada.emit()

# --- NUEVA FUNCIÓN PARA SUMAR ESCUDO ---
func agregar_escudo(cantidad: int):
	escudo_actual += cantidad
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)

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
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)
