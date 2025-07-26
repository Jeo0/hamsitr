extends PlayerState


func enter() -> void:
	player.collision_idle.disabled = true
	player.collision_grabbing.disabled = false
	player.animation_sprite.play("grabbing")
	
func exit() -> void:
	player.collision_idle.disabled = false
	player.collision_grabbing.disabled = true
	print("exiting grabbing")
	
func update(delta: float)  -> void:
	if e_rclick_is_pressed == true:
		var target_position = player.get_global_mouse_position() + grab_offset
		player.velocity = (target_position - player.position) / delta
		player.position = target_position
		
		"""
		player.position = player.get_global_mouse_position()
		player.velocity = Input.get_last_mouse_velocity()
	print("position: " + str(player.position)
		+ "\t\tmousepos: " + str(player.get_local_mouse_position())
		)
		"""
	
	
func physics_update(delta: float) -> void:
	pass
	# if velocity is somehow zero,
	# & rclick is not held down
	# change state
	
	# else if velocity is not zero
	# rclick is released:
	# slow down 
	
	# if rclick is held down:
	# player.position = get_global
	# and the velocity
	
	if player.velocity.length() <= 0.01:
		if e_rclick_is_pressed == false: 
			player._change_state(load("res://scripts/player/states/idlingState.gd").new())
			
	elif player.velocity.length() and e_rclick_is_pressed == false: 
		# slow down, not good
		# player.velocity.x = lerp(player.velocity.x, player.velocity.x * player.velocity.length() * 0.2, delta * 1.4)
		# player.velocity.y = lerp(player.velocity.y, player.velocity.y * player.velocity.length() * 0.2, delta * 1.4)
		
		# slow down correctly
		player.velocity = player.velocity.lerp(Vector2.ZERO, delta * 4)
		
		
	player.move_and_slide()
	
	
	
# var e_rclick_is_pressed: bool = true
var e_rclick_is_pressed: bool = true
var grab_offset := Vector2.ZERO

func handle_input(event) -> void:
	if Input.is_action_just_pressed("rclick"):
		e_rclick_is_pressed = true
		grab_offset = player.position - player.get_global_mouse_position()
	elif Input.is_action_just_released("rclick"):
		e_rclick_is_pressed = false
