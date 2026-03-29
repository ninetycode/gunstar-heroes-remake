extends CanvasLayer

# Usamos % para acceso rápido a nodos únicos
@onready var health_bar = %HealthBar

func _ready():
	# Primero nos aseguramos de que el HUD esté escondido hasta saber la vida
	health_bar.value = 0
	
	# [Cite: player.gd] Buscamos al jugador en el árbol de escena para conectarnos
	# Asumimos que el jugador está en el grupo "Player"
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		# Buscamos su StatsComponent para conectar la señal
		var stats = player.get_node("StatsComponent")
		if stats:
			# Nos conectamos a la señal de cambio de vida
			stats.health_changed.connect(_on_player_health_changed)
			
			# Inicializamos la barra con los valores actuales
			actualizar_barra(stats.vida_maxima, stats.vida_actual)
		else:
			print("ERROR: El HUD no encontró StatsComponent en el Player")
	else:
		print("ERROR: El HUD no encontró al Player en la escena")

func _on_player_health_changed(vida_max: int, vida_actual: int):
	actualizar_barra(vida_max, vida_actual)

func actualizar_barra(maxima: int, actual: int):
	# Configuramos el tope de la barra dinámicamente
	health_bar.max_value = maxima
	# Seteamos el valor actual
	health_bar.value = actual
