# res://player/states/RollingState.gd
extends PlayerState
@export var e_number_of_rolling: int = 3
# @export var e_scale_of_rolling: float = 0.981
@export var e_scale_of_rolling: float = 0.7
var e_random: float = 0.7

var remaining_frames: int

func enter():
	
	# print("number of rolling frames: " + str(player.animation_sprite.sprite_frames.get_frame_count("intro_rolling")))
	remaining_frames = e_number_of_rolling * player.animation_sprite.sprite_frames.get_frame_count("intro_rolling")
	player.animation_sprite.play("intro_rolling")
	player.collision_greetings.disabled = true
	player.collision_rolling.disabled = false
	player.collision_idle.disabled = true
	player.scale *= e_scale_of_rolling

func on_animation_frame_changed():
	remaining_frames -= 1
	# player.scale *= e_scale_of_rolling
	if remaining_frames <= 0:
		player._change_state(load("res://scripts/player/states/idlingState.gd").new())

func physics_update(delta: float) -> void:
	"""
	if !player.is_on_floor():
		player.velocity += player.get_gravity() * delta;
	"""
	player.position.y -= player.WALK_SPEED * delta * (e_scale_of_rolling * e_random);
	player.move_and_slide()
