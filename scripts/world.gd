extends Node2D
var game_state = true
var score = 0
var level = 0
var time = 0 #overall_time
var spawn_time = 5

@onready var game_over = $Camera2D/Game_over_canvas/Game_Over
@onready var warning = $Camera2D/Game_over_canvas/warning
@onready var score_disp = $Camera2D/Game_over_canvas/score
@onready var level_disp = $Camera2D/Game_over_canvas/level
@onready var bg_disp = $Camera2D/Game_over_canvas/bg

signal end_game

func _ready():
	$Turrent_body.game_over.connect(_on_game_over)
	game_over.visible = false
	warning.visible = false
	bg_disp.visible = false
	

func get_spawn_point():
	var offset_x = (-1 if randi_range(0, 1) == 0 else 1)* (640 + randi_range(0, 100))
	var offset_y = (-1 if randi_range(0, 1) == 0 else 1) * (360 + randi_range(0, 100))
	var spawn_point = $Camera2D.global_position + Vector2(offset_x, offset_y)
	return spawn_point


func _on_spawn_timer_timeout():
	time+=$Spawn_Timer.wait_time
	var spawn_point = get_spawn_point()
	var enemy = preload("res://scenes/enemy_1.tscn").instantiate()
	add_child(enemy)
	enemy.position = spawn_point
	enemy.turrent = $Turrent_body/Turrent_pivot/turrent
	enemy.died.connect(_on_enemy_died)

func _on_camera_area_area_exited(area):
	if 'Bullet' in area.name:
		area.queue_free()
		
func _on_enemy_died(points):
	score+=points
	score_disp.text = str(score)
	check_score()

func check_score():
	if score%200==0 and spawn_time>0.5:
		spawn_time -= 0.5
		level+=1
		level_disp.text=str(level)
		$Spawn_Timer.wait_time = spawn_time
		
func on_score_spent():
	score-=200
	score_disp.text = str(score)

func _on_game_over():
	if game_state:
		$Game_over_Timer.start()
		game_state = false
		emit_signal('end_game')
		$Spawn_Timer.paused = true
		var mins = time/60
		var secs = int(time)%60
		var text = "GAME OVER!\n\nYour score: %d\nTime survived: %02d:%02d\nLoops: %d\n\npress ENTER to restart" %[score,mins,secs,$Turrent_body.loop_cnt]
		game_over.text = text


func _on_warning_timer_timeout():
	warning.visible = false

func _on_game_over_timer_timeout():
	bg_disp.visible = true
	game_over.visible = true
