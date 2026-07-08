extends Node

var tiempo_jugado: float = 0.0
var veces_guardado: int = 0
var slot_actual: int = 1 # Para saber en qué archivo estamos jugando
var nivel_maximo_alcanzado: int = 0

func _process(delta: float) -> void:
	# El reloj avanza siempre que el juego no esté pausado
	tiempo_jugado += delta

# Transforma los segundos (ej: 3665) en "01:01:05"
func obtener_tiempo_formateado() -> String:
	# Usamos división con decimales y fmod (resto de decimales), y al final lo convertimos a entero
	var horas = int(tiempo_jugado / 3600.0)
	var minutos = int(fmod(tiempo_jugado, 3600.0) / 60.0)
	var segundos = int(fmod(tiempo_jugado, 60.0))
	return "%02d:%02d:%02d" % [horas, minutos, segundos]

# --- LÓGICA DE DISCO RÍGIDO ---

func guardar_partida(slot: int):
	veces_guardado += 1
	var config = ConfigFile.new()
	
	# 1. Guardamos la Meta-Data (Para mostrar en el menú)
	var fecha_actual = Time.get_datetime_string_from_system(false, true).replace("T", " ")
	config.set_value("Meta", "fecha", fecha_actual)
	config.set_value("Meta", "tiempo_jugado", tiempo_jugado)
	config.set_value("Meta", "tiempo_formateado", obtener_tiempo_formateado())
	config.set_value("Meta", "veces_guardado", veces_guardado)
	config.set_value("Progreso", "objetos_fijos", GameManager.objetos_fijos_agarrados)
	# 2. Guardamos los Datos del Juego (Desde el GameManager)
	config.set_value("Stats", "monedas", GameManager.monedas_totales)
	config.set_value("Stats", "mejora_vida", GameManager.nivel_mejora_vida)
	config.set_value("Stats", "mejora_escudo", GameManager.nivel_mejora_escudo)
	
	# === FIX DE PROGRESIÓN AAA ===
	# Le decimos al archivo que salve el nivel máximo que desbloqueó Blue
	config.set_value("Progreso", "nivel_maximo", GameManager.nivel_maximo_alcanzado)
	
	# 3. Guardamos el archivo en la carpeta "AppData" del usuario
	config.save("user://save_slot_" + str(slot) + ".cfg")
	print("Partida guardada en el slot ", slot, " (Nivel Máx: ", GameManager.nivel_maximo_alcanzado, ")")

func cargar_partida(slot: int) -> bool:
	var config = ConfigFile.new()
	if config.load("user://save_slot_" + str(slot) + ".cfg") == OK:
		# Recuperamos los datos de meta y stats base
		tiempo_jugado = config.get_value("Meta", "tiempo_jugado", 0.0)
		veces_guardado = config.get_value("Meta", "veces_guardado", 0)
		
		GameManager.monedas_totales = config.get_value("Stats", "monedas", 0)
		GameManager.nivel_mejora_vida = config.get_value("Stats", "mejora_vida", 0)
		GameManager.nivel_mejora_escudo = config.get_value("Stats", "mejora_escudo", 0)
		
		# === FIX DE LA CLAVE CORREGIDA ===
		# Cambiamos "objects_fijos" por "objetos_fijos" para que coincida exactamente con el guardado
		GameManager.objetos_fijos_agarrados = config.get_value("Progreso", "objetos_fijos", {})
		
		# === FIX DE CARGA AAA ===
		GameManager.nivel_maximo_alcanzado = config.get_value("Progreso", "nivel_maximo", 0)
		
		slot_actual = slot
		return true
	return false

# Esta función es la que usa el menú para saber qué escribir en los botones
func obtener_info_slot(slot: int) -> Dictionary:
	var config = ConfigFile.new()
	# Intentamos abrir el archivo
	if config.load("user://save_slot_" + str(slot) + ".cfg") == OK:
		return {
			"vacio": false,
			"fecha": config.get_value("Meta", "fecha", "Desconocida"),
			"tiempo": config.get_value("Meta", "tiempo_formateado", "00:00:00"),
			"veces": config.get_value("Meta", "veces_guardado", 0)
		}
	else:
		return {"vacio": true}
		
func borrar_partida(slot: int):
	# Buscamos la ruta exacta del archivo
	var ruta = "user://save_slot_" + str(slot) + ".cfg"
	
	# Si el archivo existe, abrimos el directorio y lo fulminamos
	if FileAccess.file_exists(ruta):
		var dir = DirAccess.open("user://")
		dir.remove("save_slot_" + str(slot) + ".cfg")
		print("Partida en slot ", slot, " eliminada con éxito.")
