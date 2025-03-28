extends Control

func _on_play_pressed() -> void:
	var loadingScreen = load("res://scenes/loading.tscn")
	get_tree().change_scene_to_packed(loadingScreen)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
