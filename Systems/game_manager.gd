extends Node

signal monedas_globales_actualizadas(cantidad)
signal pausa_estado_cambiado(esta_pausado: bool)

# === SOLUCIÓN FIX CÍCLICO AAA ===
# Eliminamos por completo el preload y la variable local. 
# El GameManager ya no necesita conocer físicamente a la escena de pausa.

var indice_arma_persistente: int = 0
var doble_salto_desbloqueado: bool = false

var monedas_totales: int = 0
var vida_persistente: int = -1 # -1 significa "llena" (primera vez)
var escudo_persistente: int = 0
var plata_prueba_entregada: bool = false

# --- REGISTRO DE OBJETOS FIJOS COLECTADOS ---
var objetos_fijos_agarrados: Dictionary = {}
var gema_recolectada_en_nivel: bool = false
#--------------------------------------------------
## MEJORAS: 
var nivel_mejora_vida: int = 0
var nivel_mejora_escudo: int = 0
#--------------------------------------------------
var nivel_maximo_alcanzado: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Limpiamos las líneas que instanciaban el menú a mano para que no dupliquen al Autoload

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	pausa_estado_cambiado.emit(get_tree().paused)

func restart_current_level() -> void:
	get_tree().paused = false
	
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(0.0)
	
	if get_tree().current_scene != null:
		get_tree().call_deferred("reload_current_scene")
	else:
		var root = get_tree().root
		var escena_actual = root.get_child(root.get_child_count() - 1)
		get_tree().call_deferred("change_scene_to_file", escena_actual.scene_file_path)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		# === BLINDAJE ANTI-PAUSA SEGURO ===
		# Le preguntamos al motor si Blue está vivo en la escena actual.
		# Si no hay nadie en el grupo "Player", significa que estás en el Main Menu o Créditos,
		# por lo que cortamos en seco con un return y el botón no hace nada.
		if not get_tree().get_first_node_in_group("Player"):
			return
			
		toggle_pause()
			
func guardar_estado_jugador(vida: int, escudo: int, monedas: int):
	vida_persistente = vida
	escudo_persistente = escudo
	monedas_totales = monedas
	monedas_globales_actualizadas.emit(monedas_totales)
	print("GameManager: Estado guardado. Monedas: ", monedas_totales)
	
func resetear_stats_rogue():
	vida_persistente = -1
	escudo_persistente = 0
	monedas_totales = 0
	indice_arma_persistente = 0
