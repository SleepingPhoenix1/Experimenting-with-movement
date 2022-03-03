extends KinematicBody2D
signal landed

var tick = false
var current_speed = 0
var is_moving = false

var direction
var can_move = true

export var acceleration = 10
export var export_deceleration = 20
var deceleration = 15

export var export_max_speed = 120
var max_speed = 100
export var turning_speed = 50

var velocity = Vector2()
#jumping variables
export var jump_slowing_down = 3

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float
export var lowfallMultiplier = 1
var jump_buffer = false

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
#falling variables
export var maxfallspeed = 200
var has_pressed_jump = false
var has_jumped = false
export var slower_fall_mult = 20

#wall stuff variables
onready var left_wall_raycasts = $WallRaycastsLeft
onready var right_wall_raycasts = $WallRaycastsRight
var wall_direction = 0
export var max_wall_slide_speed = 20
export var Wall_jump_Velocity = Vector2(10, 10)
var has_wall_jumped =false
export var wall_climb_speed = 50

var can_wall_climb = true
var is_wall_climbing = false
#stamina
export var max_stamina = 200
var stamina = max_stamina
export var stamina_on_wall : float = 1
export var stamina_wall_climb = 2
export var stamina_wall_climb_jump = 5


func _ready():
	max_speed = export_max_speed
	deceleration = export_deceleration

func _process(delta):
	if (has_jumped or has_wall_jumped) and is_on_floor():
		max_speed = export_max_speed
		has_jumped = false
		has_wall_jumped = false
		tick = false
		
	
	#lowers max speed if in air
	if !is_on_floor():
		#gravity
		
		velocity.y += get_gravity() * delta 
		if has_jumped and !tick:
			max_speed -= jump_slowing_down
			tick = true
			has_pressed_jump = false
		has_jumped = true
	
	



func _physics_process(delta):
	movement()
	_update_wall_directions()
	print(has_wall_jumped)
	
	#jump buffering
	if $jumpBuffer.is_colliding() and Input.is_action_just_pressed("ui_jump") and velocity.y > 0:
		jump_buffer = true
	
	if Input.is_action_just_pressed("ui_jump") or (is_on_floor() and jump_buffer):
		has_pressed_jump = true
		
		if is_on_floor() or !$"Coyote timer".is_stopped():
			jump()
			$SoundPlayer.stream = preload("res://soundeffects/jump.ogg")
			$SoundPlayer.play()
			$"Coyote timer".stop()
		has_jumped = true
	
	#low jumping
	if has_jumped and Input.is_action_just_released("ui_jump") and velocity.y < 0:
		velocity.y += lowfallMultiplier


func movement():
	#acceleration 
	if is_moving and can_move:
		acceleration()
	
	
	
	#controls
	if Input.is_action_pressed("ui_left"):
		is_moving = true
		direction = -1
		$CharacterSprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		is_moving = true
		direction = 1
		$CharacterSprite.flip_h = false
	else: 
		
		is_moving = false
		deceleration()
	
	#coyote timer
	var was_on_floor = is_on_floor()
	
	move_and_slide(velocity, Vector2.UP)
	
	if !is_on_floor() and was_on_floor and !has_jumped and velocity.y > 0:
		$"Coyote timer".start()
	
	
	workarounds()
	
	#wall jumping and sliding
	if !is_on_floor() and wall_direction != 0:
		wall_jumping()
		if Input.is_action_pressed("ui_left") and wall_direction == -1 and velocity.y > 0:
			velocity.y = max_wall_slide_speed
		elif Input.is_action_pressed("ui_right") and wall_direction == 1 and velocity.y > 0:
			velocity.y = max_wall_slide_speed
	
	#wall climbing
	if Input.is_action_pressed("climb") and wall_direction != 0 and can_wall_climb and stamina > 0:
		has_wall_jumped = false
		#print("b")
		can_move = false
		jump_gravity = 0
		fall_gravity = 0
		if Input.is_action_pressed("ui_up"):
			velocity.y = -wall_climb_speed 
			stamina -= stamina_wall_climb
		elif Input.is_action_pressed("ui_down"):
			velocity.y = wall_climb_speed
			stamina -= stamina_wall_climb
		else: 
			velocity.y = 0
			stamina -= stamina_on_wall
		is_wall_climbing = true
	else:
		#print("a")
		if !has_wall_jumped:
			can_move = true
		jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
		fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
		is_wall_climbing = false
	


func acceleration():
	if velocity.x < max_speed and direction == 1:
		velocity.x += acceleration #/ 2
	elif velocity.x > -max_speed and direction == -1:
		velocity.x -= acceleration #/ 2
	else:
		velocity.x = max_speed * sign(velocity.x)


func deceleration():
	if velocity.x > 0 and direction == 1:
		velocity.x -= deceleration
	elif velocity.x < 0 and direction == -1:
		velocity.x += deceleration
	elif (wall_direction !=0 and !is_on_floor()) or has_wall_jumped:
		velocity.x += deceleration * wall_direction
	else: velocity.x = 0


func get_gravity() -> float:  #sets gravity type
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump(): #jumping
	velocity.y = jump_velocity
	jump_buffer = false

func wall_jump(climbing): #wall jumping
	velocity.y = jump_velocity+10
	if !climbing:
		velocity.x += 125 * -wall_direction
	$SoundPlayer.stream = preload("res://soundeffects/jump.ogg")
	$SoundPlayer.play()
	has_wall_jumped = true

func wall_jumping():
	if Input.is_action_just_pressed("ui_jump"):
		stamina -= stamina_wall_climb_jump
		can_wall_climb = false
		var wall_jump_velocity = Wall_jump_Velocity
		if !is_moving and stamina > 0 and is_wall_climbing:
			wall_jump(true)
		else: 
			wall_jump(false)
			can_move = false
			$wall_jump_timer.start()

func _update_wall_directions():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	if is_near_wall_left and is_near_wall_right:
		wall_direction = direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)


#checks if colliding with wall and returns true or false
func _check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
	return false



func _on_wall_jump_timer_timeout():
	can_move = true

func workarounds():
		#max falling speed
	if velocity.y > maxfallspeed:
		velocity.y = maxfallspeed
	
	#stops y velocity if you hit ceiling
	if is_on_ceiling():
		velocity.y = 0
	
	#removes y velocity when on ground
	if is_on_floor() and !has_jumped:
		velocity.y = 1
		stamina = max_stamina
	
	#removes x velocity if colliding with a wall
	if is_on_wall():
		velocity.x = 0
	
	#fall detector
	if velocity.y > 0:
		can_wall_climb = true
		
	
	#stamina sliding
	if stamina <= 0 and wall_direction != 0 and !has_wall_jumped:
		velocity.y = max_wall_slide_speed+30
		
