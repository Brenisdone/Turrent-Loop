extends Camera2D

@onready var turret = $"../Turrent_body/Turrent_pivot/turrent"

func _process(delta):
	global_position = turret.global_position
