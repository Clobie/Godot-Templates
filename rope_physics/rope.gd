extends Node2D

@export var ropeLength: float = 400
@export var pointCount: int = 50
@export var constrain: float = ropeLength / pointCount
@export var dampening: float = 0.95
@export var startPin: bool = true
@export var endPin: bool = true
@export var constrain_iterations: int = 5
@onready var line2D: = $Line2D

var gravity: Vector2 = Vector2(0, 25)
var pos: Array
var posPrev: Array
var string_width: float = 12

func _ready()->void:
	pos.resize(pointCount)
	posPrev.resize(pointCount)
	for i in range(pointCount):
		pos[i] = position + Vector2(constrain *i, 0)
		posPrev[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO
	line2D.width = string_width

func get_pointCount(distance: float)->int:
	return int(ceil(distance / constrain))

func _unhandled_input(event:InputEvent)->void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == 2:
			set_last(get_global_mouse_position())

func _process(delta)->void:
	set_start(get_global_mouse_position())
	for i in range(constrain_iterations):
		update_points(delta)
		update_constrain()
	line2D.points = pos

func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func set_last(p:Vector2)->void:
	pos[pointCount-1] = p
	posPrev[pointCount-1] = p

func update_points(delta)->void:
	for i in range (pointCount):
		if (i!=0 && i!=pointCount-1) || (i==0 && !startPin) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		if i == 0:
			if startPin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		elif i == pointCount-1:
			pass
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
