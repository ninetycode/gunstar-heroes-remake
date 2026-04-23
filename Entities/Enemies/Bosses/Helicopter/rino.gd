extends BossEnemy # <-- ¡Hereda del nuevo molde de jefes!

@onready var hurtbox: HurtboxComponent = $HurtboxComponent

func _ready():
	super()
