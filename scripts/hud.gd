extends Control

var health_ui
var stamina_ui

func _enter_tree() -> void:
	health_ui = $Background/Health
	stamina_ui = $Background/Stamina

func health_update(current_health):
	health_ui.min_value = current_health

func stamina_update(current_stamina):
	stamina_ui.min_value = current_stamina
