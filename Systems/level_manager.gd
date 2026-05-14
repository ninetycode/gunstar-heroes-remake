extends Node

var habitacion_actual: int = 0
var ruta_generada: Array[String] = []

@export_category("Mazo de Habitaciones")
@export var pool_habitaciones: Array[String] # Acá arrastrás las 3+ escenas de Facu
@export var jefe_medio: String             # La ruta a la escena del primer jefe
@export var jefe_final: String             # La ruta a la escena del jefe final

func iniciar_nivel():
	habitacion_actual = 0
	ruta_generada.clear()
	
	# 1. Armamos el mazo temporal y lo mezclamos
	var temp_pool = pool_habitaciones.duplicate()
	temp_pool.shuffle()
	
	# 2. Elegimos las 4 primeras (si Facu hizo solo 3, el "%" hace que repita alguna sin crashear)
	for i in range(4):
		ruta_generada.append(temp_pool[i % temp_pool.size()])
		
	# 3. Ponemos la Sala 5: Jefe Medio
	ruta_generada.append(jefe_medio)
	
	# 4. Volvemos a mezclar y elegimos 4 más para la segunda mitad
	temp_pool.shuffle()
	for i in range(4):
		ruta_generada.append(temp_pool[i % temp_pool.size()])
		
	# 5. Ponemos la Sala 10: Jefe Final
	ruta_generada.append(jefe_final)
	
	# 6. ¡Arrancamos el viaje!
	print("Nivel generado: ", ruta_generada)
	avanzar_habitacion()

func avanzar_habitacion():
	if habitacion_actual < ruta_generada.size():
		var siguiente_escena = ruta_generada[habitacion_actual]
		habitacion_actual += 1
		# Usamos tu súper pantalla de carga
		TransitionManager.viajar_a(siguiente_escena)
	else:
		# Si ya no quedan escenas, ganamos el nivel
		print("¡NIVEL COMPLETADO!")
		TransitionManager.viajar_a("res://Levels/Lobby.tscn")
