function _init()
  define_global_variables()
  define_game()
  define_actions()
  define_bosses()
  characters = define_characters()
  define_players()
  disable_hold_function()
end

function define_global_variables()
  action_stack_timeout = 6

  bs = {
    kr = 1,
    sk = 2
  }
  debug = {}
  directions = {
    backward = -1,
    forward = 1
  }
  flinch_speed = 3
  gender = {
    him = 1,
    her = 2
  }
  jump_speed = 2
  p_id = {
    p1 = 0,
    p2 = 1
  }
  projectile_speed = 3
  round_duration = 90
  sprite_h = 8
  sprite_w = 7
  stage_offset = 16
  stages_number = 9
  swept_speed = 3
  timers = {
    finishing_move = 90,
    new_player = 60,
    round_end = 60,
    round_start = 60
  }
  walk_speed = 1
  x_shift = 3
  y_shift = 2
  y_bottom_limit = 127 - 36
  y_upper_limit = 127 - 36 - 20
end

function define_game()
  game = {
    current_combat = nil,
    current_screen = "start",
    joined_status = {
      [p_id.p1] = false,
      [p_id.p2] = false
    },
    next_combats = {
      [p_id.p1] = {},
      [p_id.p2] = {}
    }
  }
end

function define_bosses()
  bosses = {
    [bs.sk] = {
      head_sprites = { 103, 104, 105, 106, 103, 103, 103 },
      pallete_map = {
        { 1, 15 },
        { 3, 15 },
        { 4, 6 },
        { 5, 2 },
        { 9, 6 },
        { 10, 13 },
        { 11, 5 },
        { 12, 15 },
        { 14, 15 }
      },
      projectile = {
        frames_per_sprite = 2,
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {}
    }
  }
end

function define_characters()
  local characters, attr_list, c_attr_keys, sa_attr_keys = {}, split(
    [[lk,2,1f2838485f9fa0b0c0d0e8,1,50,#64|65|66|67|68|69|68,2,4,nil,#48|49|50|51|50|49@fireball,➡️➡️🅾️,#18|$19/7,20,*a2,*r1;
  kl,3,1f2030405f9fa8b8c1d8e0,1,5085,#70|71|72|73|70|70|74,2,2,50d5,#58|59|60|61|60|59@hat_toss,⬅️➡️🅾️,#18|20,20,*a2,*r1;
  jc,13,1f203f415f91a0b1c0d1e1,1,5084,#75|76|77|78|75|75|75,2,4,839bab7b,#48|49|50|51|50|49@shadow_bolt,⬇️➡️🅾️,#18|$20/7,20,*a2,*r1;
  rp,4,1f23435f839fa0b0c0d0e3,1,1324508398,#79|80|81|82|79|79|102,2,4,839bab7b,#48|49|50|51|50|49@acid_spit,➡️➡️🅾️,29|$30/7,20,*a2,*r1;
  sz,1,1f2c3c4c5f8c9fa0b0c0d0ec,1,508c,#79|80|81|82|79|79|79,2,4,879cac,#48|49|50|51|50|49@freeze,⬇️➡️🅾️,#18|$20/7,20,*a2,*r1;
  st,8,1f203f455f9fb5c0daef,1,5085,#83|84|85|86|83|83|83,2,4,nil,#48|49|50|51|50|49@fire_skull,⬅️⬅️🅾️,#18|$19/7,20,*a2,*r1;
  kn,12,21314151819fa0b0cfd0e1,2,5081,#87|88|89|90|87|87|87,2,5,nil,#52|53|54|55|54|53@fan_throw,➡️➡️🅾️,#18|$20/7,20,*a2,*r1;
  jx,14,142834485495a6b6c0d6e4f4,1,5085f4,#91|92|93|94|91|91|91,2,4,829ea7,#48|49|50|51|50|49@energy_wave,➡️⬇️⬅️❎,#18|$20/7,20,*a2,*r1;
  ml,13,12324252829fa0b0cfd0e2,2,5082,#87|88|89|90|87|87|87,2,5,nil,#56@sai_throw,⬇️⬅️🅾️,#18|$19/7,20,*a2,*r1;
  bk,14,16203f485f869fa7b8c0d7ef,1,nil,#95|96|97|98|95|95|95,2,4,8d96a6,#48|49|50|51|50|49@blade_spark,⬇️⬅️🅾️,#18|$20/7,20,*a2,*r1;
  sc,2,1f2a3a4a5f8a9fa0b0c0d0ea,1,508a,#79|80|81|82|79|79|79,2,3,50,#57@spear,⬅️⬅️🅾️,#18|$20/7,20,*a2,*r1;
  rd,1,1f2c3c4c5f8d97a0b0c7d0ec,1,8d,#99|100|100|101|99|99|99,2,4,8c97a7,#48|49|50|51|50|49@lightning,⬇️➡️🅾️,#18|$19/7,20,*a2,*r1]], ";"
  ), split "name,bg_color,body_pal_map,gender,head_pal_map,head_sprites,projectile_fps,projectile_h,projectile_pal_map,projectile_sprites", split "sequence,sprites,dmg,handler,reaction_handler"

  for i, attrs in ipairs(attr_list) do
    local c_attrs, sa_attrs = unpack_split(attrs, "@")
    characters[i] = string_to_hash(c_attr_keys, split(c_attrs, ",", false))
    characters[i].special_attacks = {}
  end

  return characters
end

function define_actions()
  actions = {
    block = create_action("block", 2, nil, true, false, "#10|11", "other"),
    crouch = create_action("crouch", 2, nil, true, false, "#$4/1/0/1|$5/1/0/2", "other"),
    flinch = create_action("flinch", 6, flinch, false, false, "#23", "damage_reaction"),
    flying_kick = create_action("flying_kick", 3, attack, false, false, "#$14/6", "aerial_attack", propelled, 10),
    flying_punch = create_action("flying_punch", 3, attack, false, false, "#$15/6", "aerial_attack", flinch, 10),
    get_up = create_action("get_up", 2, nil, false, false, "#$5/1/0/2|$4/1/0/1", "other"),
    hook = create_action("hook", 3, attack, false, true, "#$6/1/0/1|$7/2|$8/3|$8/3|$8/3|$8/3|$8/3|$7/2", "attack", propelled, 100),
    idle = create_action("idle", 1, nil, false, false, "#0", "other"),
    jump = create_action("jump", 2, nil, false, false, "#$16/6/0/2|$17/4/2/1|$16/6/0/-2/true/true/true/true|$17/4/-2/-1/true/true/true/true", "aerial"),
    kick = create_action("kick", 4, attack, false, true, "#$12/5|$13/6|$12/5", "attack", flinch, 10),
    prone = create_action("prone", 8, nil, false, false, "#$22/4/-4/0/false/false/true/true", "other"),
    propelled = create_action("propelled", 3, nil, true, false, "#$23/6/0/0|$24/4/-4/0/false/false/true/true", "damage_reaction"),
    punch = create_action("punch", 3, attack, false, true, "#$7/2|$9/3|$7/2", "attack", flinch, 10),
    roundhouse_kick = create_action("roundhouse_kick", 2, attack, false, true, "#$7/2|$28/3/-1|$7/2/0/0/true/false/true/false|$12/5|$13/6|$13/6|$13/6|$12/5", "attack", propelled, 20),
    sweep = create_action("sweep", 2, attack, false, true, "#$4/1/0/1|$25/2/0/1|$26/3/-1/1|$25/2/0/1/true/false/true/false|$27/1/0/1|$27/1/0/1|$4/1/0/1", "attack", swept, 10),
    swept = create_action("swept", 4, nil, false, false, "#$21/6/0/1", "damage_reaction"),
    walk = create_action("walk", 4, walk, false, false, "#1|2|3|2", "movement")
  }
end

function create_action(name, frames_per_sprite, handler, is_holdable, is_x_shiftable, sprites, type, reaction_handler, damage)
  return {
    damage = damage,
    frames_per_sprite = frames_per_sprite,
    handler = handler,
    is_holdable = is_holdable,
    is_x_shiftable = is_x_shiftable,
    name = name,
    reaction_handler = reaction_handler,
    sprites = eval_str(sprites),
    type = type
  }
end

function create_special_attack(name, sequence, sprites, dmg, handler, reaction_handler)
  return {
    action = create_action(
      name,
      4,
      handler,
      false,
      false,
      sprites,
      "special_attack",
      reaction_handler or flinch,
      dmg or 20
    ),
    sequence = sequence
  }
end

function define_players()
  p1 = create_player(p_id.p1)
  p2 = create_player(p_id.p2)
end

function create_player(id, character)
  local is_p1 = id == p_id.p1

  return {
    action_stack = "",
    action_stack_timeout = action_stack_timeout,
    character = character,
    current_action = actions.idle,
    current_action_params = {},
    current_action_state = "in_progress",
    current_projectile = nil,
    facing = is_p1 and directions.forward or directions.backward,
    frames_counter = 0,
    highlighted_char = is_p1 and 1 or 4,
    hp = 100,
    id = id,
    is_orientation_locked = false,
    is_x_shifted = false,
    is_y_shifted = false,
    jump_acceleration = 0,
    particle_sets = {},
    x = is_p1 and 36 or 127 - 36 - sprite_w,
    y = y_bottom_limit
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end