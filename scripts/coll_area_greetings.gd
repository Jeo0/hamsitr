extends Area2D

"""


# Load custom cursor images
var cursor_left_click = preload("res://assets/mouse/cursors-pic-128x128/petting-gesture.png")
var cursor_right_click = preload("res://assets/mouse/cursors-pic-128x128/grabbing-gesture.png")
var default_cursor = preload("res://assets/mouse/cursors-pic-128x128/normal-gesture.png")

func _ready():
	# Connect signals (only needed if not connected in editor)
	# connect("input_event", Callable(self, "_on_input_event"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
func _process(delta) -> void:
	pass
	

func _on_input_event(viewport, event: InputEventMouseButton, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click on area")
			Input.set_custom_mouse_cursor(cursor_left_click, Input.CURSOR_DRAG, Vector2(64,64))
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click on area")
			Input.set_custom_mouse_cursor(cursor_right_click, Input.CURSOR_MOVE, Vector2(64,64))
	else:
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(64,64))
		

func _on_mouse_entered() -> void:
	print("Mouse entered area")
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(64,64))
	
func _on_mouse_exited():
	print("Mouse exited area")
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(64,64))

"""
