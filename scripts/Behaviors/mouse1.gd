extends Node


""" uses rigid body
func _process(delta: float) -> void:
	_process_mouse()
	
@onready var mouse_body: RigidBody2D = $RigidBody2D
@onready var mouse_sprite: AnimatedSprite2D = $RigidBody2D/mouse_sprite

# @onready var mouse_sprite: AnimatedSprite2D = $"../Mouse/RigidBody2D/mouse_sprite"
var e_current_mouse_state: MOUSE_STATES = MOUSE_STATES.NORMAL
enum MOUSE_STATES{
	PETTING, # left click
	GRAB,	# rclick
	NORMAL, # last option
}
func _process_mouse():
	# set the states
	if Input.is_action_pressed("click"):
		e_current_mouse_state = MOUSE_STATES.PETTING
	elif Input.is_action_pressed("rclick"):
		e_current_mouse_state = MOUSE_STATES.GRAB
	else:
		e_current_mouse_state = MOUSE_STATES.NORMAL
		
	# set the sprites
	match e_current_mouse_state:
		MOUSE_STATES.PETTING:
			mouse_sprite.play("petting")
		MOUSE_STATES.GRAB:
			mouse_sprite.play("grab")
		MOUSE_STATES.NORMAL:
			mouse_sprite.play("normal")
		
	# set the position of the sprite to that of the position of the mouse
	mouse_body.position = get_global_mouse_position()
	
	# and the size and bug ?rotation?
	const m_size = 0.025
	mouse_body.scale = Vector2(m_size, m_size)
	mouse_body.rotation = 0
	

"""
