extends KinematicBody2D
signal landed

var tick = false
var current_speed = 0
var is_moving = false
var has_jumped = false
var direction

export var acceleration = 10
export var deceleration = 15
export var max_speed = 100


var velocity = Vector2()
#jumping variables
export var jump_slowing_down = 3

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float
export var lowfallMultiplier = 1

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
#falling variables
export var maxfallspeed = 200
var has_pressed_jump = false

#wall stuff variables
onready var left_wall_raycasts = $WallRaycastsLeft
onready var right_wall_raycasts = $WallRaycastsRight
var wall_direction = 0
export var max_wall_slide_speed = 20
export var Wall_jump_Velocity = Vector2(10, 10)
var has_wall_jumped =false


func _ready():
	#for some reason has_jumped fires off without a reason
	max_speed -= jump_slowing_down
	


func _process(delta):
	if (has_jumped or has_wall_jumped) and is_on_floor():
		max_speed += jump_slowing_down
		has_jumped = false
		has_wall_jumped = false
		tick = false
		
	
	
	
	



func _physics_process(delta):
	movement()
	_update_wall_directions()
	#print(wall_direction)
	
	#lowers max speed if in air
	if !is_on_floor():
		#gravity
		velocity.y += get_gravity() * delta 
		if has_jumped and !tick:
			max_speed -= jump_slowing_down
			tick = true
			has_pressed_jump = false
		has_jumped = true
	
	if Input.is_action_just_pressed("ui_jump"):
		has_pressed_jump = true
		if is_on_floor():
			jump()
	
	#low jumping
	if has_jumped and Input.is_action_just_released("ui_jump") and velocity.y < 0:
		velocity.y += lowfallMultiplier


func movement():
	#acceleration 
	if is_moving:
		acceleration()
	
	
	
	#controls
	if Input.is_action_pressed("ui_left"):
		is_moving = true
		direction = -1
	elif Input.is_action_pressed("ui_right"):
		is_moving = true
		direction = 1
	else: 
		
		is_moving = false
		deceleration()
	move_and_slide(velocity, Vector2.UP)
	
	#max falling speed
	if velocity.y > maxfallspeed:
		velocity.y = maxfallspeed
	
	#stops y velocity if you hit ceiling
	if is_on_ceiling():
		velocity.y = 0
	
	#removes y velocity when on ground
	if is_on_floor() and !has_pressed_jump:
		velocity.y = 1
	
	#wall jumping and sliding
	if !is_on_floor() and wall_direction != 0:
		wall_jumping()
		if Input.is_action_pressed("ui_left") and wall_direction == -1 and velocity.y > 0:
			velocity.y = max_wall_slide_speed
		elif Input.is_action_pressed("ui_right") and wall_direction == 1 and velocity.y > 0:
			velocity.y = max_wall_slide_speed




func acceleration():
	if velocity.x < max_speed and direction == 1:
		velocity.x += acceleration / 2
	elif velocity.x > -max_speed and direction == -1:
		velocity.x -= acceleration / 2
	else:
		velocity.x = max_speed * sign(velocity.x)
	

func deceleration():
	if velocity.x > 0 and direction == 1:
		velocity.x -= deceleration
	elif velocity.x < 0 and direction == -1:
		velocity.x += deceleration
	elif (wall_direction !=0 and !is_on_floor()) or has_wall_jumped:
		velocity.x += deceleration * wall_direction *6
	else: velocity.x = 0


func get_gravity() -> float:  #sets gravity type
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump(): #jumping
	velocity.y = jump_velocity
	


func wall_jumping():
	if Input.is_action_just_pressed("ui_jump"):
		has_wall_jumped = true
		var wall_jump_velocity = Wall_jump_Velocity
		wall_jump_velocity.x *= -wall_direction 
		velocity = wall_jump_velocity

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










