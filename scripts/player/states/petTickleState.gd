extends PlayerState

func exit() -> void:
	player.coll_area_petting.monitoring = false
	player.coll_area_petting.input_pickable = false
	player.collision_petting.disabled = true;
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()

func enter() -> void:
	player.coll_area_petting.monitoring = true
	player.coll_area_petting.input_pickable = true
	player.collision_petting.disabled = false;
	
	player.animation_sprite.play("petting_tickling")
	
	
	

var e_current_state: GOTO_STATES = GOTO_STATES.GOTO_GIGGLE
const e_decay: float = 0.5;
const e_max_tickle_accumulation: float = 8000;

var e_min_azy_start_time: float = 2.5
var e_max_azy_start_time: float = 5.0
var e_bool_azy_animation_finished: bool = true # see NOTE_ID: azymessage1
var e_azy_timer: float = randf_range(e_min_azy_start_time, e_max_azy_start_time)
var e_azyanimation_decision: float = randf()

var e_orig_scale: Vector2 = Vector2(0.195, 0.195)

enum GOTO_STATES{
	GOTO_DECAY,
	GOTO_GIGGLE
}

func update(delta: float) -> void:
	######################################
	## azy message particles
	######################################
	# NOTE_ID: azymessage1
	# first this, because if the other branch is checked first,
	# setting the e_bool_azy_animation_finished to FALSE
	# will play the animation at the start of the frame
	if e_bool_azy_animation_finished == false:
		# player.scale *= 1.00001 # not working properly
		player.azy_animation_sprite.show()
		
		# play random
		if e_azyanimation_decision < 0.5: 
			player.azy_animation_sprite.play("heart")
		elif e_azyanimation_decision >= 0.5:
			player.azy_animation_sprite.play("stupid")
			
	# check if current time is less than 0.1 (i.e.: 	0 	< 	0.1	)
	# happening ONCE every 2.5 to 8 seconds
	elif e_azy_timer < delta:
		# reset timer to 4 or random, and hide it 
		e_azy_timer = randf_range(e_min_azy_start_time, e_max_azy_start_time)
		player.azy_animation_sprite.hide()
		player.azy_animation_sprite.stop()
		e_azyanimation_decision = randf()
		
		# player.scale = e_orig_scale # not working properly
		
		# proceed to the other branch 
		# show the animation
		e_bool_azy_animation_finished = false
	e_azy_timer -= delta
	
	
	
	######################################
	## tickle
	######################################
	if player.g_tickle_accumulation < e_max_tickle_accumulation:
		player.g_tickle_accumulation += Input.get_last_mouse_velocity().length()
	
	if Input.get_last_mouse_velocity().length() < player.g_tickle_threshold:
		e_current_state = GOTO_STATES.GOTO_DECAY
	else:
		e_current_state = GOTO_STATES.GOTO_GIGGLE
	
	# process the decay
	match e_current_state:
		GOTO_STATES.GOTO_GIGGLE:
			# always set it here
			player.g_tickle_accumulation = e_max_tickle_accumulation; 
			
			# set here to invoke the single run for starting the timer
			player.local_timer.stop()
			
			"""
			print("accum: " + str(player.g_tickle_accumulation).pad_decimals(3)
					+ "\t\ttimeleft: " + str(player.local_timer.time_left).pad_decimals(3)
					+ "\t\tcurrent accum: " + str(Input.get_last_mouse_velocity().length()).pad_decimals(3)
					+ "\t\tazytimer: " + str(e_azy_timer).pad_decimals(3)
					+ "\t\tstate: giggle")
			"""
			
		GOTO_STATES.GOTO_DECAY:
			
			_invoke_start_timer(player.local_timer, 0.4);
			if player.local_timer.time_left <= 0.1:
				player.local_timer.start(0.09); # to get the continuous
				player.g_tickle_accumulation *= e_decay;
			
			if player.g_tickle_accumulation <= 1.0:
				player._change_state(load("res://scripts/player/states/petHoldState.gd").new())
				
			"""
			print("accum: " + str(player.g_tickle_accumulation).pad_decimals(3)
					+ "\t\ttimeleft: " + str(player.local_timer.time_left).pad_decimals(3)
					+ "\t\tcurrent accum: " + str(Input.get_last_mouse_velocity().length()).pad_decimals(3)
					+ "\t\tazytimer: " + str(e_azy_timer).pad_decimals(3)
					+ "\t\tstate: decay")
			"""


	
func _invoke_start_timer(timer, m_time_seconds) -> void:
	if timer.is_stopped() == true: 
		timer.start(m_time_seconds)

func handle_input(event) -> void:
	if Input.is_action_just_released("click"):
		player._change_state(load("res://scripts/player/states/petNoHoldAwaitPetState.gd").new())
	
	""" CONTEXT: handle the sitting """
	if Input.is_action_just_pressed("spice"):
		player._change_state(load("res://scripts/player/states/sittingState.gd").new())


func on_local_timer_timeout() -> void:
	# player._change_state(load("res://scripts/player/states/idlingState.gd").new())
	pass
	
func on_azy_animation_sprite_animation_finished() -> void:
	# _invoke_start_timer(player.azy_timer, randf_range(e_min_azy_start_time, e_max_azy_start_time))
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()
	pass
	
func on_azy_animation_sprite_animation_looped(): 
	e_bool_azy_animation_finished = true
	# print("\n\n=================done====================")
	player.azy_animation_sprite.hide()
	player.azy_animation_sprite.stop()
	
	
	
	
