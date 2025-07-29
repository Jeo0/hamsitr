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
const e_max_tickle_accumulation: float = 8000;
const e_max_pet_accumulation: float = 79222;

var e_orig_scale: Vector2 = Vector2(0.195, 0.195)

enum GOTO_STATES{
	GOTO_DEFAULT,
	GOTO_DECAY,
	GOTO_TRANSITION,
	GOTO_PET_A,
	GOTO_PET_B,
}

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
			
			if player.g_tickle_accumulation <= 1.0:
				e_current_state = GOTO_STATES.GOTO_TRANSITION
				#player._change_state(load("res://scripts/player/states/petHoldState.gd").new())
				
		GOTO_STATES.GOTO_TRANSITION:
			pass
		
		GOTO_STATES.GOTO_PET_A:
			pass

		GOTO_STATES.GOTO_PET_B:
			pass

	
func _invoke_start_timer(timer, m_time_seconds) -> void:
	if timer.is_stopped() == true: 
		timer.start(m_time_seconds)

func handle_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("\n=======\ngraabiingg dis fkr\n=======");
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())

	
	
func on_azy_animation_sprite_animation_finished() -> void:
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()
	pass
	
	
	
	
	
