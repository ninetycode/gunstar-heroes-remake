extends CanvasLayer

# Usamos % para acceso rápido a nodos únicos
@onready var health_bar = %HealthBar
@onready var weapon_icons: HBoxContainer = %WeaponIcons
var tween_go: Tween # Para controlar el parpadeo del cartel
var tween_retrato: Tween

func _ready():
	# Primero nos aseguramos de que el HUD esté escondido/vacío hasta saber la vida
	health_bar.value = 0
	
	# Vaciamos la barra de escudo por defecto
	if %ShieldBar:
		%ShieldBar.value = 0
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		var stats = player.get_node("StatsComponent")

		if stats:
			stats.health_changed.connect(_on_player_health_changed)
			stats.danio_recibido.connect(_on_player_danio_recibido) 
			stats.salud_agotada.connect(_on_player_salud_agotada)
			stats.salud_recuperada.connect(_on_player_salud_recuperada)
			
			# Inicializamos la barra de VIDA con los valores actuales
			actualizar_barra(stats.vida_maxima, stats.vida_actual)
			
			# --- NUEVO: Inicializamos la barra de ESCUDO con los valores actuales ---
			if %ShieldBar:
				%ShieldBar.max_value = stats.vida_maxima
				%ShieldBar.value = stats.escudo_actual
		var weapon_comp = player.get_node("WeaponComponent")
		if weapon_comp:
			weapon_comp.inventario_cambiado.connect(_on_inventario_cambiado)
			# Sincronización inicial por si el HUD cargó un milisegundo tarde
			_on_inventario_cambiado(weapon_comp.inventario_armas, weapon_comp.indice_arma_actual)
		
		else:
			print("ERROR: El HUD no encontró StatsComponent en el Player")
	else:
		print("ERROR: El HUD no encontró al Player en la escena")

# En player_hud.gd
func _on_player_health_changed(vida_max: int, vida_actual: int, escudo_actual: int):
	# La barra roja normal
	health_bar.max_value = vida_max
	health_bar.value = vida_actual
	
	# La barra de escudo (gris)
	# Como el escudo puede superar la vida, podés hacer que la ShieldBar 
	# sea más larga o simplemente mostrar el número.
	if %ShieldBar:
		%ShieldBar.max_value = vida_max # O un tope arbitrario
		%ShieldBar.value = escudo_actual
		#%ShieldLabel.text = str(escudo_actual) # Para ver el número exacto

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
		
		
func _on_player_danio_recibido(_cantidad: int):
	var retrato = get_node_or_null("MarginContainer/HBoxContainer/portrait_container/BluePortrait")
	
	if retrato:
		# Si hay una animación de color ejecutándose, la cancelamos
		if tween_retrato and tween_retrato.is_valid():
			tween_retrato.kill()
			
		retrato.modulate = Color.RED
		
		# Guardamos el nuevo tween en nuestra variable
		tween_retrato = create_tween()
		tween_retrato.tween_property(retrato, "modulate", Color.WHITE, 0.3)
	else:
		print("HUD: No se encontró la imagen BluePortrait en la ruta especificada.")

# --- NUEVA FUNCIÓN DE MUERTE ---
func _on_player_salud_agotada():
	# 1. Buscamos el contenedor animado (el marco) y la foto
	var animacion_marco = get_node_or_null("MarginContainer/HBoxContainer/portrait_container")
	var retrato = get_node_or_null("MarginContainer/HBoxContainer/portrait_container/BluePortrait")
	
	# 2. Detenemos la animación del marco
	if animacion_marco and animacion_marco is AnimatedSprite2D:
		animacion_marco.stop() 
		
	# 3. Teñimos la foto de gris oscuro y matamos cualquier destello rojo
	if retrato:
		if tween_retrato and tween_retrato.is_valid():
			tween_retrato.kill()
		
		# Color gris apagado (RGB: 0.3, 0.3, 0.3)
		retrato.modulate = Color(0.296, 0.288, 0.309, 1.0)
		
func _on_player_salud_recuperada(_cantidad: int):
	var retrato = get_node_or_null("MarginContainer/HBoxContainer/portrait_container/BluePortrait")
	
	if retrato:
		# Si hay una animación de color ejecutándose (ej: justo lo atacaron), la cancelamos
		if tween_retrato and tween_retrato.is_valid():
			tween_retrato.kill()
			
		# Teñimos de verde puro (podés usar Color.GREEN o Color(0.2, 1.0, 0.2) si querés un verde más suave)
		retrato.modulate = Color.GREEN
		
		# Animamos la vuelta al blanco normal igual que con el daño
		tween_retrato = create_tween()
		tween_retrato.tween_property(retrato, "modulate", Color.WHITE, 0.3)
	else:
		print("HUD: No se encontró la imagen BluePortrait para la curación.")
		
		
func mostrar_cartel_go(mostrar: bool):
	var cartel = get_node_or_null("GoSign")
	var sonido = get_node_or_null("GoSound")
	
	# Si ya había un parpadeo funcionando, lo matamos para que no se amontonen
	if tween_go and tween_go.is_valid():
		tween_go.kill()
	
	if cartel:
		cartel.visible = mostrar
		
		if mostrar:
			# Creamos el metrónomo visual
			tween_go = create_tween().set_loops()
			
			# 1. Se desvanece (0.5 segundos)
			tween_go.tween_property(cartel, "modulate:a", 0.2, 0.5)
			
			# 2. Aparece (0.5 segundos)
			tween_go.tween_property(cartel, "modulate:a", 1.0, 0.5)
			
			# 3. ¡MOMENTO CLAVE!: Justo cuando termina de aparecer, tiramos el sonido
			tween_go.tween_callback(func(): 
				if sonido: 
					sonido.play()
			)
		else:
			# Si lo apagamos, lo dejamos opaco y frenamos el sonido
			cartel.modulate.a = 1.0
			if sonido and sonido.playing:
				sonido.stop()
