extends Control

var _scene = null


func load_scene():
	_scene = load("res://scenes/showroom.tscn")


func change_scene():
	get_tree().change_scene_to_packed(_scene)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "load_scene":
		$CenterContainer/AnimationPlayer.play("change_scene")
