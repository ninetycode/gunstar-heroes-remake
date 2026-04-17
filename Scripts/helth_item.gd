extends BaseItem

@export var heal_amount: int = 20

func aplicar_efecto(player: Node2D) -> bool:
	var stats = player.get_node_or_null("StatsComponent")
	
	# Solo lo curamos (y consumimos el ítem) si no tiene la vida al máximo
	if stats and stats.vida_actual < stats.vida_maxima:
		stats.curar(heal_amount)
		AudioManager.play_sfx("curacion", -1.0)
		return true # Consumido!
		
	return false # No lo consume, se queda flotando
