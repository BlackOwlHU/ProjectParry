extends Node3D

@onready var player = $Player

#func _physics_process(_delta: float) -> void:
	#get_tree().call_group("hud", "health_update", global.player_health)
