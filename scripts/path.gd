extends Node2D

var turrent_pivot = null
var occupied = false

func disable_all_switch_areas():
	for child in get_children():
		if child is Area2D and child.name!='check':
			child.monitoring = false
			child.monitorable=false
			
func enable_all_switch_areas():
	for child in get_children():
		if child is Area2D and child.name!='check':
			child.set_deferred("monitoring", true)
			child.set_deferred("monitorable", true)


func _on_check_area_entered(area):
	occupied = true

func _on_check_area_exited(area):
	occupied = false
