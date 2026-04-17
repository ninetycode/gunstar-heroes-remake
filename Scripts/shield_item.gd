extends BaseItem

@export var shield_amount: int = 50

func aplicar_efecto(player: Node2D) -> bool:
	var stats = player.get_node_or_null("StatsComponent")
	if stats:
		stats.agregar_escudo(shield_amount)
		AudioManager.play_sfx("curacion") # Cambiá esto luego por el sonido metálico
		return true # Consumido!
		
	return false
