# res://scripts/player/states/grabbingState.gd
extends PlayerState


func enter() -> void:
	player.coll_area_grabbing.monitoring = true
	player.coll_area_grabbing.input_pickable = true
	player.collision_grabbing.disabled = false
	
	player.collision_default_grabbing.disabled = false
	player.animation_sprite.play("grabbing")
	
func exit() -> void:
	player.coll_area_grabbing.monitoring = false
	player.coll_area_grabbing.input_pickable = false
	player.collision_grabbing.disabled = true
	
	player.collision_default_grabbing.disabled = true
	
func update(delta: float)  -> void:
	pass
	
	
const MAX_GRAB_SPEED := 7000
const DEADZONE_DISTANCE := 4.0  # Snap if within 4 pixel
func physics_update(delta: float) -> void:
	if e_rclick_is_pressed == true:
		#var target_position = player.get_global_mouse_position() + grab_offset
		#player.velocity = (target_position - player.position) / delta
		#player.position = target_position # never set this position while also calling move_and_slide()
		var target_position = player.get_global_mouse_position() + grab_offset
		var delta_pos = target_position - player.position

		if delta_pos.length() <= DEADZONE_DISTANCE:
			player.velocity = Vector2.ZERO
			player.position = target_position  # snap safely if very close
		else:
			var speed = min(delta_pos.length() / delta, MAX_GRAB_SPEED)
			player.velocity = delta_pos.normalized() * speed
		
		"""
		player.position = player.get_global_mouse_position()
		player.velocity = Input.get_last_mouse_velocity()
	print("position: " + str(player.position)
		+ "\t\tmousepos: " + str(player.get_local_mouse_position())
		)
		"""
	
	elif e_rclick_is_pressed == false: 
		if player.velocity.length() <= 0.6:
			player._change_state(load("res://scripts/player/states/idlingState.gd").new())
			return # do not go through the next statements
			
		# else slow down, not good
		# player.velocity.x = lerp(player.velocity.x, player.velocity.x * player.velocity.length() * 0.2, delta * 1.4)
		# player.velocity.y = lerp(player.velocity.y, player.velocity.y * player.velocity.length() * 0.2, delta * 1.4)
		
		# slow down correctly
		player.velocity = player.velocity.lerp(Vector2.ZERO, delta * 4)
		
		
	player.move_and_slide()
	
	
	
var e_rclick_is_pressed: bool = true
var grab_offset := Vector2.ZERO
func handle_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			e_rclick_is_pressed = true
			grab_offset = player.position - player.get_global_mouse_position()
		else:
			e_rclick_is_pressed = false
			
	""" CONTEXT: handle the sitting """
	if Input.is_action_just_pressed("spice"):
		player._change_state(load("res://scripts/player/states/sittingState.gd").new())
		
	"""
	if Input.is_action_just_pressed("rclick"):
		e_rclick_is_pressed = true
		grab_offset = player.position - player.get_global_mouse_position()
	elif Input.is_action_just_released("rclick"):
		e_rclick_is_pressed = false
	"""



"""
func on_collision_area_input_event(viewport: Node, event, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
	if event is InputEventMouseButton and event.pressed and InputMap.event_is_action(event, "rclick"):
		player.cursor_changed = true
		e_rclick_is_pressed = true
		grab_offset = player.position - player.get_global_mouse_position()
	# elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
	elif event is InputEventMouseButton and not event.pressed and InputMap.event_is_action(event, "rclick"):
		player.cursor_changed = true
		e_rclick_is_pressed = false
"""
