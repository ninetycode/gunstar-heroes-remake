extends Area2D

var objetivo_actual: InteractableComponent = null

func _process(_delta):
	# Obtenemos todas las áreas interactivas cerca de Blue
	var areas = get_overlapping_areas()
	
	var area_mas_cercana: InteractableComponent = null
	
	if areas.size() > 0:
		# De todas las áreas, agarramos la primera (o la más cercana)
		area_mas_cercana = areas[0] as InteractableComponent

	# Si el objetivo cambió (nos alejamos o nos acercamos a otro)
	if area_mas_cercana != objetivo_actual:
		if objetivo_actual:
			objetivo_actual.desenfocar() # Apaga el borde anterior
		
		objetivo_actual = area_mas_cercana
		
		if objetivo_actual:
			objetivo_actual.enfocar() # Prende el borde nuevo

	# Si apretamos el botón de interactuar (ej: "E" o "U")
	if Input.is_action_just_pressed("interact") and objetivo_actual:
		objetivo_actual.interactuar()
