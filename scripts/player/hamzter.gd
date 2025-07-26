# res://player/Player.gd
extends CharacterBody2D

const WALK_SPEED: float = 500.0
const NEAR_DISTANCE: float = 500.0

@onready var animation_sprite: AnimatedSprite2D = $animationSprite

@onready var coll_area_greetings: Area2D = $coll_area_greetings
@onready var collision_greetings: CollisionShape2D = $coll_area_greetings/collision_greetings
@onready var collision_rolling: CollisionShape2D = $coll_area_rolling/collision_rolling
@onready var collision_idle: CollisionShape2D = $coll_area_idle/collision_idle
@onready var collision_walking: CollisionShape2D = $coll_area_walking/collision_walking
@onready var collision_petting: CollisionShape2D = $coll_area_petting/collision_petting

@onready var azy_timer: Timer = $azy_timer
@onready var azy_animation_sprite: AnimatedSprite2D = $azy_animationSprite
@onready var collision_grabbing: CollisionShape2D = $coll_area_grabbing/collision_grabbing

# timers
@onready var state_timer: Timer = $state_timer
@onready var local_timer: Timer = $local_timer

var current_state: PlayerState
var bitmask: BitMap = BitMap.new()

# global variables
var g_tickle_threshold: float = 1300.0
var g_tickle_accumulation: float = 0.0


func _ready():
	_change_state(load("res://scripts/player/states/greetingState.gd").new())
	
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
		
		
func _process(delta):
	if current_state:
		current_state.update(delta)
	if Input.is_action_just_pressed("escac"):
		get_tree().quit()
	
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


func _on_collision_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
	if current_state:
		current_state.on_collision_area_input_event(viewport, event, shape_idx)
