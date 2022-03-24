extends Node2D

export var IDLE_DURATION = 1.0

export var move_to = Vector2.RIGHT * 192
export var speed = 3.0

onready var tween = $StaticBody2D/Tween
onready var platform = $StaticBody2D


func _ready():
	_init_tween()

func _init_tween():
	var duration = move_to.length() / float(speed)
	tween.interpolate_property(platform, "position", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_DURATION)
	tween.interpolate_property(platform, "position", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, duration + IDLE_DURATION * 2)
	tween.start()


