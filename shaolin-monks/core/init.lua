function _init()
  define_global_constants()
  define_global_variables()
  actions = define_actions()
  characters = define_characters()
  define_player(p1_id)
  define_player(p2_id)
end

function define_global_constants()
  action_stack_timeout, backward, debug, forward, frozen_body_pal_map, frozen_head_pal_map, jump_speed, map_min_x, map_max_x, p1_id, p2_id, offensive_speed, projectile_speed, round_duration, sprite_h, sprite_w, stage_offset, stroke_width, walk_speed, x_shift, y_bottom_limit, y_shift, y_upper_limit = 6, -1, {}, 1, "p0c1c2c3c4c5c6c7c8c9cacbcdcecfc", "p0c1c2c374c5c6c8c9cacbcdcecfc", 3, 1, 126, 0, 1, 4, 3, 90, 8, 8, 16, 2, 1, 3, 127 - 36, 2, 127 - 36 - 30
  ground_actions_map, aerial_actions_map, timers = string_to_hash("⬅️,➡️,⬆️,⬇️,➡️⬆️,⬅️⬆️,➡️⬇️,⬅️⬇️,🅾️,⬇️🅾️,❎,⬅️❎,⬇️❎,🅾️❎", "walk,walk,jump,crouch,jump,jump,crouch,crouch,punch,hook,kick,roundhouse_kick,sweep,block"), string_to_hash("🅾️,❎", "jump_punch,jump_kick"), string_to_hash("finishing_move,new_player,round_end,round_start", "90,60,60,60")
end

function define_global_variables()
  current_screen, p1, p2 = "start", {}, {}
  define_combat_variables()
end

function define_characters()
  local characters, c_attr_list, sa_attr_list, c_attr_keys = {}, split("lk,2,p1f2838485f9fa0b0c0d0e8,1,p3050,#64|65|66|67|68|69|68,2,4,nil,#48|49|50|51|50|49;kl,3,p1f2030405f9fa8b8c1d8e0,1,p305085,#70|71|72|73|70|70|74,2,2,p50d5,#58|59|60|61|60|59;jc,13,p1f203f415f91a0b1c0d1e1,1,p305084,#75|76|77|78|75|75|75,2,4,p839bab7b,#48|49|50|51|50|49;rp,4,p1f23435f839fa0b0c0d0e3,1,p13243a508398,#79|80|81|82|79|79|102,2,4,p839bab7b,#48|49|50|51|50|49;sz,1,p1f2c3c4c5f8c9fa0b0c0d0ec,1,p30508c,#79|80|81|82|79|79|79,2,4,p879cac,#48|49|50|51|50|49;st,8,p1f203f455f9fb5c0daef,1,p305085,#83|84|85|86|83|83|83,2,4,nil,#48|49|50|51|50|49;kn,12,p21314151819fa0b0cfd0e1,2,p305081,#87|88|89|90|87|87|87,2,5,nil,#52|53|54|55|54|53;jx,14,p142834485495a6b6c0d6e4f4,1,p305085f4,#91|92|93|94|91|91|91,2,4,p829ea7,#48|49|50|51|50|49;ml,13,p12324252829fa0b0cfd0e2,2,p305082,#87|88|89|90|87|87|87,2,5,nil,#56;bk,14,p16203f485f869fa7b8c0d7ef,1,nil,#95|96|97|98|95|95|95,2,4,p8d96a6,#48|49|50|51|50|49;sc,2,p1f2a3a4a5f8a9fa0b0c0d0ea,1,p508a,#79|80|81|82|79|79|79,2,3,p50,#57;rd,1,p1f2c3c4c5f8d97a0b0c7d0ec,1,p8d,#99|100|100|101|99|99|99,2,4,p8c97a7,#48|49|50|51|50|49", ";"), split("fireball,20,4,fire_projectile,nil,flinch,➡️+➡️+🅾️,#18|$19/7,false,false,false,false,false,true,true,false,false,false,true;aerial_fireball,20,4,fire_projectile,nil,flinch,➡️+➡️+🅾️,#18|$19/7,true,false,false,false,false,true,true,false,false,false,true;flying_kick,20,4,lk_flying_kick,nil,thrown_lower,➡️+➡️+❎,#12|$14/7,false,false,false,false,false,true,true,1,-1,true,true;bicycle_kick,20,4,lk_bicycle_kick,nil,stumble,h3❎,#$12/5|$31/1/0/1|$32/5/0/1|$33/6/0/1|$32/5/0/1|$31/1/0/1,false,false,false,false,true,false,true,1,-1,true,true@hat_toss,20,3,kl_hat_toss,nil,flinch,⬅️+➡️+🅾️,#37|37|$18/7|$20/7,false,false,false,false,false,true,true,false,false,true,true;spin,20,1.5,kl_spin,nil,thrown_higher,⬆️+⬆️,#3|$34/1/0/0/false/false/true|$35/1/0/0/true/false/true|$35/2/0/0/true/false/true|$35/3/0/0/true/false/true|$36/3/0/0/true/false/true|$36/3/0/0/true/false|$35/3|$35/2|35,false,false,false,false,true,false,true,false,false,true,true;teleport,nil,4,kl_teleport,nil,flinch,⬇️+⬆️,#$4/1/0/1,false,false,false,false,false,false,true,false,false,true,false;diving_kick,nil,4,kl_diving_kick,nil,thrown_lower,⬇️❎,#12|14,true,false,false,false,false,false,true,false,false,true,true@low_green_bolt,20,4,fire_projectile,nil,flinch,⬅️+⬇️+➡️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false,true;high_green_bolt,20,4,jc_high_green_bolt,nil,flinch,➡️+⬇️+⬅️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false,true;shadow_kick,20,4,jc_shadow_kick,nil,thrown_lower,⬅️+➡️+❎,#12|$14/7,false,false,false,false,false,false,true,false,false,true,true@acid_spit,20,4,fire_projectile,nil,flinch,➡️+➡️+🅾️,#29|$30/7,false,false,false,false,false,true,true,false,false,false,true@freeze,0,4,sz_freeze,nil,nil,⬇️+➡️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false,false@fire_skull,20,4,fire_projectile,nil,flinch,⬅️+⬅️+🅾️,#18|$19/7,false,false,false,false,false,true,true,false,false,false,true@fan_throw,20,4,fire_projectile,nil,flinch,➡️+➡️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false;aerial_fan_throw,20,4,fire_projectile,nil,flinch,➡️+➡️+🅾️,#18|$20/7,true,false,false,false,false,true,true,false,false,false,true@energy_wave,20,4,fire_projectile,nil,flinch,➡️+⬇️+⬅️+❎,#18|$20/7,false,false,false,false,false,true,true,false,false,false,true@sai_throw,20,4,fire_projectile,nil,flinch,h2🅾️,#18|$19/7,false,false,false,false,false,true,true,false,false,false;aerial_sai_throw,20,4,fire_projectile,nil,flinch,h2🅾️,#18|$19/7,true,false,false,false,false,true,true,false,false,false,true@blade_spark,20,4,fire_projectile,nil,flinch,⬇️+⬅️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false,true@spear,20,4,fire_projectile,nil,flinch,⬅️+⬅️+🅾️,#18|$20/7,false,false,false,false,false,true,true,false,false,false,true@lightning,20,4,fire_projectile,nil,flinch,⬇️+➡️+🅾️,#18|$19/7,false,false,false,false,false,true,true,false,false,false,true", "@"), split "name,bg_color,body_pal_map,gender,head_pal_map,head_sprites,projectile_fps,projectile_h,projectile_pal_map,projectile_sprites"

  for i, c_attrs in ipairs(c_attr_list) do
    characters[i] = string_to_hash(c_attr_keys, split(c_attrs))
    characters[i].special_attacks = define_actions(sa_attr_list[i])
  end

  return characters
end

function define_actions(attr_list)
  local actions, attr_list, attr_keys = {}, split(attr_list or "block,nil,2,nil,nil,nil,nil,#10|11,false,false,true,true,false,true,false,false,false,false,false;crouch,nil,2,nil,get_up,nil,nil,#$4/1/0/1|$5/1/0/2,false,false,true,true,false,true,false,false,false,false,false;flinch,nil,6,flinch,nil,nil,nil,#$23/6,false,false,false,false,false,false,false,false,false,false,false;jump_kick,10,3,jump_attack,nil,thrown_lower,nil,#$14/6,true,true,false,false,false,false,false,false,false,true,true;jump_punch,10,3,jump_attack,nil,flinch,nil,#$15/6,true,true,false,false,false,false,false,false,false,true,true;get_up,nil,2,nil,nil,nil,nil,#$5/1/0/2|$4/1/0/1,false,false,true,false,false,false,false,false,false,false,false;hook,100,3,attack,nil,thrown_higher,nil,#$6/1/0/1|$7/2|$8/3|$8/3|$8/3,false,true,false,false,false,true,false,1,false,false,true;idle,nil,1,nil,nil,nil,nil,#0,false,false,true,false,false,false,false,false,false,false,false;jump,nil,2,jump,nil,nil,nil,#$16/6/0/2|$17/4/2/1|$16/6/0/-2/true/true/true/true|$17/4/-2/-1/true/true/true/true,true,false,false,false,true,false,false,false,false,true,false;kick,10,2,attack,nil,flinch,nil,#$12/5|$13/6|$13/6,false,true,false,false,false,true,false,1,false,false,true;prone,nil,8,nil,get_up,nil,nil,#$22/4/-4/0/false/false/true/true,false,false,false,false,false,false,false,false,1,false,false;punch,10,2,attack,nil,flinch,nil,#$7/2|$9/3|$9/3,false,true,false,false,false,true,false,1,false,false,true;roundhouse_kick,20,2,attack,nil,thrown_lower,nil,#$7/2|$28/3/-1|$7/2/0/0/true/false/true/false|$12/5|$13/6|$13/6|$13/6|$12/5,false,true,false,false,false,false,false,1,false,false,true;stumble,nil,6,nil,nil,nil,nil,#$23/6|1,false,false,false,false,true,false,false,false,false,true,false;sweep,10,2,attack,nil,swept,nil,#$4/1/0/1|$25/2/0/1|$26/3/-1/1|$25/2/0/1/true/false/true/false|$27/1/0/1|$27/1/0/1|$4/1/0/1,false,true,false,false,false,false,false,1,false,false,false;swept,nil,4,swept,prone,nil,nil,#$21/6/0/1,false,false,false,false,false,false,false,false,false,false,false;thrown_lower,nil,3,thrown_lower,prone,nil,nil,#$23/6/0/0|$24/4/-4/0/false/false/true/true,true,false,false,false,false,false,false,false,false,true,false;thrown_higher,nil,3,thrown_higher,prone,nil,nil,#$23/6/0/0|$24/4/-4/0/false/false/true/true,true,false,false,false,false,false,false,false,false,true,false;walk,nil,4,walk,nil,nil,nil,#1|2|3|2,false,false,true,false,false,false,false,false,false,false,false", ";"), split "name,dmg,fps,handler,complementary_action,reaction,sequence,sprites,is_aerial,is_attack,is_cancelable,is_holdable,is_resetable,is_reversible,is_special_attack,is_x_shiftable,is_y_shiftable,requires_forced_stop,spills_blood"

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
  local p = string_to_hash("action_stack,action_stack_timeout,character,ca,caf,cap,facing,has_locked_controls,has_joined,highlighted_char,hp,held_buttons,held_buttons_timer,id,input_detection_delay,is_x_shifted,is_y_shifted,next_combats,particle_sets,previous_buttons,previous_directionals,projectile,released_buttons,st_frozen_timer,x,y", { "", action_stack_timeout, p.character, actions.idle, 0, {}, is_p1 and forward or backward, false, p.has_joined, is_p1 and 1 or 4, 100, nil, 0, id, 0, false, false, next_combats, {}, nil, nil, nil, nil, 0, is_p1 and 36 or 127 - 36 - sprite_w, y_bottom_limit })

  if is_p1 then
    p1 = p
  else
    p2 = p
  end
end