extends BaseItem
class_name GemaLore

@export_category("Lore de la Gema")
## El nombre de la gema por si querés printearlo o mandarlo al HUD
@export var nombre_gema: String = "Gema del Inframundo"

func aplicar_efecto(_player: Node2D) -> bool:
	# [Inferencia] Mandamos un aviso a la consola para debuguear que funcione
	print("¡Blue recolectó la gema de lore: ", nombre_gema, "!")
	
	# === LÓGICA DE EVENTOS (Feedback Visual/Lore) ===
	# Podés usar tus señales globales para avisarle al HUD que muestre un cartelito,
	# o simplemente reproducir un sonido de éxito.
	AudioManager.play_sfx("ui_accept", 0.0, 1.2)
	
	# SI QUERÉS GUARDAR EL HECHO DE QUE TENES LA GEMA EN EL GAMEMANAGER:
	# GameManager.gema_lore_recolectada = true
	
	# CRÍTICO: Devolvemos 'true' para avisarle al script base que la gema 
	# fue agarrada correctamente y que se puede destruir del mapa.
	return true
