# res://player/states/GreetingState.gd
extends PlayerState

func enter():
	player.animation_sprite.play("intro_greetings1")
	player.coll_area_greetings.monitoring = true 
	player.coll_area_greetings.input_pickable = true
	player.collision_greetings.disabled = false
	
	player.collision_rolling.disabled = true
	player.collision_idle.disabled = true
	player.collision_walking.disabled = true
	player.collision_petting.disabled = true
	player.collision_grabbing.disabled = true
	
	player.azy_animation_sprite.hide()
	
	
func exit() -> void:
	player.coll_area_greetings.monitoring = false
	player.coll_area_greetings.input_pickable = false
	player.collision_greetings.disabled = true
	

func on_animation_finished():
	# Optional: Go idle after greeting ends
	pass

func physics_update(delta: float) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	if event.is_action_pressed("click"):
		pass
	
# handle the input
func on_collision_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("greeting area clicked")
		player._change_state(load("res://scripts/player/states/rollingState.gd").new())
		
"""
	
var current_frame := -1
var current_animation := ""
func update(delta: float) -> void:
	var anim_sprite = player.animation_sprite
	if anim_sprite.frame != current_frame or anim_sprite.animation != current_animation:
		_setup_bitmask()
		current_frame = anim_sprite.frame
		current_animation = anim_sprite.animation


####################################################################
##################################################################
################### HANDLE INPUT ##################################
###################################################################
var bitmask: BitMap
func _setup_bitmask():
	var tex = player.animation_sprite.sprite_frames.get_frame_texture(player.animation_sprite.animation, player.animation_sprite.frame)
	var image = tex.get_image()
	bitmask = BitMap.new()
	bitmask.create_from_image_alpha(image, 0.1)  # threshold: alpha > 0.1 = opaque
	
func is_click_on_visible_pixel(global_pos: Vector2) -> bool:
	if bitmask == null:
		return false
	var local_pos = player.animation_sprite.to_local(global_pos)
	var image_pos = (local_pos + Vector2(bitmask.get_size()) / 2).floor()
	
	if not Rect2(Vector2.ZERO, Vector2(bitmask.get_size())).has_point(image_pos):
		return false

	return bitmask.get_bitv(image_pos)
	
	
	

@onready var rigid_body_2d: RigidBody2D = $Mouse/RigidBody2D

func handle_input(event):
	pass
	if event.is_action_pressed("click"):
		# if player.is_pixel_opaque(player.get_local_mouse_position()):
		if is_click_on_visible_pixel(player.get_global_mouse_position()):
			print("\n=======\nCat1 clicked, changing state to rolling \n=======");
			
			player._change_state(load("res://scripts/player/states/rollingState.gd").new())


"""
