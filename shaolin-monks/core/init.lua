function _init()
  define_global_constants()
  define_global_variables()
  actions = define_actions()
  characters = define_characters()
  define_player(p1_id)
  define_player(p2_id)
end

function define_global_constants()
  action_stack_timeout, backward, debug, flinch_speed, forward, frozen_body_pal_map, frozen_head_pal_map, jump_speed, map_min_x, map_max_x, p1_id, p2_id, projectile_speed, round_duration, sprite_h, sprite_w, stage_offset, swept_speed, walk_speed, x_shift, y_bottom_limit, y_shift, y_upper_limit = 6, -1, {}, 4, 1, "p0c1c2c3c4c5c6c7c8c9cacbcdcecfc", "p0c1c2c374c5c6c8c9cacbcdcecfc", 2, 1, 126, 0, 1, 3, 90, 8, 8, 16, 3, 1, 3, 127 - 36, 2, 127 - 36 - 28
  actions_map, timers = string_to_hash(
    "⬅️,➡️,⬆️,⬇️,➡️⬆️,⬅️⬆️,➡️⬇️,⬅️⬇️,🅾️,⬅️🅾️,➡️🅾️,⬆️🅾️,⬇️🅾️,⬅️⬆️🅾️,➡️⬆️🅾️,❎,⬅️❎,➡️❎,⬆️❎,⬇️❎,⬅️⬆️❎,➡️⬆️❎,🅾️❎,⬅️🅾️❎,➡️🅾️❎,⬇️🅾️❎",
    "1|walk,1|walk,1|jump,1|crouch,1|jump,1|jump,1|crouch,1|crouch,2|punch,2|punch,2|punch,2|flying_punch,2|hook,2|flying_punch,2|flying_punch,2|kick,2|roundhouse_kick,2|kick,2|flying_kick,2|sweep,2|flying_kick,2|flying_kick,1|block,1|block,1|block,1|block"
  ), string_to_hash("finishing_move,new_player,round_end,round_start", "90,60,60,60")
end

function define_global_variables()
  current_screen, p1, p2 = "start", {}, {}
  define_combat_variables()
end

function define_characters()
  local characters, special_attacks, c_attr_list, sa_attr_list, c_attr_keys = {}, {}, split(
    [[lk,2,p1f2838485f9fa0b0c0d0e8,1,p3050,#64|65|66|67|68|69|68,2,4,nil,#48|49|50|51|50|49;kl,3,p1f2030405f9fa8b8c1d8e0,1,p305085,#70|71|72|73|70|70|74,2,2,p50d5,#58|59|60|61|60|59;jc,13,p1f203f415f91a0b1c0d1e1,1,p305084,#75|76|77|78|75|75|75,2,4,p839bab7b,#48|49|50|51|50|49;rp,4,p1f23435f839fa0b0c0d0e3,1,p13243a508398,#79|80|81|82|79|79|102,2,4,p839bab7b,#48|49|50|51|50|49;sz,1,p1f2c3c4c5f8c9fa0b0c0d0ec,1,p30508c,#79|80|81|82|79|79|79,2,4,p879cac,#48|49|50|51|50|49;st,8,p1f203f455f9fb5c0daef,1,p305085,#83|84|85|86|83|83|83,2,4,nil,#48|49|50|51|50|49;kn,12,p21314151819fa0b0cfd0e1,2,p305081,#87|88|89|90|87|87|87,2,5,nil,#52|53|54|55|54|53;jx,14,p142834485495a6b6c0d6e4f4,1,p305085f4,#91|92|93|94|91|91|91,2,4,p829ea7,#48|49|50|51|50|49;ml,13,p12324252829fa0b0cfd0e2,2,p305082,#87|88|89|90|87|87|87,2,5,nil,#56;bk,14,p16203f485f869fa7b8c0d7ef,1,nil,#95|96|97|98|95|95|95,2,4,p8d96a6,#48|49|50|51|50|49;sc,2,p1f2a3a4a5f8a9fa0b0c0d0ea,1,p508a,#79|80|81|82|79|79|79,2,3,p50,#57;rd,1,p1f2c3c4c5f8d97a0b0c7d0ec,1,p8d,#99|100|100|101|99|99|99,2,4,p8c97a7,#48|49|50|51|50|49]], ";"
  ), split(
    [[fireball,20,4,*a2,false,false,*r1,➡️+➡️+🅾️,#18|$19/7,special_attack;flying_kick,20,4,*a5,false,false,*r2,➡️+➡️+❎,#12|$14/7,special_attack;bicycle_kick,20,4,*a6,false,false,*r2,h3❎,#$12/5|$31/1/0/1|$32/5/0/1|$33/6/0/1|$32/5/0/1|$31/1/0/1,special_attack@hat_toss,20,4,*a2,false,false,*r1,⬅️+➡️+🅾️,#$18/7|$20/7,special_attack@shadow_bolt,20,4,*a2,false,false,*r1,⬇️+➡️+🅾️,#18|$20/7,special_attack@acid_spit,20,4,*a2,false,false,*r1,➡️+➡️+🅾️,#29|$30/7,special_attack@freeze,0,4,*a2,false,false,*r4,⬇️+➡️+🅾️,#18|$20/7,special_attack@fire_skull,20,4,*a2,false,false,*r1,⬅️+⬅️+🅾️,#18|$19/7,special_attack@fan_throw,20,4,*a2,false,false,*r1,➡️+➡️+🅾️,#18|$20/7,special_attack@energy_wave,20,4,*a2,false,false,*r1,➡️+⬇️+⬅️+❎,#18|$20/7,special_attack@sai_throw,20,4,*a2,false,false,*r1,h2🅾️,#18|$19/7,special_attack@blade_spark,20,4,*a2,false,false,*r1,⬇️+⬅️+🅾️,#18|$20/7,special_attack@spear,20,4,*a2,false,false,*r1,⬅️+⬅️+🅾️,#18|$20/7,special_attack@lightning,20,4,*a2,false,false,*r1,⬇️+➡️+🅾️,#18|$19/7,special_attack]], "@"
  ), split "name,bg_color,body_pal_map,gender,head_pal_map,head_sprites,projectile_fps,projectile_h,projectile_pal_map,projectile_sprites"

  for i, c_attrs in ipairs(c_attr_list) do
    characters[i] = string_to_hash(c_attr_keys, split(c_attrs))
    characters[i].special_attacks = define_actions(sa_attr_list[i])
  end

  return characters
end

function define_actions(attr_list)
  local actions, attr_list, attr_keys = {}, split(
    attr_list or [[block,nil,2,nil,true,false,nil,nil,#10|11,other;crouch,nil,2,nil,true,false,nil,nil,#$4/1/0/1|$5/1/0/2,other;flinch,nil,6,*a3,false,false,nil,nil,#23,damage_reaction;flying_kick,10,3,*a1,false,false,*r2,nil,#$14/6,aerial_attack;flying_punch,10,3,*a1,false,false,*r1,nil,#$15/6,aerial_attack;get_up,nil,2,nil,false,false,nil,nil,#$5/1/0/2|$4/1/0/1,other;hook,100,3,*a1,false,true,*r2,nil,#$6/1/0/1|$7/2|$8/3|$8/3|$8/3|$8/3|$8/3|$7/2,punch_attack;idle,nil,1,nil,false,false,nil,nil,#0,other;jump,nil,2,nil,false,false,nil,nil,#$16/6/0/2|$17/4/2/1|$16/6/0/-2/true/true/true/true|$17/4/-2/-1/true/true/true/true,aerial;kick,10,4,*a1,false,true,*r1,nil,#$12/5|$13/6|$12/5,kick_attack;prone,nil,8,nil,false,false,nil,nil,#$22/4/-4/0/false/false/true/true,other;propelled,nil,3,nil,true,false,nil,nil,#$23/6/0/0|$24/4/-4/0/false/false/true/true,damage_reaction;punch,10,3,*a1,false,true,*r1,nil,#$7/2|$9/3|$7/2,punch_attack;roundhouse_kick,20,2,*a1,false,true,*r2,nil,#$7/2|$28/3/-1|$7/2/0/0/true/false/true/false|$12/5|$13/6|$13/6|$13/6|$12/5,kick_attack;sweep,10,2,*a1,false,true,*r3,nil,#$4/1/0/1|$25/2/0/1|$26/3/-1/1|$25/2/0/1/true/false/true/false|$27/1/0/1|$27/1/0/1|$4/1/0/1,kick_attack;swept,nil,4,nil,false,false,nil,nil,#$21/6/0/1,damage_reaction;walk,nil,4,*a4,false,false,nil,nil,#1|2|3|2,movement]], ";"
  ), split "name,dmg,fps,handler,is_holdable,is_x_shiftable,reaction_handler,sequence,sprites,type"

  for i, attrs in ipairs(attr_list) do
    attrs = split(attrs)
    actions[attrs[1]] = string_to_hash(attr_keys, attrs)
  end

  return actions
end

function define_player(id, p)
  local p = p or {}
  local next_combats = p.next_combats or split "1,2,3,4,5,6,7,8,9,10,11,12"

  for i = #next_combats, 2, -1 do
    local j = flr(rnd(i)) + 1
    next_combats[i], next_combats[j] = next_combats[j], next_combats[i]
  end

  local is_p1 = id == p1_id
  local p = string_to_hash(
    "action_stack,action_stack_timeout,character,current_action,current_action_params,current_action_state,facing,frames_counter,frozen_timer,has_joined,highlighted_char,hp,held_buttons,held_buttons_timer,id,input_detection_delay,is_orientation_locked,is_x_shifted,is_y_shifted,jump_acceleration,next_combats,particle_sets,previous_buttons,previous_directionals,projectile,released_buttons,x,y", { "", action_stack_timeout, p.character, actions.idle, {}, "in_progress", is_p1 and forward or backward, 0, 0, p.has_joined, is_p1 and 1 or 4, 100, nil, 0, id, 0, false, false, false, 0, next_combats, {}, nil, nil, nil, nil, is_p1 and 36 or 127 - 36 - sprite_w, y_bottom_limit }
  )

  if is_p1 then
    p1 = p
  else
    p2 = p
  end
end