extends PlayerState

enum GOTO_STATES{
	GO_WAIT_TICKLE, 		# 98.5%
	GO_BLINK,			# 10%
	GO_HOLD
}

const e_chance_go_wait_tickle: float = 0.985						# 98.5%
const e_chance_go_blink: float = 1.0 - e_chance_go_wait_tickle # 10%
@export var e_min_wait_tickle_time: float = 0.5 # 1.0
@export var e_max_wait_tickle_time: float = 2.0 # 10.0
@export var e_min_blink_time: float = 0.1
@export var e_max_blink_time: float = 0.3
var e_current_local_state: GOTO_STATES = GOTO_STATES.GO_WAIT_TICKLE
var e_seconds_left_to_change_state: float 


func enter() -> void:
	#player.collision_idle.disabled = true
	#player.collision_walking.disabled = true
	#player.collision_petting.disabled = false;
	player.coll_area_petting.monitoring = true
	player.coll_area_petting.input_pickable = true
	player.collision_petting.disabled = false
	
	_change_seconds_left_to_change_state()
	player.state_timer.start(e_seconds_left_to_change_state)
	
	player.animation_sprite.play("petting_no_hold_await_pet")
	player.animation_sprite.frame = 0;
	player.animation_sprite.pause()
	
func exit() -> void:
	player.coll_area_petting.monitoring = false
	player.coll_area_petting.input_pickable = false
	player.collision_petting.disabled = true
	
	
	
func update(delta) -> void:
	#_setup_bitmask()
	
	e_current_local_state = _determine_what_state()
	match e_current_local_state:
		GOTO_STATES.GO_BLINK:
			# NOTE: always start the local timer to limit the time the blinking happens
			player.local_timer.start(e_max_blink_time)
			player.animation_sprite.frame = 1;
			
		GOTO_STATES.GO_WAIT_TICKLE:
			player.animation_sprite.frame = 0;
	# print("state_timer: " + str(player.state_timer.time_left).pad_decimals(3) 
			# + "state: " + str(e_current_local_state))
		
func on_local_timer_timeout() -> void:
	e_current_local_state = GOTO_STATES.GO_WAIT_TICKLE

func on_state_timer_timeout() -> void:
	player._change_state(load("res://scripts/player/states/walkingState.gd").new())


##################################################
########## HANDLING INPUT ########################
##################################################

func handle_input(event: InputEvent) -> void:
	# left click: hold
	if Input.is_action_just_pressed("click"):
		#print("presesd handleinput")
		e_current_local_state = GOTO_STATES.GO_HOLD
		player._change_state(load("res://scripts/player/states/petHoldState.gd").new())
		
	# right click: grab
	elif Input.is_action_just_pressed("rclick"):
		player.cursor_changed = true 
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())


func _determine_what_state() -> GOTO_STATES:
	var m_lottery_result : float = randf_range(0., 1.)
	
	# if the local timer does not meet/exceed the minimum blink time
	# go change state
	if player.local_timer.time_left >= e_min_blink_time:
		if 0 >= m_lottery_result or m_lottery_result <= e_chance_go_wait_tickle: # 0-90%
			# print("lottery: " + str(m_lottery_result).pad_decimals(3) + "\t\ttickle")
			return GOTO_STATES.GO_WAIT_TICKLE
		else:	# 90.0001 - 100%
			# print("lottery: " + str(m_lottery_result).pad_decimals(3) + "\t\tblink")
			return GOTO_STATES.GO_BLINK
	else: # just stay where it is originally
		return e_current_local_state
		

func _change_seconds_left_to_change_state(m_override_max: float = 1.0) -> void:
	e_seconds_left_to_change_state = randf_range(e_min_wait_tickle_time, e_max_wait_tickle_time * m_override_max)

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
		# if player.is_pixel_opaque(player.get_local_mouse_position()):
		if is_click_on_visible_pixel(player.get_global_mouse_position()):
			# print("\n=======\nCat1 clicked, changing state to pethold \n=======");
			
			e_current_local_state = GOTO_STATES.GO_HOLD
			player._change_state(load("res://scripts/player/states/petHoldState.gd").new())

"""
