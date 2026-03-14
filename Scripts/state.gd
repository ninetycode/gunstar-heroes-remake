extends Node
class_name State

#referencia  al maquina de estados que controla a este estado
var state_machine = null 

#se ejecuta una sola vez cuando el jguador ENTRA en este estado
func enter() -> void:
	pass
	
# se ejecuta cuando el jugador SALE
func exit() -> void:
	pass
	
#equivalente al _process
func update(_delta:float) -> void:
	pass

#equivalente al _phhysics_process
func physics_update(_delta: float) -> void:
	pass
