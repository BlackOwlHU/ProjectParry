extends CharacterBody3D
#hours i have spend to fix this: 11
@export var Enemy_Damage = 10
var ai = true
var is_attack_on : bool = false
var dead : bool = false
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var SPEED = 4.0
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var timer = $Timer
@onready var pos = $Position
@onready var BodyCollison = $BodyCollison
@onready var DamageRegister = $Area3D/DamageRegister
@onready var SwordCollison = $Scaler/hand_right/Sword/SwordArea/SwordCollison
@onready var EnemyBody = $EnemyBody
@onready var Sword = $Scaler/hand_right/Sword
@onready var Hitbox = $Area3D
@onready var anim_player = $AnimationPlayer
@onready var AttackRange = $AttackRange
@onready var BetweenAttacks = $BetweenAttacks
@onready var enemy_bar = $SubViewport/Enemy_Bar

var is_enemy_in_range : bool = false
@export var enemy_health = 100
@export var enemy_stamina = 100

func _ready():
	enemy_bar.values(enemy_health, enemy_stamina)
	anim_player.play("Enemy Movements/Idle_test")
	_on_timer_timeout()
	#nav_agent.path_changed.connect(func():print("path changed"))
	#call_deferred("actor_setup")
#
#func actor_setup():
	#await  get_tree().physics_frame
	#nav_agent.target_position = player.position

func _physics_process(_delta: float) -> void:
	if dead:
		is_dead()
		return
	if dead == false:
		$Sprite3D.look_at(player.position)
		enemy_bar.enemy_healthbar(enemy_health)
		enemy_bar.enemy_staminabar(enemy_stamina)
	if ai and dead == false:
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

func update_target_location():
	nav_agent.target_position = player.position
	#print(nav_agent.target_position)

func _on_timer_timeout() -> void:
	#print("refresh")
	if ai and dead == false:
		timer.wait_time = 0.1
		update_target_location()
		timer.autostart = true
		timer.start()

func _on_navigation_agent_3d_target_reached() -> void:
	print("reached")

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.owner is Player:
		if enemy_health > 0:
			print("enemy_health:")
			print(enemy_health)
		enemy_health -= global.player_damage
		if enemy_health <= 0:
			dead = true
			ai = false
			print("enemy_killed")
			Sword.visible = false
			BodyCollison.set_deferred("disabled", true)
			DamageRegister.set_deferred("disabled", true)
			SwordCollison.set_deferred("disabled", true)
			Hitbox.set_deferred("monitoring", false)
			#$StaticBody3D.collision_layer = 0
			#$StaticBody3D.collision_mask = 0


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_enemy_in_range = true

func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_enemy_in_range = false

func _on_between_attacks_timeout() -> void:
	$Scaler/hand_right/Sword/SwordArea.set_deferred("monitorable", true)
	SwordCollison.set_deferred("disabled", false)
	if is_enemy_in_range and ai and dead == false:
		anim_player.play("Enemy Attacks/simple attack")
		is_attack_on = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Enemy Attacks/simple attack":
		anim_player.play("Enemy Movements/idle")
		$Scaler/hand_right/Sword/SwordArea.set_deferred("monitorable", false)
	if anim_name == "Enemy Movements/Stunned" and enemy_health > 0:
		anim_player.play("Enemy Movements/idle")
		ai = true
		is_attack_on = false
		timer.wait_time = 0.1
		timer.autostart = true
		timer.start()

func _on_sword_area_area_entered(area: Area3D) -> void:
	if area.owner is Player and dead == false and ai:
		get_tree().call_group("Player", "get_damage", Enemy_Damage)
		SwordCollison.set_deferred("disabled", true)
		$Scaler/hand_right/Sword/SwordArea.set_deferred("monitorable", false)
		is_attack_on = false

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if ai and dead == false:
		velocity = velocity.move_toward(safe_velocity, .25)
		move_and_slide()

func get_stunned(parry_on):
	if is_attack_on and parry_on and dead == false:
		parry_on = false
		timer.autostart = false
		timer.wait_time = 4
		timer.start()
		ai = false
		anim_player.play("Enemy Movements/Stunned")
		$Scaler/hand_right/Sword/SwordArea.set_deferred("monitorable", false)
		SwordCollison.set_deferred("disabled", true)

func is_dead():
	queue_free()
