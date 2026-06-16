extends Node
class_name WalletComponent

signal monedas_cambiadas(total_monedas)

var monedas_actuales: int = 0

func inicializar(cantidad_inicial: int) -> void:
	monedas_actuales = cantidad_inicial
	monedas_cambiadas.emit(monedas_actuales)

func agregar_monedas(cantidad: int) -> void:
	monedas_actuales += cantidad
	monedas_cambiadas.emit(monedas_actuales)


func gastar_monedas(cantidad: int) -> bool:
	if monedas_actuales >= cantidad:
		monedas_actuales -= cantidad
		monedas_cambiadas.emit(monedas_actuales)
		return true
	return false
