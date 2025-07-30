func exit() -> void : 
  player.collision_sitting.disabled = true;
  #player.azy_animation_sprite.hide()
  #player.azy_animation_sprite.stop()

func enter() -> void : 
  player.collision_sitting.disabled = false; 
  player.animation_sprite.play("sitting_default")

enum GOTO_STATES {
  GOTO_DEFAULT,
  GOTO_DECAY,
  GOTO_TRANSITION,
  GOTO_PET_SEMI,
  GOTO_PET_A,
  GOTO_PET_B,
}
var e_orig_scale : Vector2 = Vector2(0.195, 0.195)

#player global variables
#g_tickle_threshold = 1300.0
#g_tickle_accumulation = 0.0

var e_current_state : GOTO_STATES = GOTO_STATES.GOTO_DEFAULT 

const e_decay : float = 0.5;
const e_max_pet_semi_accumulation : float = 19000;
const e_min_iloveu_accumulation : float = 79222;
const e_max_iloveu_accumulation : float = 500000; # 500k 
var e_go_factor : bool = false;


func update(delta) -> void : 
  """
  if click:
    if `current g_tickle_acum` is BIGGER_THAN `g_tickle_threshold`:     # 1300
      set state to transition 

    elif `current g_tickle_acum` is BIGGER_THAN `emax_pet_semi_acum`:     # 19000
      set state to pet semi

    elif `current g_tickle_acum` is BIGGER_THAN `e_min_iloveu_acum`:     # 79222
      set state to either peta or petb



    # always accumulate the mouse movemetn
		player.g_tickle_accumulation += Input.get_last_mouse_velocity().length()

    if player.g_tickle_accumulation >= e_max_iloveu_accumulation:   # 500k
      player.g_tickle_accumulation = e_max_iloveu_accumulation      # clamp it to 500k




  elif no click:
    if `current g_tickle_acum` is BIGGER_THAN `emin_iloveu acum`:     # 79222
      set state to semi pet
      

    elif `current g_tickle_acum` is BIGGER_THAN `emax_semi pet_acum`: # 19000
      set state to decay

    elif `current g_tickle_acum` is 0:
      set state to default


    # always decay whenever no click is happening
    current g_tickel_acum *= e_decay




  # play na natin ang animation
  match e_current_state:
    
		GOTO_STATES.GOTO_DEFAULT:
      player.animation_sprite.play("sitting_default")
			
			
		GOTO_STATES.GOTO_DECAY:
      player.animation_sprite.play_backwards("sitting_transition")
				

		GOTO_STATES.GOTO_TRANSITION:
      player.animation_sprite.play("sitting_transition")
		
		
		GOTO_STATES.GOTO_PET_SEMI:
      player.animation_sprite.play("sitting_semi_pet")
			
		
		GOTO_STATES.GOTO_PET_A:
			player.animation_sprite.play("sitting_petting_A")
			

		GOTO_STATES.GOTO_PET_B:
			player.animation_sprite.play("sitting_petting_B")

      

  """
