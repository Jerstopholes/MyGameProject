extends KinematicBody2D


export (float) var speed = 200.0

var velocity = Vector2(0, 0)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	if not GameManager.console_active:
		get_input()
		velocity = move_and_slide(velocity)
