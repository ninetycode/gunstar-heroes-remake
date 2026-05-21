extends BaseEnemy
class_name BossEnemy

# Señales para coordinar con la interfaz y la música
signal fase_cambiada(nueva_fase: int)

@export_category("Configuración del Jefe")
@export var nombre_boss: String = "Jefe Desconocido"
@export var usar_fases: bool = false
## A qué porcentaje de vida (0.0 a 1.0) cambia a Fase 2 (Ej: 0.5 es el 50%)
@export_range(0.0, 1.0) var umbral_fase_2: float = 0.5

var fase_actual: int = 1
var esta_en_cooldown_ataque: bool = false

func _ready() -> void:
	super()
	if stats:
		# Nos conectamos al cambio de vida para monitorear las fases
		stats.health_changed.connect(_on_vida_jefe_cambio)

func _on_danio_recibido(cantidad: int) -> void:
	super(cantidad)
	GameEvents.boss_health_changed.emit(stats.vida_actual)

func _on_vida_jefe_cambio(max_vida: int, actual_vida: int, _escudo: int) -> void:
	if not usar_fases or fase_actual == 2: return
	
	# Calculamos el porcentaje actual de salud
	var porcentaje_vida = float(actual_vida) / float(max_vida)
	
	if porcentaje_vida <= umbral_fase_2 and fase_actual == 1:
		_cambiar_a_fase_2()

func _cambiar_a_fase_2() -> void:
	fase_actual = 2
	fase_cambiada.emit(fase_actual)
	print("¡" + nombre_boss + " ha entrado en FASE 2! Más agresivo.")
	# Acá podés activar partículas, cambiar la animación o alterar la música

func _on_death() -> void:
	GameEvents.boss_died.emit()
	super() # Desparece físicamente y suelta loot

# --- LA FUNCIÓN PRO: Orquestador de Poderes ---
## Esta función permite que le pases una lista de nombres de funciones
## y el jefe elija una al azar para intercalar ataques.
func ejecutar_ataque_aleatorio(lista_de_ataques: Array[String]) -> void:
	if esta_en_cooldown_ataque or lista_de_ataques.is_empty(): return
	
	var ataque_elegido = lista_de_ataques.pick_random()
	
	# Usamos metaprogramación de Godot: si el script tiene esa función, la ejecuta
	if has_method(ataque_elegido):
		esta_en_cooldown_ataque = true
		call(ataque_elegido)
