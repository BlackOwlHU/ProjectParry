extends CharacterBody3D

@onready var ai = true
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 3.0
@onready var player = get_tree().get_first_node_in_group("Player")

func update():
	var i = 1
	while i > 0:
		update_target_location() 

func _physics_process(delta: float) -> void:
	look_at(player.position)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()-global_position
	next_location.normalized()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	velocity = velocity.move_toward(new_velocity, .25)
	move_and_slide()

func update_target_location() -> void :
	nav_agent.target_position = player.global_transform.origin
