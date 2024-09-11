extends Control

@onready var ResOptionButton = $Resolution/HBoxContainer/OptionButton

var Resolution: Dictionary = {"800x600":Vector2(800,600),
								"1280x720":Vector2(1280,720),
								"1920x1080":Vector2(1920,1080)}

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _ready():
	AddResolution()
	ResOptionButton.selected = 1

func AddResolution():
	for i in Resolution:
		ResOptionButton.add_item(i)


func _on_option_button_item_selected(index: int) -> void:
	var size = Resolution.get(ResOptionButton.get_item_text(index))
	get_window().set_size(size)
