extends CharacterBody3D
#hours i have spend to fix this: 9
@onready var ai = true
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var SPEED = 3.0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var timer = $Timer

func _ready():
	pass
	#nav_agent.path_changed.connect(func():print("path changed"))
	call_deferred("actor_setup")

func actor_setup():
	await  get_tree().physics_frame
	nav_agent.target_position = player.position

func _physics_process(_delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		return
	look_at(player.global_transform.origin+Vector3(0,1,0))
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()-global_position
	#print(nav_agent.is_target_reachable())
	var new_velocity = (next_location - current_location).normalized() * SPEED
	nav_agent.set_velocity(new_velocity)
	velocity = current_location.direction_to(next_location) * SPEED
	move_and_slide()

func update_target_location(player: Vector3) -> void:
	nav_agent.target_position = player

func _on_timer_timeout() -> void:
	#print("refresh")
	update_target_location(player.position)
	timer.start()

func _on_navigation_agent_3d_target_reached() -> void:
	print("reached")
