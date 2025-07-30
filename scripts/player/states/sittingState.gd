extends PlayerState

func exit() -> void:
	player.collision_sitting.disabled = true;
	player.azy_animation_sprite.position = Vector2.ZERO
	player.azy_animation_sprite.scale = Vector2(1,1)
	
	player.g_tickle_accumulation = 0
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()

func enter() -> void:
	player.collision_sitting.disabled = false;
	player.animation_sprite.play("sitting_default")
	
	# offset
	player.azy_animation_sprite.position = Vector2(-690,-250)
	player.azy_animation_sprite.scale *= 0.9
	
	
	
	
# player global variables
# g_tickle_threshold = 1300.0
# g_tickle_accumulation = 0.0

var e_current_state: GOTO_STATES = GOTO_STATES.GOTO_DEFAULT
const m_debug_factor: float = 0.7
const e_decay : float = 14000 * m_debug_factor;
const e_max_pet_semi_accumulation : float = 1300 * m_debug_factor;
const e_min_pet_semi_accumu: float = 3000 * m_debug_factor;
const e_min_iloveu_accumulation : float = 5000 * m_debug_factor;
const e_max_iloveu_accumulation : float = 9000 * m_debug_factor; # 220k

# azy animation
const e_min_azy_time: float = 10
const e_max_azy_time: float = 360
var e_time_left_till_azy: float = randf_range(e_min_azy_time,e_max_azy_time);

var e_decided_pet_state_a_or_b: bool = false;
var e_left_click_pressed: bool = false
var e_azy_shown: bool = false

var e_orig_scale: Vector2 = Vector2(0.195, 0.195)

enum GOTO_STATES{
	GOTO_DEFAULT,
	GOTO_DECAY,
	GOTO_TRANSITION,
	GOTO_PET_SEMI,
	GOTO_PET_A,
	GOTO_PET_B,
}
			

func _pet_a_or_b() -> GOTO_STATES:
	# if already decided
	# then keep it as it is
	# else decide new
	if e_decided_pet_state_a_or_b:		
		return e_current_state
	else:
		if randf() > 0.5: # 50.001% up to 100%
			return GOTO_STATES.GOTO_PET_A
		return GOTO_STATES.GOTO_PET_B
	
		
func on_animation_finished() -> void:
	""" override the animations	""" 
	pass
	
	# after animation finished on transition
	# proceed to set current state to semi
	#if e_current_state == GOTO_STATES.GOTO_TRANSITION:
		#e_current_state = GOTO_STATES.GOTO_PET_SEMI
	
	# decay to default
	#if e_current_state == GOTO_STATES.GOTO_DECAY:
		#e_current_state = GOTO_STATES.GOTO_DEFAULT
		

func handle_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#e_left_click_pressed = true
		#else:
			#var t := get_tree().create_timer(1.0)
			#await t.timeout
			## Guard: state might have been changed/freed during the await
			#if !is_instance_valid(self) or player.current_state != self:
				#return
			#e_left_click_pressed = false
	# change 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("\n=======\ngraabiingg dis fkr\n=======");
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())
	
	# left click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			e_left_click_pressed = true
		elif !event.pressed:
			await get_tree().create_timer(0.5).timeout
			e_left_click_pressed = false


func update(delta: float) -> void: 
	# guard
	#if player.current_state != self:
		#return
	##########################################################################
	######################## HANDLING AZY MSG ################################
	##########################################################################
	if e_azy_shown == false:
		e_time_left_till_azy -= delta;
		
		if e_time_left_till_azy <= delta:
			player.azy_animation_sprite.show()
			player.azy_animation_sprite.play("congratulatory")
			
			# proceed to show for a few sec and then byebye
			e_azy_shown = true
			e_time_left_till_azy = randf_range(3,10)
	
	
	elif e_azy_shown == true:
		e_time_left_till_azy -= delta
		
		if e_time_left_till_azy <= delta:
			player.azy_animation_sprite.hide()
			player.azy_animation_sprite.stop()
			
			e_azy_shown = false
			e_time_left_till_azy = randf_range(e_min_azy_time,e_max_azy_time)
			
	
	
	
	##########################################################################
	######################## HANDLE TICKLING #################################
	##########################################################################
	
	if e_left_click_pressed == true:
		if player.g_tickle_accumulation > e_min_iloveu_accumulation:     # 5000
			e_current_state = _pet_a_or_b()
			e_decided_pet_state_a_or_b = true

		elif player.g_tickle_accumulation > e_min_pet_semi_accumu:     # 3000
			e_current_state = GOTO_STATES.GOTO_PET_SEMI
			
		elif player.g_tickle_accumulation > player.g_tickle_threshold:     # 1300
			e_current_state = GOTO_STATES.GOTO_TRANSITION
		
		else:
			e_current_state = GOTO_STATES.GOTO_DEFAULT

		# always accumulate the mouse movemetn
		player.g_tickle_accumulation += Input.get_last_mouse_velocity().length() * delta

		# clamp it to 500k
		if player.g_tickle_accumulation >= e_max_iloveu_accumulation:   # 500k
			player.g_tickle_accumulation = e_max_iloveu_accumulation      
	####################################################################
	
	# else if no click
	elif e_left_click_pressed == false:
		e_decided_pet_state_a_or_b = false
		if player.g_tickle_accumulation < player.g_tickle_threshold:             # == 0 
			e_current_state = GOTO_STATES.GOTO_DEFAULT

		elif player.g_tickle_accumulation > e_max_pet_semi_accumulation:      # > 19000
			e_current_state = GOTO_STATES.GOTO_DECAY

		elif player.g_tickle_accumulation > e_min_iloveu_accumulation:      # > 79222 
			e_current_state = GOTO_STATES.GOTO_PET_SEMI
			
		else:
			e_current_state = GOTO_STATES.GOTO_DEFAULT
			
		# decay whenever no click is happening
		if player.g_tickle_accumulation > delta:
			player.g_tickle_accumulation -= e_decay * delta

	####################################################################
	
	# play na natin ang animation
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT:
			player.animation_sprite.play("sitting_default")
			# player.g_tickle_accumulation = 0

		GOTO_STATES.GOTO_DECAY:
			player.animation_sprite.play_backwards("sitting_transition")
			#player.g_tickle_accumulation = e_max_pet_semi_accumulation

		GOTO_STATES.GOTO_TRANSITION:
			player.animation_sprite.play("sitting_transition")
			#player.g_tickle_accumulation = e_max_pet_semi_accumulation

		GOTO_STATES.GOTO_PET_SEMI:
			player.animation_sprite.play("sitting_semi_pet")
			#player.g_tickle_accumulation = e_max_pet_semi_accumulation

		GOTO_STATES.GOTO_PET_A:
			player.animation_sprite.play("sitting_petting_A")
			#player.g_tickle_accumulation = e_min_iloveu_accumulation

		GOTO_STATES.GOTO_PET_B:
			player.animation_sprite.play("sitting_petting_B")
			#player.g_tickle_accumulation = e_min_iloveu_accumulation
			
	############################################################################
	
	print("accum: " + str(player.g_tickle_accumulation).pad_decimals(3) 
			+ "\t\tcurrent accum: " + str(Input.get_last_mouse_velocity().length()).pad_decimals(3) 
			+ "\t\ttimeleft tillazy: " + str(e_time_left_till_azy).pad_decimals(3)
			+ "\t\tazy pos: " + str(player.azy_animation_sprite.position)
			+ "\t\tstate: " + str(e_current_state))

""" # previous update
func update(delta: float) -> void:
	######################################
	## tickle
	######################################
	if player.g_tickle_accumulation < e_max_tickle_accumulation:
		player.g_tickle_accumulation += Input.get_last_mouse_velocity().length()
	
	if Input.get_last_mouse_velocity().length() < player.g_tickle_threshold:
		e_current_state = GOTO_STATES.GOTO_DECAY
	else:
		e_current_state = GOTO_STATES.GOTO_TRANSITION
	
	# process the decay
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT:
			player.animation_sprite.play("sitting_default")
			# always set it here
			player.g_tickle_accumulation = e_max_tickle_accumulation; 
			
			# set here to invoke the single run for starting the timer
			player.local_timer.stop()
			
			
		GOTO_STATES.GOTO_DECAY:
			_invoke_start_timer(player.local_timer, 0.4);
			if player.local_timer.time_left <= 0.1:
				player.local_timer.start(0.09); # to get the continuous
				player.g_tickle_accumulation *= e_decay;
				player.animation_sprite.play_backwards("sitting_transition")
			
			# go back to default once the accumulation keeps descending
			if player.g_tickle_accumulation <= 1.0:
				e_current_state = GOTO_STATES.GOTO_DEFAULT
				#player._change_state(load("res://scripts/player/states/petHoldState.gd").new())
				
				
		GOTO_STATES.GOTO_TRANSITION:
			player.animation_sprite.play("sitting_transition")
		
		
		GOTO_STATES.GOTO_PET_SEMI:
			# logic of the tickling
			player.animation_sprite.play("sitting_semi_pet")
			
			if player.g_tickle_accumulation > e_max_tickle_accumulation:
				e_current_state = _pet_a_or_b()
			
		
		GOTO_STATES.GOTO_PET_A:
			player.animation_sprite.play("sitting_petting_A")
			


		GOTO_STATES.GOTO_PET_B:
			player.animation_sprite.play("sitting_petting_B")
			
			# proceed to decay once we descend further than e_max_tickle_accumu
			if player.g_tickle_accumulation < e_max_tickle_accumulation:
				e_current_state = GOTO_STATES.GOTO_DECAY
"""



""" # lmao 
extends PlayerState

# --- ENUMS & CONSTANTS ---
enum GOTO_STATES {
	GOTO_DEFAULT,
	GOTO_DECAY,
	GOTO_TRANSITION,
	GOTO_PET_SEMI,
	GOTO_PET_A,
	GOTO_PET_B,
}

const e_decay: float = 0.5
const e_max_tickle_accumulation: float = 19000
const e_max_pet_accumulation: float = 79222

# --- STATE VARIABLES ---
var e_current_state: GOTO_STATES = GOTO_STATES.GOTO_DEFAULT
var e_orig_scale: Vector2 = Vector2(0.195, 0.195)

# --- STATE ENTRY/EXIT ---
func enter() -> void:
	player.collision_sitting.disabled = false
	_play_anim_once("sitting_default")

func exit() -> void:
	player.collision_sitting.disabled = true
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()

# --- STATE UPDATE LOOP ---
func update(delta: float) -> void:
	var mouse_speed = Input.get_last_mouse_velocity().length()

	# Always increase tickle accumulation
	if player.g_tickle_accumulation < e_max_tickle_accumulation:
		player.g_tickle_accumulation += mouse_speed

	# Only allow re-evaluation of state if not in petting state
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT, GOTO_STATES.GOTO_DECAY, GOTO_STATES.GOTO_TRANSITION:
			if mouse_speed < player.g_tickle_threshold:
				e_current_state = GOTO_STATES.GOTO_DECAY
			else:
				e_current_state = GOTO_STATES.GOTO_TRANSITION

	# Process the current state
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT:
			_play_anim_once("sitting_default")
			player.g_tickle_accumulation = e_max_tickle_accumulation
			player.local_timer.stop()

		GOTO_STATES.GOTO_DECAY:
			_invoke_start_timer(player.local_timer, 0.4)
			if player.local_timer.time_left <= 0.1:
				player.local_timer.start(0.09)
				player.g_tickle_accumulation *= e_decay
				player.animation_sprite.play_backwards("sitting_transition")

			if player.g_tickle_accumulation <= 1.0:
				e_current_state = GOTO_STATES.GOTO_DEFAULT

		GOTO_STATES.GOTO_TRANSITION:
			_play_anim_once("sitting_transition")

		GOTO_STATES.GOTO_PET_SEMI:
			_play_anim_once("sitting_semi_pet")
			if player.g_tickle_accumulation > e_max_tickle_accumulation:
				e_current_state = _pet_a_or_b()

		GOTO_STATES.GOTO_PET_A:
			_play_anim_once("sitting_petting_A")

		GOTO_STATES.GOTO_PET_B:
			_play_anim_once("sitting_petting_B")
			if player.g_tickle_accumulation < e_max_tickle_accumulation:
				e_current_state = GOTO_STATES.GOTO_DECAY

# --- INPUT HANDLING ---
func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("\n=======\ngraabiingg dis fkr\n=======")
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())

# --- ANIMATION CALLBACKS ---
func on_animation_finished() -> void:
	if e_current_state == GOTO_STATES.GOTO_TRANSITION:
		e_current_state = GOTO_STATES.GOTO_PET_SEMI

func on_azy_animation_sprite_animation_finished() -> void:
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()

# --- HELPERS ---
func _pet_a_or_b() -> GOTO_STATES:
	return GOTO_STATES.GOTO_PET_A if randf() > 0.5 else GOTO_STATES.GOTO_PET_B

func _invoke_start_timer(timer: Timer, m_time_seconds: float) -> void:
	if timer.is_stopped():
		timer.start(m_time_seconds)

func _play_anim_once(anim_name: String) -> void:
	if player.animation_sprite.animation != anim_name or !player.animation_sprite.is_playing():
		player.animation_sprite.play(anim_name)
	
	print
"""
