extends BaseItem

# Podés cambiar esto en el Inspector (ej: una moneda de plata vale 1, una de oro vale 5)
@export var valor_moneda: int = 1

func aplicar_efecto(player: Node2D) -> bool:
	var stats = player.get_node_or_null("StatsComponent")
	
	if stats and stats.has_method("agregar_monedas"):
		stats.agregar_monedas(valor_moneda)
		
		# [Inferencia] Pongo un sonido genérico, cambialo por el tuyo
		#AudioManager.play_sfx("coin_pickup") 
		
		return true # ¡Se consume!
		
	return false
