function _init()
  define_global_variables()
  game = define_game()
  actions = define_actions()
  characters = define_characters()
  p1 = create_player(p1_id)
  p2 = create_player(p2_id)
end

function define_global_variables()
  action_stack_timeout = 6
  backward = -1
  debug = {}
  flinch_speed = 4
  forward = 1
  jump_speed = 2
  p1_id = 0
  p2_id = 1
  projectile_speed = 3
  round_duration = 90
  sprite_h = 8
  sprite_w = 7
  stage_offset = 16
  swept_speed = 3
  timers = {
    finishing_move = 90,
    new_player = 60,
    round_end = 60,
    round_start = 60
  }
  walk_speed = 1
  x_shift = 3
  y_bottom_limit = 127 - 36
  y_shift = 2
  y_upper_limit = 127 - 36 - 20
end

function define_game()
  return {
    current_combat = nil,
    current_screen = "start",
    joined_status = {
      [p1_id] = false,
      [p2_id] = false
    },
    next_combats = {
      [p1_id] = {},
      [p2_id] = {}
    }
  }
end

function define_characters()
  local characters, special_attacks, c_attr_list, sa_attr_list, c_attr_keys = {}, {}, split(
    [[lk,2,1f2838485f9fa0b0c0d0e8,1,50,#64|65|66|67|68|69|68,2,4,nil,#48|49|50|51|50|49;kl,3,1f2030405f9fa8b8c1d8e0,1,5085,#70|71|72|73|70|70|74,2,2,50d5,#58|59|60|61|60|59;jc,13,1f203f415f91a0b1c0d1e1,1,5084,#75|76|77|78|75|75|75,2,4,839bab7b,#48|49|50|51|50|49;rp,4,1f23435f839fa0b0c0d0e3,1,1324508398,#79|80|81|82|79|79|102,2,4,839bab7b,#48|49|50|51|50|49;sz,1,1f2c3c4c5f8c9fa0b0c0d0ec,1,508c,#79|80|81|82|79|79|79,2,4,879cac,#48|49|50|51|50|49;st,8,1f203f455f9fb5c0daef,1,5085,#83|84|85|86|83|83|83,2,4,nil,#48|49|50|51|50|49;kn,12,21314151819fa0b0cfd0e1,2,5081,#87|88|89|90|87|87|87,2,5,nil,#52|53|54|55|54|53;jx,14,142834485495a6b6c0d6e4f4,1,5085f4,#91|92|93|94|91|91|91,2,4,829ea7,#48|49|50|51|50|49;ml,13,12324252829fa0b0cfd0e2,2,5082,#87|88|89|90|87|87|87,2,5,nil,#56;bk,14,16203f485f869fa7b8c0d7ef,1,nil,#95|96|97|98|95|95|95,2,4,8d96a6,#48|49|50|51|50|49;sc,2,1f2a3a4a5f8a9fa0b0c0d0ea,1,508a,#79|80|81|82|79|79|79,2,3,50,#57;rd,1,1f2c3c4c5f8d97a0b0c7d0ec,1,8d,#99|100|100|101|99|99|99,2,4,8c97a7,#48|49|50|51|50|49]], ";"
  ), split(
    [[fireball,20,4,*a2,false,false,*r1,➡️➡️🅾️,#18|$19/7,special_attack@hat_toss,20,4,*a2,false,false,*r1,⬅️➡️🅾️,#18|20,special_attack@shadow_bolt,20,4,*a2,false,false,*r1,⬇️➡️🅾️,#18|$20/7,special_attack@acid_spit,20,4,*a2,false,false,*r1,➡️➡️🅾️,29|$30/7,special_attack@freeze,20,4,*a2,false,false,*r1,⬇️➡️🅾️,#18|$20/7,special_attack@fire_skull,20,4,*a2,false,false,*r1,⬅️⬅️🅾️,#18|$19/7,special_attack@fan_throw,20,4,*a2,false,false,*r1,➡️➡️🅾️,#18|$20/7,special_attack@energy_wave,20,4,*a2,false,false,*r1,➡️⬇️⬅️❎,#18|$20/7,special_attack@sai_throw,20,4,*a2,false,false,*r1,⬇️⬅️🅾️,#18|$19/7,special_attack@blade_spark,20,4,*a2,false,false,*r1,⬇️⬅️🅾️,#18|$20/7,special_attack@spear,20,4,*a2,false,false,*r1,⬅️⬅️🅾️,#18|$20/7,special_attack@lightning,20,4,*a2,false,false,*r1,⬇️➡️🅾️,#18|$19/7,special_attack]], "@"
  ), split "name,bg_color,body_pal_map,gender,head_pal_map,head_sprites,projectile_fps,projectile_h,projectile_pal_map,projectile_sprites"

  for i, c_attrs in ipairs(c_attr_list) do
    characters[i] = string_to_hash(c_attr_keys, split(c_attrs))
    characters[i].special_attacks = define_actions(sa_attr_list[i])
  end

  return characters
end

function define_actions(attr_list)
  local actions, attr_list, attr_keys = {}, split(
    attr_list or [[block,nil,2,nil,true,false,nil,nil,#10|11,other;crouch,nil,2,nil,true,false,nil,nil,#$4/1/0/1|$5/1/0/2,other;flinch,nil,6,*a3,false,false,nil,nil,#23,damage_reaction;flying_kick,10,3,*a1,false,false,*r2,nil,#$14/6,aerial_attack;flying_punch,10,3,*a1,false,false,*r1,nil,#$15/6,aerial_attack;get_up,nil,2,nil,false,false,nil,nil,#$5/1/0/2|$4/1/0/1,other;hook,100,3,*a1,false,true,*r2,nil,#$6/1/0/1|$7/2|$8/3|$8/3|$8/3|$8/3|$8/3|$7/2,attack;idle,nil,1,nil,false,false,nil,nil,#0,other;jump,nil,2,nil,false,false,nil,nil,#$16/6/0/2|$17/4/2/1|$16/6/0/-2/true/true/true/true|$17/4/-2/-1/true/true/true/true,aerial;kick,10,4,*a1,false,true,*r1,nil,#$12/5|$13/6|$12/5,attack;prone,nil,8,nil,false,false,nil,nil,#$22/4/-4/0/false/false/true/true,other;propelled,nil,3,nil,true,false,nil,nil,#$23/6/0/0|$24/4/-4/0/false/false/true/true,damage_reaction;punch,10,3,*a1,false,true,*r1,nil,#$7/2|$9/3|$7/2,attack;roundhouse_kick,20,2,*a1,false,true,*r2,nil,#$7/2|$28/3/-1|$7/2/0/0/true/false/true/false|$12/5|$13/6|$13/6|$13/6|$12/5,attack;sweep,10,2,*a1,false,true,*r3,nil,#$4/1/0/1|$25/2/0/1|$26/3/-1/1|$25/2/0/1/true/false/true/false|$27/1/0/1|$27/1/0/1|$4/1/0/1,attack;swept,nil,4,nil,false,false,nil,nil,#$21/6/0/1,damage_reaction;walk,nil,4,*a4,false,false,nil,nil,#1|2|3|2,movement]], ";"
  ), split "name,dmg,fps,handler,is_holdable,is_x_shiftable,reaction_handler,sequence,sprites,type"

  for i, attrs in ipairs(attr_list) do
    attrs = split(attrs)
    actions[attrs[1]] = string_to_hash(attr_keys, attrs)
  end

  return actions
end

function create_player(id, character)
  local is_p1 = id == p1_id

  return string_to_hash(
    "action_stack,action_stack_timeout,character,current_action,current_action_params,current_action_state,facing,frames_counter,highlighted_char,hp,id,is_orientation_locked,is_x_shifted,is_y_shifted,jump_acceleration,particle_sets,projectile,x,y", { "", action_stack_timeout, character, actions.idle, {}, "in_progress", is_p1 and forward or backward, 0, is_p1 and 1 or 4, 100, id, false, false, false, 0, {}, nil, is_p1 and 36 or 127 - 36 - sprite_w, y_bottom_limit }
  )
end