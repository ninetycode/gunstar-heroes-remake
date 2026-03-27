extends BossEnemy # <-- ¡Hereda del nuevo molde de jefes!

@onready var hurtbox: HurtboxComponent = $HurtboxComponent

# ¡Y listo! No tenés que poner NADA de la interfaz acá.
# Todo el código de las señales ya lo maneja 'BossEnemy'.

func _ready():
	super() # Es obligatorio llamar a super() para que el molde haga su magia.
	
	# Acá abajo solo pondrías cosas únicas de este jefe de prueba
	# (por ejemplo, iniciar su propia máquina de estados).
