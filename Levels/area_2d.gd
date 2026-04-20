
var objeto_enfocado: InteractableComponent = null

func _process(_delta):
	# Supongamos que usamos un Area2D que detecta todo lo que entra.
	# Agarramos el primer interactuable de la lista.
	var areas = get_overlapping_areas()
	
	var nuevo_enfoque = null
	if areas.size() > 0 and areas[0] is InteractableComponent:
		nuevo_enfoque = areas[0]
	
	# Si cambiamos de objeto, apagamos el viejo y prendemos el nuevo
	if nuevo_enfoque != objeto_enfocado:
		if objeto_enfocado:
			objeto_enfocado.desenfocar()
		
		objeto_enfocado = nuevo_enfoque
		
		if objeto_enfocado:
			objeto_enfocado.enfocar()

	# Interacción al apretar el botón
	if Input.is_action_just_pressed("interact") and objeto_enfocado:
		objeto_enfocado.interactuar()
