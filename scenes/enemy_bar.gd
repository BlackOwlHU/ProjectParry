extends Control

func values(enemy_hp_value, enemy_stamina_value):
	$VBoxContainer/Enemy_Health.max_value = enemy_hp_value
	$VBoxContainer/Enemy_Stamina.max_value = enemy_stamina_value

func enemy_healthbar(enemy_health):
	$VBoxContainer/Enemy_Health.value = enemy_health

func enemy_staminabar(enemy_stamina):
	$VBoxContainer/Enemy_Stamina.value = enemy_stamina
