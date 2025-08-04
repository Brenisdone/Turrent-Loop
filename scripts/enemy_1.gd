extends Node2D

const SPEED = 200
@export var health := 100
var turrent = null
var world = null
var move= true

signal died(points)

func _ready():
	$enemy_sprite.animation_finished.connect(_on_enemy_animation_finished)

func _process(delta):
	if turrent!=null:
		rotation = (turrent.global_position - global_position).angle()
		if move:
			var direction = (turrent.global_position - global_position).normalized()
			position += direction * SPEED * delta

func _on_enemy_1_area_entered(area):
	if 'Bullet' in area.name:
		health-= 50
		area.queue_free()
		$health_bar.value = health
		if health <= 0:
			emit_signal('died',50)
			queue_free()

func _on_move_area_area_entered(area):
	if area.name == 'turrent_area':
		move = false

func _on_move_area_area_exited(area):
	if area.name == 'Camera_area':
		move = true

func _on_enemy_animation_finished():
	if $enemy_sprite.animation == 'shoot':
		$enemy_sprite.play("idle")

func shoot():
	const bullet_scene = preload("res://scenes/bullet_enemy.tscn")
	var bullet = bullet_scene.instantiate()
	var angle = global_rotation
	bullet.rotate = angle
	bullet.global_position = global_position + Vector2.RIGHT.rotated(angle) * 15
	get_parent().add_child(bullet)
	bullet.name = 'Bullet'
	$enemy_sprite.play("shoot")
	$enemy_shoot.play()


func _on_shoot_timer_timeout():
	if move == false:
		shoot()
