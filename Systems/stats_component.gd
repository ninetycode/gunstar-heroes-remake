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
signal monedas_cambiadas(total_monedas)
var monedas_actuales : int = 0

@export_category("Debug y Pruebas")
@export var monedas_de_prueba: int = 0 

func _ready():
	# 1. VIDA MÁXIMA REAL BASE (100 + Mejoras)
	vida_maxima = 100 + (GameManager.nivel_mejora_vida * 10)
	
	# 2. CARGAR MONEDAS
	monedas_actuales = GameManager.monedas_totales

	# 3. ESTABLECER VIDA Y ESCUDO AL ARRANCAR
	if GameManager.vida_persistente != -1:
		vida_actual = GameManager.vida_persistente
		escudo_actual = GameManager.escudo_persistente
	else:
		# Partida fresca (Cuando morís y volvés al lobby)
		vida_actual = vida_maxima
		escudo_actual = GameManager.nivel_mejora_escudo * 20

	# Límite de seguridad para el escudo
	if escudo_actual > vida_maxima:
		escudo_actual = vida_maxima

	# 4. TRUCO DE PRUEBAS
	if monedas_de_prueba > 0:
		monedas_actuales += monedas_de_prueba
		GameManager.monedas_totales = monedas_actuales
		monedas_de_prueba = 0

	# 5. AVISAR AL HUD
	health_changed.emit(vida_maxima, vida_actual, escudo_actual)
	monedas_cambiadas.emit(monedas_actuales)

	# 6. CONSOLA DE DIAGNÓSTICO
	print("\n========================================")
	print("=== INICIO DE NIVEL (Stats de Blue) ===")
	print("Vida: ", vida_actual, " / ", vida_maxima)
	print("Escudo Inicial: ", escudo_actual)
	print("Monedas en Bolsillo: ", monedas_actuales)
	print("========================================\n")

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
	# Limitamos el escudo a la vida máxima
	if escudo_actual > vida_maxima:
		escudo_actual = vida_maxima
		
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
	
func agregar_monedas(cantidad: int):
	monedas_actuales += cantidad
	# --- NUEVO: Sincronizamos con el Banco inmediatamente ---
	GameManager.monedas_totales = monedas_actuales 
	# Emitimos la señal local para la animación
	monedas_cambiadas.emit(monedas_actuales)
	# Emitimos la señal global para que el nuevo HUD se entere
	GameManager.monedas_globales_actualizadas.emit(monedas_actuales)
