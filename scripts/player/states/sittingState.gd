extends PlayerState

func exit() -> void:
	player.collision_sitting.disabled = true;
	#player.azy_animation_sprite.hide()
	#player.azy_animation_sprite.stop()

func enter() -> void:
	player.collision_sitting.disabled = false;
	player.animation_sprite.play("sitting_default")
	
var e_current_state: GOTO_STATES = GOTO_STATES.GOTO_DEFAULT
const e_decay: float = 0.5;
const e_max_tickle_accumulation: float = 19000;
const e_max_pet_accumulation: float = 79222;

var e_orig_scale: Vector2 = Vector2(0.195, 0.195)

enum GOTO_STATES{
	GOTO_DEFAULT,
	GOTO_DECAY,
	GOTO_TRANSITION,
	GOTO_PET_SEMI,
	GOTO_PET_A,
	GOTO_PET_B,
}
func update(delta: float) -> void:
	# Tickle accumulation always grows with velocity
	if player.g_tickle_accumulation < e_max_tickle_accumulation:
		player.g_tickle_accumulation += Input.get_last_mouse_velocity().length()

	var mouse_speed = Input.get_last_mouse_velocity().length()

	print("accum: " + str(player.g_tickle_accumulation).pad_decimals(3)
			+ "\t\ttimeleft: " + str(player.local_timer.time_left).pad_decimals(3)
			+ "\t\tcurrent accum: " + str(Input.get_last_mouse_velocity().length()).pad_decimals(3)
			+ "\t\tstate: giggle")
			
	# Allow state transition logic only if not in a PET state
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT, GOTO_STATES.GOTO_DECAY, GOTO_STATES.GOTO_TRANSITION:
			if mouse_speed < player.g_tickle_threshold:
				e_current_state = GOTO_STATES.GOTO_DECAY
			else:
				e_current_state = GOTO_STATES.GOTO_TRANSITION

	# Process current state
	match e_current_state:
		GOTO_STATES.GOTO_DEFAULT:
			player.animation_sprite.play("sitting_default")
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
			player.animation_sprite.play("sitting_transition")

		GOTO_STATES.GOTO_PET_SEMI:
			player.animation_sprite.play("sitting_semi_pet")
			if player.g_tickle_accumulation > e_max_tickle_accumulation:
				e_current_state = _pet_a_or_b()

		GOTO_STATES.GOTO_PET_A:
			player.animation_sprite.play("sitting_petting_A")

		GOTO_STATES.GOTO_PET_B:
			player.animation_sprite.play("sitting_petting_B")
			if player.g_tickle_accumulation < e_max_tickle_accumulation:
				e_current_state = GOTO_STATES.GOTO_DECAY

"""
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

func _pet_a_or_b() -> GOTO_STATES:
	if randf() > 0.5: # 50.001% up to 100%
		return GOTO_STATES.GOTO_PET_A
	return GOTO_STATES.GOTO_PET_B
	
	
func _invoke_start_timer(timer, m_time_seconds) -> void:
	if timer.is_stopped() == true: 
		timer.start(m_time_seconds)
		

func handle_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("\n=======\ngraabiingg dis fkr\n=======");
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())

	
	
func on_animation_finished() -> void:
	# after animation finished on transition
	# proceed to set current state to semi
	if e_current_state == GOTO_STATES.GOTO_TRANSITION:
		e_current_state = GOTO_STATES.GOTO_PET_SEMI
	
	
func on_azy_animation_sprite_animation_finished() -> void:
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()
	pass
	
	
	
	
	
