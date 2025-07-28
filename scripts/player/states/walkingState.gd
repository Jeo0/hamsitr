extends PlayerState

func enter():
	player.animation_sprite.play("walking_normal")
	
	player.coll_area_walking.monitoring = true
	player.coll_area_walking.input_pickable = true
	player.collision_walking.disabled = false
	
	_determine_where_to_go_next()
	# sprite_2d.position = e_place_going

func exit():
	player.coll_area_walking.monitoring = false
	player.coll_area_walking.input_pickable = false
	player.collision_walking.disabled = true
	
func handle_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player._change_state(load("res://scripts/player/states/petHoldState.gd").new())
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		player._change_state(load("res://scripts/player/states/grabbingState.gd").new())
		

func update(delta) -> void:
	# if player is not near the dest, set velocity towards that direction
	if _check_player_arrived_to_destination():
		player.velocity.x = lerp(player.velocity.x, e_direction_going.x * e_walking_speed, delta * 1.2)
		player.velocity.y = lerp(player.velocity.y, e_direction_going.y * e_walking_speed, delta * 1.2) 
		
	else:
		
		# else proceed with slowing down first 
		if player.velocity.length() >= 0.5:
			player.velocity.x = lerp(player.velocity.x, e_direction_going.x * player.velocity.length(), delta * 2.4)
			player.velocity.y = lerp(player.velocity.y, e_direction_going.y * player.velocity.length(), delta * 2.4)
		# then change the state
		else: 
			player._change_state(load("res://scripts/player/states/idlingState.gd").new())
			
	# retry the direction calculation 
	e_direction_going = Vector2(e_place_going - player.get_transform().origin).normalized()
	
	# set the animation speed with respect to the velocity
	player.animation_sprite.speed_scale = lerpf(0.5, 1.0, player.velocity.length() * delta)
	
	player.move_and_slide()
	
	var m_current_place: Vector2 = player.get_transform().origin
	var m_current_error: float = abs(e_place_going-m_current_place).x \
								+ abs(e_place_going-m_current_place).y
	"""
	print("whereto_loc: (" + str(e_place_going.x).pad_decimals(3)
		+ ", "				+ str(e_place_going.y).pad_decimals(3)
		+ ")\t\tcurrent_loc: (" + str(m_current_place.x).pad_decimals(3)
		+ ", "				+ str(m_current_place.y).pad_decimals(3)
		+ ")\t\tdist_error: " + str(m_current_error).pad_decimals(3)
		+ "\t\tvelocity: " + str(player.velocity.length()).pad_decimals(3)
		+ "\t\tani_speed: " + str(player.animation_sprite.speed_scale).pad_decimals(3))
	"""
const e_collision_offset: float = 400;
const e_max_error_allowable: float = 100;
var e_place_going: Vector2
var e_direction_going: Vector2
var e_is_walking: bool = false
const e_walking_speed: float = 100

func _determine_where_to_go_next() -> void:
	var m_place_to_go_next: Vector2 = Vector2(randf_range(0 + e_collision_offset,
			player.get_viewport_rect().size.x - e_collision_offset),
			randf_range(0+e_collision_offset, player.get_viewport().size.y - e_collision_offset) )
	"""
	var m_place_to_go_next: Vector2 = Vector2(randf_range(0, player.get_viewport_rect().size.x),
											randf_range(0, player.get_viewport().size.y) )
	"""
	e_place_going = m_place_to_go_next
	e_direction_going = Vector2(e_place_going - player.get_transform().origin).normalized()
	
	
func _check_player_arrived_to_destination() -> bool:
	var m_current_place: Vector2 = player.get_transform().origin
	var m_current_error: float = abs(e_place_going-m_current_place).x \
								+ abs(e_place_going-m_current_place).y
	if m_current_error <= e_max_error_allowable:
			return false
	return true
