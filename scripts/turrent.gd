extends Node2D

var ghost_path: Node2D = null

var game_state = true #to check game over
var build = true      #to check build mode
var loop_cnt = 1

var current_switch_area = null
var current_path = null
var angle = 0
const ANGLE_MAP = {
	"switch_left": 180,
	"switch_right": 0,
	"switch_up": -90,
	"switch_down": 90
}

@onready var boom = $boom
@onready var main = get_parent()
#turrent_vars
@export var rotation_speed := -1.5
@export var health := 100
signal game_over


func _ready():
	$"..".end_game.connect(_on_game_over)
	$Turrent_pivot/turrent.animation_finished.connect(_on_turrent_animation_finished)
	boom.visible = false
	
	#first path
	ghost_path = preload("res://scenes/path.tscn").instantiate()
	ghost_path.scale = Vector2(1.05,1.05)
	ghost_path.name = 'Path'
	ghost_path.disable_all_switch_areas()
	ghost_path.global_position = Vector2(0,0)
	ghost_path.turrent_pivot = $Turrent_pivot	
	get_tree().current_scene.add_child.call_deferred(ghost_path)
	current_path = ghost_path
	ghost_path = null

func _process(delta):
	if game_state:
		var rotating = Input.is_action_pressed('up') or Input.is_action_pressed('down')
		if rotating:
			if Input.is_action_pressed('up'):
				$Turrent_pivot.rotation += rotation_speed * delta
			elif Input.is_action_pressed('down'):
				$Turrent_pivot.rotation -= rotation_speed * delta
			if not $turrent_screeching.playing:
				$turrent_screeching.play()
		else:
			if $turrent_screeching.playing:
				$turrent_screeching.stop()
		if Input.is_action_just_pressed('shoot'):
			shoot()
		if Input.is_action_just_pressed("build"):
			build_mode()
		if Input.is_action_just_pressed("switch") and current_switch_area:
			var path_node = current_switch_area.get_parent()
			path_node.disable_all_switch_areas()
			# Set turret pivot to this new path's position
			$Turrent_pivot.global_position = path_node.global_position
			$Turrent_pivot.global_rotation = deg_to_rad(angle) # or 180 depending on direction
			$Turrent_pivot.get_parent().rotation_speed *= -1
			current_path.enable_all_switch_areas()
			current_path = path_node
		if build:
			if Input.is_action_just_pressed('path_up'):
				update_ghost_position(0,-207)
			elif Input.is_action_just_pressed('path_down'):
				update_ghost_position(0,207)
			elif Input.is_action_just_pressed('path_left'):
				update_ghost_position(-207,0)
			elif Input.is_action_just_pressed('path_right'):
				update_ghost_position(207,0)
			elif Input.is_action_just_pressed('place'):
				place_path()
		follow_mouse()
	else:
		if Input.is_action_pressed('place'):
			get_tree().reload_current_scene()

func follow_mouse():
	$Turrent_pivot/turrent.look_at(get_global_mouse_position())

func shoot():
	$Turrent_pivot/turrent.play('shoot')
	$turrent_shooting.play()
	const bullet_scene = preload("res://scenes/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	var angle = $Turrent_pivot/turrent.global_rotation
	bullet.rotate = angle
	bullet.global_position = $Turrent_pivot/turrent.global_position + Vector2.RIGHT.rotated(angle) * 40
	get_parent().add_child(bullet)
	bullet.name = 'Bullet'

func _on_turrent_animation_finished():
	if $Turrent_pivot/turrent.animation == "shoot":
		$Turrent_pivot/turrent.play("idle")

func _on_turrent_damage_area_entered(area):
	if 'Bullet' in area.name:
		health -= 10
		$Turrent_pivot/health_bar.value = health
		if health<=0:
			emit_signal('game_over')
		area.queue_free()
	elif area.name.begins_with("switch_"):
		current_switch_area = area
		set_angle(current_switch_area.name)

func set_angle(area_str):
	angle = ANGLE_MAP.get(area_str,90)


func _on_turrent_damage_area_exited(area):
	if area == current_switch_area:
		current_switch_area = null

func _on_game_over():
	boom.global_position= $Turrent_pivot/turrent_area.global_position + Vector2(0,-20)
	boom.visible = true
	boom.play("boom")
	game_state = false

func build_mode():
	if ghost_path != null:
		ghost_path.queue_free()
		ghost_path = null
	elif ghost_path == null:
		ghost_path = preload("res://scenes/path.tscn").instantiate()
		ghost_path.disable_all_switch_areas()
		ghost_path.modulate = Color(1, 1, 1, 0.3)
		ghost_path.scale = Vector2(1.05,1.05)
		get_tree().current_scene.add_child.call_deferred(ghost_path)
		update_ghost_position(207,0)
	build = true

func update_ghost_position(x,y):
	if ghost_path == null:
		return
	ghost_path.global_position = $Turrent_pivot.global_position + Vector2(x,y)

func place_path():
	if build:
		if ghost_path and !ghost_path.occupied and main.score>=200:
			main.on_score_spent()
			ghost_path.turrent_pivot = $Turrent_pivot
			ghost_path.modulate = Color(1,1,1,1)
			ghost_path.name = 'Path'
			ghost_path.enable_all_switch_areas()
			ghost_path = null
			loop_cnt+=1
			build = false
		elif ghost_path.occupied:
			main.warning.text = "You can't place that there mate!"
			main.warning.visible = true
			$"../Warning_Timer".start()
			ghost_path.queue_free()
			ghost_path = null
		else:
			main.warning.text = 'Not enough score'
			main.warning.visible = true
			$"../Warning_Timer".start()
			ghost_path.queue_free()
			ghost_path = null
