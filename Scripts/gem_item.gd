extends BaseItem
class_name GemaLore

@export_category("Lore de la Gema")
@export var nombre_gema: String = "Gema del Inframundo"

func aplicar_efecto(_player: Node2D) -> bool:
	print("¡Blue recolectó la gema de lore: ", nombre_gema, "!")
	
	# 1. Cerrojo para el LevelManager
	GameManager.gema_recolectada_en_nivel = true
	
	# 2. Frenamos la música de fondo
	if has_node("/root/AudioManager"):
		AudioManager.stop_music(0.0)
		# Podés meter acá un SFX de victoria si tenés
		AudioManager.play_sfx("ui_accept", 0.0, 1.0) 
	
	# === EL ENLACE QUE FALTABA ===
	# Llamamos textualmente a tu señal de GameEvents para que el HUD se entere
	if has_node("/root/GameEvents"):
		GameEvents.gema_recolectada.emit(nombre_gema)
	
	return true # Se destruye limpiamente del mapa
