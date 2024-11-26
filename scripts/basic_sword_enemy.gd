extends CharacterBody3D
#hours i have spend to fix this: 11
@onready var ai = true
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var SPEED = 4.0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var timer = $Timer
@onready var pos = $Position

var enemy_health = 100

func _ready():
	pass
	#nav_agent.path_changed.connect(func():print("path changed"))
	call_deferred("actor_setup")

func actor_setup():
	await  get_tree().physics_frame
	nav_agent.target_position = player.position

func _physics_process(_delta: float) -> void:
	if ai:
		if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
			return
		if nav_agent.is_navigation_finished():
			return
		look_at(player.global_transform.origin+Vector3(0,1,0))
		var current_location = pos.global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		next_location.y=current_location.y
		#print(nav_agent.is_target_reachable())
		var new_velocity =  (current_location.direction_to(next_location)) * SPEED
		nav_agent.set_velocity(new_velocity)
		velocity = nav_agent.velocity
		move_and_slide()

func update_target_location():
	nav_agent.target_position = player.position
	#print(nav_agent.target_position)

func _on_timer_timeout() -> void:
	#print("refresh")
	if ai:
		update_target_location()
	timer.start()

func _on_navigation_agent_3d_target_reached() -> void:
	print("reached")


func _on_area_3d_area_entered(area: Area3D) -> void:
	if enemy_health > 0:
		print("enemy_health:")
		print(enemy_health)
	if area.owner is Player:
		enemy_health -= global.player_damage
		if enemy_health <= 0:
			ai = false
			print("enemy_killed")
			$MeshInstance3D.visible = false
			$Right_Arm/MeshInstance3D/Area3D/CollisionShape3D2.disabled = true
			$CollisionShape3D.disabled = true
			$MeshInstance3D/Area3D/DamageRegister.disabled = true
			#$StaticBody3D.collision_layer = 0
			#$StaticBody3D.collision_mask = 0
