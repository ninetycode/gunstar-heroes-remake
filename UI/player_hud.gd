extends CanvasLayer

# Usamos % para acceso rápido a nodos únicos
@onready var health_bar = %HealthBar
@onready var weapon_icons: HBoxContainer = %WeaponIcons

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
		var weapon_comp = player.get_node("WeaponComponent")
		if weapon_comp:
			weapon_comp.inventario_cambiado.connect(_on_inventario_cambiado)
			# Sincronización inicial por si el HUD cargó un milisegundo tarde
			_on_inventario_cambiado(weapon_comp.inventario_armas, weapon_comp.indice_arma_actual)
		
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

func _on_inventario_cambiado(lista_armas: Array[WeaponResource], indice_activo: int):
	# 1. Borramos los iconos anteriores para no duplicarlos
	for hijo in weapon_icons.get_children():
		hijo.queue_free()
		
	# 2. Creamos los iconos nuevos
	for i in range(lista_armas.size()):
		var recurso = lista_armas[i]
		if recurso == null or recurso.icono_arma == null:
			continue # Si hay un hueco vacío o sin imagen, lo saltamos
			
		var rect = TextureRect.new()
		rect.texture = recurso.icono_arma
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# 3. LA MAGIA DEL COLOR: Brillante si está activo, oscuro si no
		if i == indice_activo:
			rect.modulate = Color(1.2, 1.2, 1.2, 1.0) # Un toque más blanco/brillante
		else:
			rect.modulate = Color(0.3, 0.3, 0.3, 0.8) # Gris oscuro y penitas transparente
			
		# Lo agregamos al contenedor de la pantalla
		weapon_icons.add_child(rect)
