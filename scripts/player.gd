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


func _ready():
	#for some reason has_jumped fires off without a reason
	max_speed -= jump_slowing_down


func _process(delta):
	if has_jumped and is_on_floor():
		max_speed += jump_slowing_down
		has_jumped = false
		tick = false
	
	
func _physics_process(delta):
	movement()
	#print(velocity.x)
	
	#lowers max speed if in air
	if !is_on_floor():
		#gravity
		velocity.y += get_gravity() * delta 
		if has_jumped and !tick:
			max_speed -= jump_slowing_down
			tick = true
		has_jumped = true
	
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
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
		direction = "left"
	elif Input.is_action_pressed("ui_right"):
		is_moving = true
		direction = "right"
	else: 
		
		is_moving = false
		deceleration()
	move_and_slide(velocity, Vector2.UP)
	


func acceleration():
	if velocity.x < max_speed and direction == "right":
		velocity.x += acceleration / 2
	elif velocity.x > -max_speed and direction == "left":
		velocity.x -= acceleration / 2
	else:
		#current_speed = max_speed
		velocity.x = max_speed * sign(velocity.x)

func deceleration():
	if velocity.x > 0 and direction == "right":
		velocity.x -= deceleration
	elif velocity.x < 0 and direction == "left":
		velocity.x += deceleration
	else: velocity.x = 0


func get_gravity() -> float:  #sets gravity type
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump(): #jumping
	velocity.y = jump_velocity
	
















