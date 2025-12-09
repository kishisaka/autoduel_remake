extends CharacterBody2D

enum states { PATROL, CHASE, ATTACK, DEAD }
var state = states.CHASE
@export var player: CharacterBody2D

var projectile_scene = preload("res://projectile.tscn")

var wheel_base = 70
var steering_angle = 30
var engine_power = 300
var friction = -55
var drag = -0.06
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 2.5
var traction_slow = 10
var isReversing = false
var isFiring = false

var acceleration = Vector2.ZERO
var steer_direction

func _physics_process(delta):
	acceleration = Vector2.ZERO
	if player != null:
		get_player_direction()
		"""
		get_input_direcitonal_with_reverse()
		fireGun()
		"""
		apply_friction(delta)
		calculate_steering(delta)
		velocity += acceleration * delta
		move_and_slide()
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
func fireGun():
	if isFiring:
		fire_gun()
	
func get_player_direction():
	var turn = 0 
	"""
	print("Enemy turn = ", self.global_position.angle_to(self.global_position.direction_to(player.global_position)))
	"""
	turn = self.transform.x.angle_to(self.global_position.direction_to(player.global_position))
	steer_direction = turn * deg_to_rad(steering_angle)
	acceleration = transform.x * engine_power

func get_input_direcitonal_with_reverse():
	var turn = 0
	var input_direction = Input.get_vector("left","right","up","down")
	turn = transform.x.cross(input_direction)
	steer_direction = turn * deg_to_rad(steering_angle)
	if input_direction.length() != 0:
		if isReversing:
			acceleration = transform.x * -engine_power
		else:
			acceleration = transform.x * engine_power
	if Input.is_action_pressed("b1"):
		print("is braking")
		acceleration = transform.x * braking
	if Input.is_action_just_pressed("r1"):
		isReversing = !isReversing
		print("is reversing: " + str(isReversing))
	if Input.is_action_just_released("fire"):
		isFiring = false
	if Input.is_action_just_pressed("fire"):
		isFiring = true
		
func fire_gun():
	var projectile = projectile_scene.instantiate()
	# Spawn projectile offset from car to avoid immediate collision
	projectile.position = position + transform.x * 80
	projectile.direction = transform.x
	projectile.shooter = self
	get_parent().add_child(projectile)
	
func get_input():
	var turn = Input.get_axis("steer_left", "steer_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
	
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
#	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()
