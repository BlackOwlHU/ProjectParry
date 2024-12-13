extends CharacterBody3D
class_name Player

@export var SPEED = 5.0
@export var player_health = 100
@export var player_stamina = 100
var ready_to_run : bool = true
@export var stamina_max = 100
var stamina_current = player_stamina
var got_hit : bool = false
var parry_on : bool = false
@export var JUMP_VELOCITY = 6
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@onready var player_damage = 50
@onready var timer = $Timer
@onready var hud = $HUD

@onready var anim_player = $AnimationPlayer
@onready var weapon_hitbox = $CameraController/Camera3D/Right_Arm/Weapon/Hitbox
@onready var hitbox_collision = $CameraController/Camera3D/Right_Arm/Weapon/Hitbox/CollisionShape3D

var mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

func _input(event):		
	if event.is_action_pressed("Exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("Attack"):
		if stamina_current < 25:
			return
		if stamina_current >= 25:
			stamina_current -= 25
			timer.start()
		anim_player.play("attack")
		weapon_hitbox.monitoring = true
		hitbox_collision.disabled = false
	
	if Input.is_action_just_pressed("Parry-Block"):
		anim_player.play("parry")
		parry_on = true
		weapon_hitbox.monitoring = true
	
	if Input.is_action_pressed("Pause"):
		if Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		#print(Vector2(_rotation_inout, _tilt_input))

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_player.play("idle")

func _physics_process(delta: float) -> void:
	if player_health <= 0:
		get_tree().reload_current_scene()
	hud.health_update(player_health)
	hud.stamina_update(stamina_current)
	
	if Input.is_action_pressed("Sprint") and stamina_current > 0 and ready_to_run and is_on_floor():
		stamina_current -= 1
		timer.start()
		SPEED = 10
	elif !Input.is_action_pressed("Sprint") and !Input.is_action_just_pressed("ui_accept") and !Input.is_action_just_pressed("Attack") and stamina_current < player_stamina and  timer.is_stopped():
		stamina_current += 0.75
		if stamina_current > player_stamina:
			stamina_current = player_stamina
		if stamina_current == player_stamina:
			ready_to_run = true
	elif stamina_current > 0:
		ready_to_run = true
	elif stamina_current <= 0:
		ready_to_run = false
	if Input.is_action_just_released("Sprint") or stamina_current <= 0:
		SPEED = 5
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and stamina_current >= 10 and !Input.is_action_just_pressed("Sprint"):
		stamina_current -= 10
		timer.start()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_player.play("idle")
		weapon_hitbox.monitoring = false
		hitbox_collision.disabled = true
	if anim_name == "parry":
		parry_on = false
		anim_player.play("idle")
		weapon_hitbox.monitoring = false
		hitbox_collision.disabled = true

func get_damage(damage):
	if parry_on:
		stamina_current += 10
		get_tree().call_group("enemy", "get_stunned", parry_on)
		return
	player_health -= damage
