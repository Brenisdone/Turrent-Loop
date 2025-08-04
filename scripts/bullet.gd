extends Area2D

@export var SPEED = 450

var rotate = 0 #gets degrees

func _physics_process(delta):
	position += SPEED * Vector2(cos(rotate),sin(rotate)) * delta
