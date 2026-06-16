extends BaseItem

@export var valor_moneda: int = 1

func aplicar_efecto(player: Node2D) -> bool:
	var wallet = player.get_node_or_null("WalletComponent")
	
	if wallet and wallet.has_method("agregar_monedas"):
		wallet.agregar_monedas(valor_moneda)
		
		# [Inferencia] Pongo un sonido genérico, cambialo por tu AudioManager
		# AudioManager.play_sfx("coin_pickup") 
		
		return true # ¡Se consume!
		
	return false
