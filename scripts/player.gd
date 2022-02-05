extends KinematicBody2D

var current_speed = 0
var is_moving = false
var direction

export var acceleration = 10
export var deceleration = 15
export var max_speed = 100
export (Curve) var acceleration_curve

var velocity = Vector2()



func _ready():
	pass


func _process(delta):
	max_speed * 2


func _physics_process(delta):
	movement()
	#print(velocity.x)


func movement():
	#acceleration and deceleration 
	if is_moving:
		acceleration()
	
	
	
	#controls
	if Input.is_action_pressed("ui_left"):
		#velocity.x -= current_speed
		is_moving = true
		direction = "left"
	elif Input.is_action_pressed("ui_right"):
		#velocity.x += current_speed
		is_moving = true
		direction = "right"
	else: 
		
		is_moving = false
		deceleration()
	move_and_slide(velocity, Vector2.UP)
	


func acceleration():
	if velocity.x < max_speed and direction == "right":
		velocity.x += acceleration
	elif velocity.x > -max_speed and direction == "left":
		velocity.x -= acceleration
	else:
		#current_speed = max_speed
		velocity.x = max_speed * sign(velocity.x)

func deceleration():
	if velocity.x > 0 and direction == "right":
		velocity.x -= deceleration
	elif velocity.x < 0 and direction == "left":
		velocity.x += deceleration
	else: velocity.x = 0























