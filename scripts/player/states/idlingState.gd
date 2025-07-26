# res://player/states/IdleState.gd
extends PlayerState

func exit():
	player.coll_area_idle.monitoring = false
	player.coll_area_idle.input_pickable = false
	player.collision_idle.disabled = true

func enter():
	player.animation_sprite.play("idling")
	
	player.coll_area_idle.monitoring = true 
	player.coll_area_idle.input_pickable = true
	player.collision_idle.disabled = false
	
	#player.collision_greetings.disabled = true
	#player.collision_rolling.disabled = true
	#player.collision_petting.disabled = true
	#player.collision_walking.disabled = true
	
	# set the local state
	e_current_local_state = GOTO_STATES.UNDECIDED
	
	# print("\n\ncurrent local state: " + str(e_current_local_state))
	e_current_local_state = _determine_what_state()
	# print("after setting determine what state local state: " + str(e_current_local_state))
	
	match e_current_local_state:
		GOTO_STATES.GO_WALK:
			_change_seconds_left_to_change_state()
			# print(e_seconds_left_to_change_state)
			player.state_timer.start(e_seconds_left_to_change_state)
			
		GOTO_STATES.GO_TICKLE:
			_change_seconds_left_to_change_state(1.3) # 1.3 times longer before going to wait for tickle
			# print(e_seconds_left_to_change_state)
			player.state_timer.start(e_seconds_left_to_change_state)
			
			
			
	
func physics_update(delta: float) -> void:
	player.move_and_slide()


#####################################################################
#####################################################################
#####################################################################
@export var e_min_idle_time: float = 1.0 # 1.0
@export var e_max_idle_time: float = 2.0 # 5.0
var e_seconds_left_to_change_state: float 
const e_chance_go_walk: float = 0.9 # 0.9
const e_chance_go_tickle: float = 1.0 - e_chance_go_walk
enum GOTO_STATES{
	GO_WALK,
	GO_TICKLE,
	UNDECIDED
}
var e_current_local_state: GOTO_STATES = GOTO_STATES.UNDECIDED


func _change_seconds_left_to_change_state(m_override_max: float = 1.0) -> void:
	e_seconds_left_to_change_state = randf_range(e_min_idle_time, e_max_idle_time * m_override_max)

func update(delta) -> void:
	# print("time_left: " + str(player.state_timer.time_left).pad_decimals(3)
		# + "\t\tvelocity: " + str(player.velocity.length()).pad_decimals(3))
	pass
	
	
func on_state_timer_timeout() -> void:
	match e_current_local_state:
		GOTO_STATES.GO_WALK:
			player._change_state(load("res://scripts/player/states/walkingState.gd").new())
			# print("going to walk")
		GOTO_STATES.GO_TICKLE:
			player._change_state(load("res://scripts/player/states/petNoHoldAwaitPetState.gd").new())
			# print("waiting tickle")
				
func _determine_what_state() -> GOTO_STATES:
	var m_lottery_result : float = randf_range(0., 1.)
	m_lottery_result=0.91 # set it to go tickle
	# m_lottery_result = 0.1
	# print("_______mloteery reuslt: " + str(m_lottery_result))
	if 0 >= m_lottery_result or m_lottery_result <= e_chance_go_walk: # 0-90%
		# print("==============go_walk: " + str(GOTO_STATES.GO_WALK))
		return GOTO_STATES.GO_WALK
	else:	# 90.0001 - 100%
		# print("==============go_tickle: " + str(GOTO_STATES.GO_TICKLE))
		return GOTO_STATES.GO_TICKLE


################################################################
################################################################ 
################################################################
func on_collision_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("greeting area clicked;\nproceeding to roll")
		player._change_state(load("res://scripts/player/states/rollingState.gd").new())
	"""
	print("-------collision area input in idle ")
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.cursor_changed = true 
		print("\n=======\nCat1 clicked, changing state to pethold \n=======");
		
		player._change_state(load("res://scripts/player/states/petHoldState.gd").new())

	if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		player.cursor_changed = true 
		print("\n=======\ngraabiingg dis fkr\n=======");
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())
		

#func on_collision_area_input_event(viewport: Node, event: InputEventMouseButton, shape_idx: int) -> void:
	#"""
	#handles the mouse cursor
	#"""
	#pass 
	#print("on hamzter, collision area input event")
	## all mouse input are decided here
	#if event.pressed:
		#player.cursor_changed = true 
		#
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Left click on area")
			#Input.set_custom_mouse_cursor(cursor_left_click, Input.CURSOR_ARROW, cursor_dimension/2)
		#if event.button_index == MOUSE_BUTTON_RIGHT:
			#print("Right click on area")
			#Input.set_custom_mouse_cursor(cursor_right_click, Input.CURSOR_ARROW, cursor_dimension/2)
			

"""
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


func handle_input(event):
	if event.is_action_pressed("click"):
		if is_click_on_visible_pixel(player.get_global_mouse_position()):
			pass
			print("\n=======\nCat1 clicked, changing state to pethold \n=======");
			
			player._change_state(load("res://scripts/player/states/petHoldState.gd").new())

	if event.is_action_pressed("rclick"):
		if is_click_on_visible_pixel(player.get_global_mouse_position()):
			player._change_state(load("res://scripts/player/states/grabbingState.gd").new())
		

"""
