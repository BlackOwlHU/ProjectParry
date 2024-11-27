extends Control

var progress = []
var sceneName
var scene_load_status = 0

func _ready() -> void:
	sceneName = "res://scenes/world.tscn"
	ResourceLoader.load_threaded_request(sceneName)

func _process(delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	$HBoxContainer/Countdown.text = str(floor(progress[0]*100)) + "%"
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)
