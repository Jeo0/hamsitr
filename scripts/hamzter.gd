extends CharacterBody2D

const g_walkSpeed: float = 500.0
const g_near_proximity_distance: float = 500


@onready var animation_sprite: AnimatedSprite2D = $animationSprite

@onready var collision_greetings: CollisionShape2D = $collision_greetings
@onready var collision_rolling: CollisionShape2D = $collision_rolling
@onready var collision_idle: CollisionShape2D = $collision_idle

enum g_stateMachine {
	GREETINGS,
	ROLLING,
	IDLING
}
var g_currentStateMachine = g_stateMachine.GREETINGS
var default_rolling_remaining: int = 3  * 6 # animation_sprite.sprite_frames.get_frame_count("intro_rolling")# animation_sprite.get_frame 
var g_rolling_remaining: int = default_rolling_remaining

			
func _ready() -> void:
	# self.show()
	g_currentStateMachine = g_stateMachine.GREETINGS
	_play_animation(null)
	
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		# velocity += get_gravity() * delta
		pass
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# involves inertia
		var direction = (get_local_mouse_position() - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, direction.x * g_walkSpeed, delta * 1.2)
		velocity.y = lerp(velocity.y, direction.y * g_walkSpeed, delta * 1.2) 
		# slow down if near
		if _is_near():
			# bigger constant = faster the stop
			velocity *= delta * 50
		
		"""
		# using math, but failed
		var xy_oy = get_local_mouse_position().y - get_global_transform().origin.y
		var xx_ox = get_local_mouse_position().x - get_global_transform().origin.x
		var direction = 1 / tan(deg_to_rad(xy_oy / xx_ox))
		# using math
		# do not use
		velocity.x += direction * SPEED
		velocity.y += direction * SPEED
		
		# or use this
		# robotic movement
		# velocity = (get_local_mouse_position() - global_transform.origin).normalized() * g_walkSpeed 
		"""
	
	# after rightclick and greet:
	# roll
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if g_currentStateMachine != g_stateMachine.ROLLING:
			print("set statemachine to rolling")
			g_currentStateMachine = g_stateMachine.ROLLING
			_play_animation(null)
			
		
		print("g_Rolling remaining: " + str(g_rolling_remaining))
		"""
		if g_rolling_remaining == 0:
			g_currentStateMachine = g_stateMachine.IDLING;
			_play_animation(null)
		"""
			
	move_and_slide()
	

func _is_near():
	var distance = (get_local_mouse_position() - global_transform.origin).length()
	return bool(distance <= g_near_proximity_distance)


func _play_animation(m_arg):
	# DO NOT SET the g_currentStateMachine here
	# do it in 
	match g_currentStateMachine:
		g_stateMachine.GREETINGS:
			print("playing greetings")
			animation_sprite.show()
			animation_sprite.frame = 0
			animation_sprite.play("intro_greetings1")
			
			""" # not working 
			collision_rolling.set_process(false) 
			collision_idle.set_process(false)
			collision_rolling.hide()
			collision_idle.hide()
			"""
			collision_rolling.disabled = true
			collision_idle.disabled = true
			
			
		g_stateMachine.ROLLING:
			print("playing rolling")
			if g_rolling_remaining:
				animation_sprite.frame = 0
				animation_sprite.play("intro_rolling")
				
				""" # not working 
				collision_greetings.set_process(false)
				collision_rolling.set_process(true)
				collision_greetings.hide()
				collision_rolling.show()
				"""
				collision_greetings.disabled = true
				collision_rolling.disabled = false
				
				
		g_stateMachine.IDLING:
			print("playing idling")
			# after end rolling, proceed idle
			animation_sprite.frame = 0
			animation_sprite.play("idling")
			
			""" # not working 
			collision_rolling.set_process(false)
			collision_idle.set_process(true)
			collision_rolling.hide()
			collision_idle.show()
			"""
			collision_rolling.disabled = true 
			collision_idle.disabled = false


func _on_animation_sprite_animation_finished() -> void:
	print("=========animation finished")
	pass # Replace with function body.


func _on_animation_sprite_animation_looped() -> void:
	print("=========animationloop")
	pass


func _on_animation_sprite_frame_changed() -> void:
	# print("==========sprite frame change")
	# print("current statemachine: " + str(g_stateMachine.get()))
	
	# RULE: "pass" if the logic is handled elsewhere
	# only change the g_currentStateMachine here
	# if you need to loop
	match g_currentStateMachine:
		g_stateMachine.GREETINGS:
			pass
				
		g_stateMachine.ROLLING:
			print("im being played")
			if g_rolling_remaining:
				g_rolling_remaining -= 1
			else:
				g_rolling_remaining = default_rolling_remaining # reset
				g_currentStateMachine = g_stateMachine.IDLING
				
		g_stateMachine.IDLING:
			# print("status: idle")
			pass
