extends Node

@warning_ignore("unused_signal")
signal boss_fight_started(nombre_boss: String, vida_max: int, vida_actual: int)

@warning_ignore("unused_signal")
signal boss_health_changed(vida_actual: int)

@warning_ignore("unused_signal")
signal boss_died()
