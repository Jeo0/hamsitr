# res://player/states/RollingState.gd
extends PlayerState
@export var e_number_of_rolling: int = 3
# @export var e_scale_of_rolling: float = 0.981
@export var e_scale_of_rolling: float = 0.7
var e_random: float = 0.7

var remaining_frames: int

func exit() -> void:
	player.coll_area_rolling.monitoring = false
	player.coll_area_rolling.input_pickable = false
	player.collision_rolling.disabled = true
	

func enter() -> void:
	
	player.animation_sprite.play("intro_rolling")
	player.coll_area_rolling.monitoring = true 
	player.coll_area_rolling.input_pickable = true
	player.collision_rolling.disabled = false
	
	remaining_frames = e_number_of_rolling * player.animation_sprite.sprite_frames.get_frame_count("intro_rolling")
	player.scale *= e_scale_of_rolling

func on_animation_frame_changed():
	remaining_frames -= 1
	# player.scale *= e_scale_of_rolling
	if remaining_frames <= 0:
		player._change_state(load("res://scripts/player/states/idlingState.gd").new())

func physics_update(delta: float) -> void:
	player.position.y -= player.WALK_SPEED * delta * (e_scale_of_rolling * e_random);
	player.move_and_slide()
