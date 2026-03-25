extends Area2D
class_name HurtboxComponent

@export var stats_component : Node 

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# --- CASO 1: SOS EL PLAYER Y TE PEGAN ---
	if owner.is_in_group("Player"):
		# Si es una BALA enemiga
		if area.is_in_group("enemy_bullet"):
			procesar_danio_y_desactivar_bala(area)
		
		# Si es un ATAQUE MELEE (la patada del enemigo)
		# Suponiendo que el pie/cuerpo del enemigo está en el grupo "enemy_melee"
		elif area.is_in_group("enemy_melee") or area.owner.is_in_group("Enemies"):
			# Si el enemigo te toca con su hitbox de ataque, recibís daño
			var danio_melee = area.get("danio") if "danio" in area else 1
			recibir_golpe(danio_melee)

	# --- CASO 2: SOS UN ENEMIGO Y BLUE TE PEGA ---
	elif owner.is_in_group("Enemies"):
		if area.is_in_group("player_bullet"):
			procesar_danio_y_desactivar_bala(area)
		
		# Por si Blue también tiene un ataque melee (ej. un culatazo)
		elif area.is_in_group("player_melee"):
			var danio_melee = area.get("danio") if "danio" in area else 1
			recibir_golpe(danio_melee)

func procesar_danio_y_desactivar_bala(area: Area2D):
	var d = area.get("danio") if "danio" in area else 1
	recibir_golpe(d)
	
	# Solo desactivamos si es un proyectil, para que no desaparezca el pie del enemigo jajaj
	if area.owner.has_method("desactivar"): 
		area.owner.desactivar()

func recibir_golpe(damage):
	if stats_component != null:
		stats_component.recibir_danio(damage)
