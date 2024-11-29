extends Control

var health_ui
var stamina_ui

func _enter_tree() -> void:
	health_ui = $Background/Health
	stamina_ui = $Background/Stamina

func health_update(current_health : int):
	health_ui.value = current_health

func stamina_update(current_stamina : int):
	stamina_ui.value = current_stamina
