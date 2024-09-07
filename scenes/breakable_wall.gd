extends Area3D

var wall_health = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wall_health <= 0:
		print("wall_break")
		$MeshInstance3D.visible = false
		$CollisionShape3D2.disabled = true
		$StaticBody3D/CollisionShape3D.disabled = true

func _on_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	wall_health -= global.player_damage
