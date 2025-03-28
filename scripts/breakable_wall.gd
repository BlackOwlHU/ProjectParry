extends Area3D

var wall_health = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.owner is Player:
		if wall_health > 0:
			print("wall_health:")
			print(wall_health)
			wall_health -= global.player_damage
			if wall_health <= 0:
				print("wall_breaked")
				$MeshInstance3D.visible = false
				$CollisionShape3D2.set_deferred("disabled", true)
				$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
				$StaticBody3D.collision_layer = 0
				$StaticBody3D.collision_mask = 0
