# res://player/states/PlayerState.gd
extends Node

class_name PlayerState

var player: CharacterBody2D

func enter(): pass
func exit(): pass
func update(delta): pass
func physics_update(delta): pass
func handle_input(event): pass
func on_animation_finished(): pass
func on_animation_frame_changed(): pass
func on_state_timer_timeout(): pass
func on_local_timer_timeout(): pass
func on_azy_timer_timeout(): pass
func on_azy_animation_sprite_animation_finished(): pass
func on_azy_animation_sprite_animation_looped(): pass
func on_collision_area_input_event(viewport, event, shape_idx): pass
func on_coll_area_mouse_entered(): pass
