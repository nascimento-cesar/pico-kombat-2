function update_gameplay()
  if detect_new_player() then
    return process_new_player()
  end

  function_from_hash("countdown,finished,finishing_move,new_player", { process_round_start, process_round_end, process_finishing_move }, combat_round_state)
  update_player(p1)
  update_player(p2)
  fix_players_orientation()
  fix_players_placement()
end

function detect_new_player()
  foreach_player(function(p, p_id)
    if not p.has_joined and not is_round_state_eq "new_player" then
      if btnp(🅾️, p_id) or btnp(❎, p_id) then
        init_player(p)
        combat_round_state = "new_player"
      end
    end
  end)

  return is_round_state_eq "new_player"
end

function reset_timers()
  for k, v in pairs(timers) do
    combat_round_timers[k] = v
  end
end

function process_new_player()
  if combat_round_timers.new_player > 0 then
    combat_round_timers.new_player -= 1
  else
    current_screen, p1.character, p2.character = "character_selection"
  end
end

function process_finishing_move()
  if combat_round_timers.finishing_move > 0 then
    combat_round_timers.finishing_move -= 1
  else
    combat_round_state = "finished"
  end
end

function process_round_end()
  if combat_round_timers.round_end > 0 then
    combat_round_timers.round_end -= 1
  else
    if has_combat_ended() then
      local winner = get_combat_winner()
      local loser = get_vs(winner)

      if not p1.has_joined or not p2.has_joined then
        current_screen, loser.character = "next_combat"
      else
        current_screen, loser.character, winner.character = "character_selection"
      end
    else
      combat_round += 1
      combat_round_state = "countdown"
    end

    setup_new_round()
  end
end

function process_round_start()
  if combat_round_timers.round_start > 0 then
    combat_round_timers.round_start -= 1
  else
    combat_round_start_time, combat_round_state = time(), "in_progress"
  end
end

function get_next_challenger(p)
  local challenger = characters[p.next_combats[1]]
  deli(p.next_combats, 1)

  if p.character == challenger then
    return get_next_challenger(p)
  end

  return challenger
end

function update_player(p)
  if is_frozen(p) then
    p.frozen_timer -= 1
  else
    p.frames_counter += 1
    update_previous_action(p)

    if (is_round_state_eq "in_progress" or is_round_state_eq "finishing_move") and combat_round_loser ~= p then
      if p.has_joined then
        process_inputs(p)
      else
        next_cpu_action(p)
      end
    end

    perform_current_action(p)
    update_aerial_action(p)
    update_projectile(p)

    if p.has_joined then
      cleanup_action_stack(p)
    end
  end
end

function next_cpu_action(p)
  handle_no_key_press(p)
end

function update_previous_action(p)
  if is_action_animation_finished(p) then
    local has_landed = p.current_action_params.has_landed

    if is_action_type_eq(p, "aerial") and not has_landed then
      restart_action(p)
    elseif is_action_type_eq(p, "aerial_attack") and not has_landed then
      hold_action(p)
    elseif is_action_eq(p, "propelled") and not has_landed then
      hold_action(p)
    elseif is_action_type_eq(p, "special_attack") then
      if p.current_action.name == "bicycle_kick" then
        restart_action(p, 2)
      else
        hold_action(p)
      end
    elseif is_action_eq(p, "swept") then
      start_action(p, actions.prone)
    elseif is_action_eq(p, "flinch") and is_round_state_eq "finished" then
      swept(p)
    elseif is_action_eq(p, "prone") then
      if is_round_state_eq "finished" then
        hold_action(p)
      else
        start_action(p, actions.get_up)
      end
    else
      finish_action(p)
    end
  end
end

function process_inputs(p)
  local pressed_buttons, pressed_directionals, direction = get_pressed_inputs(p)
  local action, pressed_chord, is_blocking = nil, pressed_directionals .. pressed_buttons, pressed_buttons == "🅾️❎"

  if p.held_buttons then
    if p.held_buttons == pressed_buttons then
      p.held_buttons_timer += 1
    else
      release_held_buttons(p)
    end
  elseif pressed_buttons ~= "" then
    if p.held_buttons_timer == 0 then
      if pressed_buttons == p.previous_buttons or not p.previous_buttons then
        p.held_buttons_timer += 1
      else
        p.held_buttons_timer, p.previous_buttons = 0, pressed_buttons
      end
    else
      p.held_buttons = pressed_buttons
    end
  end

  if pressed_directionals ~= p.previous_directionals then
    p.input_detection_delay, p.previous_directionals = 0, pressed_directionals ~= "" and pressed_directionals or nil
  end

  action = actions_map[is_blocking and pressed_buttons or (p.held_buttons and pressed_directionals or pressed_chord)]

  if action then
    local type, name = unpack_split(action, "|")
    local handler = type == "1" and setup_action or setup_attack
    record_action(p, p.held_buttons and pressed_directionals or pressed_chord)
    handler(p, name, direction and { direction = direction })
  else
    handle_no_key_press(p)
  end
end

function get_pressed_inputs(p)
  local pressed_buttons, pressed_directionals, direction = "", "", nil

  for i, k in ipairs(split "⬅️,➡️,⬆️,⬇️,🅾️,❎") do
    if btn(i - 1, p.id) then
      if i < 5 then
        if k == "⬅️" then
          direction = p.facing * -1
        elseif k == "➡️" then
          direction = p.facing
        end

        if p.facing == backward then
          k = k == "⬅️" and "➡️" or (k == "➡️" and "⬅️" or k)
        end

        pressed_directionals = pressed_directionals .. k
      else
        pressed_buttons = pressed_buttons .. k
      end
    end
  end

  return pressed_buttons, pressed_directionals, direction
end

function release_held_buttons(p)
  p.released_buttons = (p.held_buttons and p.held_buttons_timer > 10) and p.held_buttons .. "," .. flr(p.held_buttons_timer / 10) or nil
  p.held_buttons, p.held_buttons_timer = nil, 0
end

function perform_current_action(p)
  return p.current_action.handler and p.current_action.handler(p)
end

function update_aerial_action(p)
  if is_in_air(p) then
    local direction, vs = p.current_action_params.direction, get_vs(p)
    local x_speed, is_turn_around_attack = jump_speed * (direction or 0) / 2, p.current_action_params.is_turn_around_attack

    if p.current_action_params.is_landing then
      move_y(p, jump_speed)
      move_x(p, x_speed, is_turn_around_attack and p.facing * -1 or p.facing)

      if is_p1_ahead_p2() and not is_turn_around_attack then
        if is_action_type_eq(p, "aerial") then
          p.current_action_params.is_turn_around_attack = true
          shift_player_orientation(p)
        end

        if not p.current_action_params.vs_has_turned_around then
          shift_player_orientation(vs)
          p.current_action_params.vs_has_turned_around = true
        end
      end

      if p.y >= y_bottom_limit then
        p.current_action_params.has_landed = true
        p.current_action_params.is_landing = false

        setup_action(p, is_action_eq(p, "propelled") and "prone" or "idle")
      end
    else
      if not p.current_action_params.has_landed then
        move_y(p, -jump_speed)
        move_x(p, x_speed)

        if p.y <= y_upper_limit then
          p.current_action_params.is_landing = true
        end
      end
    end
  end
end

function update_projectile(p)
  if p.projectile then
    local vs = get_vs(p)

    p.projectile.x += projectile_speed * p.facing
    p.projectile.frames_counter += 1

    if has_collision(p.projectile.x, p.projectile.y, vs.x, vs.y, nil, 6) then
      p.projectile = nil
      deal_damage(p.current_action, vs)
      start_action(p, actions.idle)
    elseif is_limit_right(p.projectile.x) or is_limit_left(p.projectile.x) then
      p.projectile = nil
      start_action(p, actions.idle)
    end
  end
end

function fix_players_orientation()
  if (p1.facing == p2.facing or is_p1_ahead_p2()) and not is_in_air(p1) and not is_in_air(p2) then
    shift_player_orientation(p1, p1.x < p2.x and forward or backward)
    shift_player_orientation(p2, p1.x < p2.x and backward or forward)
  end
end

function shift_player_orientation(p, facing)
  if not is_action_type_eq(p, "special_attack") and not is_frozen(p) then
    p.facing = facing or p.facing * -1
  end
end

function fix_players_placement()
  if not is_in_air(p1) and not is_in_air(p2) then
    if p1.x < sprite_w and p2.x < sprite_w then
      if p1.facing == forward then
        p1.x = map_min_x
        p2.x = sprite_w
      else
        p1.x = sprite_w
        p2.x = map_min_x
      end
    end

    if p1.x + sprite_w > map_max_x - sprite_w + 2 and p2.x + sprite_w > map_max_x - sprite_w + 2 then
      if p1.facing == forward then
        p1.x = map_max_x - (sprite_w - 1) * 2
        p2.x = map_max_x - (sprite_w - 1)
      else
        p1.x = map_max_x - (sprite_w - 1)
        p2.x = map_max_x - (sprite_w - 1) * 2
      end
    end
  end
end

function cleanup_action_stack(p, force)
  if force or p.action_stack_timeout <= 0 then
    p.action_stack_timeout = action_stack_timeout
    p.action_stack = ""
  else
    p.action_stack_timeout -= 1
  end
end

function handle_no_key_press(p)
  if is_action_eq(p, "walk") then
    setup_action(p, "idle")
  elseif p.current_action.is_holdable and is_action_state_eq(p, "held") and not is_action_eq(p, "propelled") then
    setup_action(p, p.current_action, { is_released = true })
  elseif is_action_state_eq(p, "finished") then
    setup_action(p, "idle")
  end
end

function setup_action(p, next_action, params)
  params, next_action = params or {}, type(next_action) == "string" and actions[next_action] or next_action

  if is_action_type_eq(p, "aerial") then
    if next_action.type == "kick_attack" then
      next_action = actions.flying_kick
    elseif next_action.type == "punch_attack" then
      next_action = actions.flying_punch
    end

    if next_action.type == "aerial_attack" then
      merge(params, p.current_action_params)
    end
  end

  local is_next_action_eq_previous = p.current_action == next_action

  if is_action_state_eq(p, "finished") then
    if is_next_action_eq_previous then
      if p.current_action.is_holdable then
        hold_action(p)
      elseif is_action_type_eq(p, "movement") then
        restart_action(p)
      else
        start_action(p, next_action, params)
      end
    else
      start_action(p, next_action, params)
    end
  elseif is_next_action_eq_previous then
    if is_action_state_eq(p, "held") and params.is_released then
      release_action(p)
    elseif is_action_type_eq(p, "movement") and p.current_action_params.direction ~= params.direction then
      start_action(p, next_action, params)
    end
  elseif not is_next_action_eq_previous then
    if is_action_type_eq(p, "aerial") and next_action.type == "aerial_attack" or next_action == actions.idle then
      start_action(p, next_action, params)
    elseif is_action_type_eq(p, "movement") then
      start_action(p, next_action, params)
    elseif is_action_state_eq(p, "held") then
      if not is_action_type_eq(p, "aerial_attack") and not is_action_type_eq(p, "special_attack") and (next_action.type == "kick_attack" or next_action.type == "punch_attack") then
        start_action(p, next_action, params)
      elseif next_action == actions.prone then
        start_action(p, next_action, params)
      end
    end
  end
end

function setup_attack(p, next_action, params)
  setup_action(p, next_action, merge(params or {}, { is_player_attacking = true }))
end

function start_action(p, action, params)
  params = params or {}

  for _, special_attack in pairs(p.character.special_attacks) do
    local sequence, should_trigger = special_attack.sequence, false

    if sub(sequence, 1, 1) == "h" and p.released_buttons then
      local released_buttons, released_buttons_timer = unpack_split(p.released_buttons)
      p.released_buttons, should_trigger = nil, released_buttons == sub(sequence, 3) and released_buttons_timer >= sub(sequence, 2)
    else
      should_trigger = sub(p.action_stack, #p.action_stack - #sequence + 1, #p.action_stack) == sequence
    end

    if should_trigger then
      cleanup_action_stack(p, true)

      return setup_attack(p, special_attack)
    end
  end

  p.current_action = action
  p.current_action_state = "in_progress"
  p.current_action_params = params
  p.frames_counter = 0

  if action.is_x_shiftable then
    shift_player_x(p)
  end

  if action == actions.prone then
    shift_player_y(p)
  elseif action == actions.get_up then
    shift_player_y(p, true)
  end
end

function hold_action(p)
  p.current_action_state = "held"
  p.frames_counter = 0
end

function release_action(p)
  p.current_action_state = "released"
  p.current_action_params = { is_released = true }
  p.frames_counter = 0
end

function finish_action(p)
  p.current_action_state = "finished"
  shift_player_x(p, true)
end

function restart_action(p, restart_from)
  p.current_action_state = "in_progress"
  p.frames_counter = (restart_from or 0) * p.current_action.fps
end

function has_collision(a_x, a_y, t_x, t_y, type, a_w, a_h, t_w, t_h)
  local a_w, a_h, t_w, t_h = a_w or sprite_w, a_h or sprite_h, t_w or sprite_w, t_h or sprite_h
  local has_r_col, has_l_col, has_u_col, has_d_col = a_x + a_w > t_x and a_x < t_x, a_x < t_x + t_w and a_x > t_x, t_y + t_h > a_y and t_y <= a_y, a_y + a_h > t_y and t_y >= a_y

  if type == "left" then
    return has_l_col and (has_u_col or has_d_col)
  elseif type == "right" then
    return has_r_col and (has_u_col or has_d_col)
  else
    return (has_r_col or has_l_col) and (has_u_col or has_d_col)
  end
end

function record_action(p, input)
  if p.input_detection_delay <= 0 and input ~= "" then
    p.action_stack = p.action_stack .. (p.action_stack ~= "" and "+" or "") .. input
    p.action_stack_timeout = action_stack_timeout
    p.input_detection_delay = 1

    if #p.action_stack > 20 then
      p.action_stack = sub(p.action_stack, 2, 21)
    end
  end
end

function shift_player_x(p, unshift)
  if unshift then
    if p.is_x_shifted then
      move_x(p, -x_shift)
      p.is_x_shifted = false
    end
  elseif not p.is_x_shifted then
    move_x(p, x_shift, nil, true)
    p.is_x_shifted = true
  end
end

function shift_player_y(p, unshift, shift_up)
  if unshift then
    if p.is_y_shifted then
      move_y(p, y_bottom_limit - p.y)
      p.is_y_shifted = false
    end
  elseif not p.is_y_shifted then
    move_y(p, y_shift * (shift_up and -1 or 1), nil, true)
    p.is_y_shifted = true
  end
end

function deal_damage(action, p)
  p.hp -= action.dmg
  action.reaction_handler(p)

  if action ~= actions.sweep then
    spill_blood(p)
  end

  check_defeat(p)
end

function spill_blood(p)
  add(p.particle_sets, build_particle_set(8, 30, p.facing == forward and p.x + sprite_w or p.x, p.y))
end

function check_defeat(p)
  if is_round_state_eq "finishing_move" then
    combat_round_state = "finished"
  elseif p.hp <= 0 then
    local vs = get_vs(p)
    combat_rounds_won[vs.id] += 1
    combat_round_loser, combat_round_winner, combat_round_state = p, vs, has_combat_ended() and "finishing_move" or "finished"
  end
end

function attack(p, collision_callback)
  local vs, full_sprite_w = get_vs(p), sprite_w + 1

  if is_player_attacking(p) and has_collision(p.x, p.y, vs.x, vs.y, nil, full_sprite_w) then
    if vs.is_blocking then
    else
      deal_damage(p.current_action, vs)
      p.current_action_params.is_player_attacking = false

      if collision_callback then
        collision_callback()
      end
    end
  elseif is_limit_left(p.x) or is_limit_right(p.x) then
    finish_action(p)
  end
end

function walk(p)
  move_x(p, walk_speed * p.current_action_params.direction)
end

function build_particle_set(color, count, x, y)
  local particle_set = string_to_hash("color,particles,x,y", { color, {}, x, y })

  for i = 1, count do
    add(particle_set.particles, string_to_hash("current_lifespan,max_lifespan,speed_x,speed_y,x,y", { rnd(10), 10, rnd() * 2 - 1, rnd() * 2 - 1, particle_set.x, particle_set.y }))
  end

  return particle_set
end

function move_x(p, x_increment, direction, allow_overlap, ignore_collision)
  direction = direction or p.facing

  local vs = get_vs(p)
  local new_p_x = p.x + x_increment * direction
  local has_l_col, has_r_col = has_collision(new_p_x, p.y, vs.x, vs.y, "left"), has_collision(new_p_x, p.y, vs.x, vs.y, "right")

  if is_limit_left(new_p_x) then
    p.x = map_min_x
  elseif is_limit_right(new_p_x) then
    p.x = map_max_x - sprite_w + 1
  elseif has_l_col and not ignore_collision then
    if allow_overlap then
      p.x = new_p_x
    else
      local vs_x_increment = new_p_x - vs.x - sprite_w + 1

      if not is_limit_left(vs.x + vs_x_increment + 1) then
        if not is_in_air(vs) then
          move_x(vs, vs_x_increment, nil, false, true)
        end

        p.x = new_p_x
      end
    end
  elseif has_r_col and not ignore_collision then
    if allow_overlap then
      p.x = new_p_x
    else
      local vs_x_increment = vs.x - new_p_x - sprite_w + 1

      if not is_limit_right(vs.x - vs_x_increment - 1) then
        if not is_in_air(vs) then
          move_x(vs, vs_x_increment, nil, false, true)
        end

        p.x = new_p_x
      end
    end
  else
    p.x = new_p_x
  end
end

function move_y(p, y)
  p.y += y
end