# res://scripts/player/hamzter.gd
extends CharacterBody2D

const WALK_SPEED: float = 500.0
const NEAR_DISTANCE: float = 500.0

@onready var animation_sprite: AnimatedSprite2D = $animationSprite

@onready var coll_area_greetings: Area2D = $coll_area_greetings
@onready var collision_greetings: CollisionShape2D = $coll_area_greetings/collision_greetings
@onready var coll_area_rolling: Area2D = $coll_area_rolling
@onready var collision_rolling: CollisionShape2D = $coll_area_rolling/collision_rolling
@onready var coll_area_idle: Area2D = $coll_area_idle
@onready var collision_idle: CollisionShape2D = $coll_area_idle/collision_idle
@onready var coll_area_walking: Area2D = $coll_area_walking
@onready var collision_walking: CollisionShape2D = $coll_area_walking/collision_walking
@onready var coll_area_petting: Area2D = $coll_area_petting
@onready var collision_petting: CollisionShape2D = $coll_area_petting/collision_petting
@onready var coll_area_grabbing: Area2D = $coll_area_grabbing
@onready var collision_grabbing: CollisionShape2D = $coll_area_grabbing/collision_grabbing
@onready var collision_default_grabbing: CollisionShape2D = $collision_default_grabbing # the default collision handler
@onready var collision_sitting: CollisionShape2D = $collision_sitting


@onready var azy_timer: Timer = $azy_timer
@onready var azy_animation_sprite: AnimatedSprite2D = $azy_animationSprite

# timers
@onready var state_timer: Timer = $state_timer
@onready var local_timer: Timer = $local_timer

# mouse cursors
var cursor_left_click = preload("res://assets/mouse/cursors-pic-64x64/petting.png")
var cursor_right_click = preload("res://assets/mouse/cursors-pic-64x64/grabbing.png")
var cursor_default = preload("res://assets/mouse/cursors-pic-64x64/normal.png")
var cursor_dimension: Vector2 = cursor_default.get_size()
var cursor_changed: bool = false

var current_state: PlayerState
var bitmask: BitMap = BitMap.new()

# global variables
var g_tickle_threshold: float = 1300.0
var g_tickle_accumulation: float = 0.0


func _ready():
	await get_tree().create_timer(1.0).timeout

	_change_state(preload("res://scripts/player/states/greetingState.gd").new())
	
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
		
func _process(delta):
		
	if current_state:
		current_state.update(delta)
	
	# test wifi access point
	# UPS
	# udpated the record of the inventory for disposal. Specifically 
	# monitor
	
	# errands (for following instructions, and interpersonal communication development)
	#	: getting tape from the inventory
	#	: 
	# proper lifting posture: healthy living 
	
	# ::::::::::::::::business practices:::::::::::::::
	# 

func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)
	
	""" do this event driven """
	if Input.is_action_just_pressed("escac"):
		get_tree().quit()
		
	""" CONTEXT: handles the mouse cursor """
	# normal
	if event is InputEventMouseButton and not event.pressed and cursor_changed:
		# Reset cursor globally when mouse is released
		#print("setting to default")
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW, cursor_dimension/2)
		cursor_changed = false
	
	# left click and right click		
	if event is InputEventMouseButton and event.pressed:
		cursor_changed = true 
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click on area")
			Input.set_custom_mouse_cursor(cursor_left_click, Input.CURSOR_ARROW, cursor_dimension/2)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click on area")
			Input.set_custom_mouse_cursor(cursor_right_click, Input.CURSOR_ARROW, cursor_dimension/2)
			
	""" CONTEXT: handle the sitting """
	#if event is InputEventKey:
		#if event.pressed and event.
			#pass
	if Input.is_action_just_pressed("spice"):
		_change_state(load("res://scripts/player/states/sittingState.gd").new())
		
			

func _on_animation_sprite_animation_finished():
	if current_state:
		current_state.on_animation_finished()

func _on_animation_sprite_frame_changed():
	if current_state:
		current_state.on_animation_frame_changed()

func _change_state(new_state: PlayerState):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.player = self
	add_child(current_state)  # Optional, only if you want states to access scene tree
	current_state.enter()


func _on_state_timer_timeout() -> void:
	if current_state:
		current_state.on_state_timer_timeout()

func _on_local_timer_timeout() -> void:
	if current_state:
		current_state.on_local_timer_timeout()
		
func _on_azy_timer_timeout() -> void:
	if current_state:
		current_state.on_azy_timer_timeout()


func _on_azy_animation_sprite_animation_finished() -> void:
	if current_state:
		current_state.on_azy_animation_sprite_animation_finished()


func _on_azy_animation_sprite_animation_looped() -> void:
	if current_state:
		current_state.on_azy_animation_sprite_animation_looped()


func _on_collision_area_input_event(viewport: Node, event, shape_idx: int) -> void:
	if current_state:
		current_state.on_collision_area_input_event(viewport, event, shape_idx)


func _on_coll_area_mouse_entered() -> void:
	pass 
	if current_state:
		# always default to default mouse
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW, cursor_dimension/2)
		
		current_state.on_coll_area_mouse_entered()


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.polling_input(event);

func _on_coll_area_mouse_exited() -> void:
	pass 
	if cursor_changed:
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW, cursor_dimension/2)
		cursor_changed = false
	if current_state:
		current_state.on_coll_area_mouse_exited()
	
