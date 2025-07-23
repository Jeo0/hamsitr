extends PlayerState


enum GOTO_STATES{
	GO_HOLD,
	GO_BLINK,
	GO_NOHOLD,
	GO_TICKLE,
	GO_WALK,
	UNDECIDED
}

# Called when the node enters the scene tree for the first time.
func enter() -> void: # Replace with function body.
	player.animation_sprite.play("petting_holding")
	player.animation_sprite.frame = 0;
	player.animation_sprite.pause()
	player.collision_idle.disabled = true
	player.collision_walking.disabled = true
	player.collision_petting.disabled = false;
	
	# _change_seconds_left_to_change_state()
	# player.state_timer.start(e_seconds_left_to_change_state)


const e_chance_go_hold: float = 0.6 # 0.96						# 96%
const e_chance_go_blink: float = 1.0 - e_chance_go_hold # 10%
@export var e_min_wait_tickle_time: float = 0.5 # 1.0
@export var e_max_wait_tickle_time: float = 2.0 # 10.0
@export var e_min_blink_time: float = 0.15
@export var e_max_blink_time: float = 0.25
@export var e_max_dilat_time: float = 5.0
# 
var e_current_local_state: GOTO_STATES = GOTO_STATES.GO_HOLD
var e_previous_local_state: GOTO_STATES = GOTO_STATES.UNDECIDED


func update(delta: float) -> void:
	var m_new_state: GOTO_STATES = _determine_what_state()
	
	if m_new_state != e_current_local_state:
		e_previous_local_state = e_current_local_state
		e_current_local_state = m_new_state
		_on_state_change(m_new_state)
		
	# e_current_local_state = _determine_what_state()
	
	_process_current_state(delta)


func _determine_what_state() -> GOTO_STATES:
	var m_lottery_result : float = randf_range(0., 1.)
	# print("loterry: " + str(m_lottery_result).pad_decimals(3)
		# + "\tlocalTimeLeft:" + str(player.local_timer.time_left).pad_decimals(3))
	
	# if blinking & timer run out: return GO_HOLD
	if e_current_local_state == GOTO_STATES.GO_BLINK and player.local_timer.time_left <= 0.001:
		print("GOING TOHOLD====================================================")
		return GOTO_STATES.GO_HOLD

	# If holding and timer ran out, maybe go to blink
	if e_current_local_state == GOTO_STATES.GO_HOLD and player.local_timer.time_left <= 0.0:
		if randf() <= e_chance_go_blink:
			return GOTO_STATES.GO_BLINK
			
	# else just stay where they are 
	return e_current_local_state
	

func _on_state_change(m_new_state: GOTO_STATES) -> void:
	match m_new_state:
		GOTO_STATES.GO_BLINK:
			player.local_timer.start(randf_range(e_min_blink_time, e_max_blink_time))
			player.animation_sprite.frame = 1  # closed eyes
		GOTO_STATES.GO_HOLD:
			player.local_timer.start(randf_range(1.5, e_max_dilat_time))  # time until next possible blink
			player.animation_sprite.frame = 0 # open eyes
	# print("state_timer: " + str(player.state_timer.time_left).pad_decimals(3) 
			# + "state: " + str(e_current_local_state))


func _process_current_state(delta: float) -> void:
	# print()
	pass


#########################################################################
#########################################################################
############### HANDLE THE INPUT ########################################
#########################################################################
#########################################################################
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



var e_accumulation_delta: float = 0
var e_original_location: float = 0
func handle_input(event):
	if event.is_action_released("click"):
		e_current_local_state = GOTO_STATES.GO_NOHOLD
		player._change_state(load("res://scripts/player/states/petNoHoldAwaitPetState.gd").new())
		print("released click")
	
	
	# record the destruction history
	# (movement delta) accumulate
	print("mousevelo: " + str(Input.get_last_mouse_velocity().length()).pad_decimals(3)
		+ "\tmousescreen: " + str(Input.get_last_mouse_screen_velocity().length()).pad_decimals(3))
		
	# lets do it quick and dirty
	if Input.get_last_mouse_velocity().length() >= player.g_tickle_threshold: 
		player._change_state(load("res://scripts/player/states/petTickleState.gd").new())
	
