function draw_gameplay()
  cls(1)
  draw_stage()

  if is_round_finishing_move() then
    draw_finish_him_her()
  elseif is_round_finished() then
    draw_round_result()
  elseif is_round_beginning() then
    draw_round_start()
  elseif player_has_joined() then
    draw_new_player()
  end

  draw_round_timer()
  draw_hp()
  draw_player(p1)
  draw_player(p2)
end

function draw_stage()
  local x = (game.current_combat.current_stage - 1) % 8 * stage_offset
  local y = flr(game.current_combat.current_stage / 9) * 16

  map(x, y, 0, 0, 16, 16)
end

function draw_player(p)
  local flip_body_x = false
  local flip_body_y = false
  local flip_head_x = false
  local flip_head_y = false
  local head_x_adjustment = 0
  local head_y_adjustment = 0
  local body_id
  local head_id
  local index
  local sprite
  local sprites = p.current_action.sprites

  if is_action_held(p) then
    index = #sprites
  else
    index = flr(p.frames_counter / p.current_action.fps) + 1

    if is_action_released(p) then
      index = #sprites - index + 1
    end
  end

  sprite = sprites[index]

  if type(sprite) == "table" then
    body_id = sprite[1]
    head_id = sprite[2]
    head_x_adjustment = sprite[3] or 0
    head_y_adjustment = sprite[4] or 0
    flip_body_x = sprite[5]
    flip_body_y = sprite[6]
    flip_head_x = sprite[7]
    flip_head_y = sprite[8]
  else
    body_id = sprite
    head_id = 1
  end

  if p.facing == directions.backward then
    flip_body_x = not flip_body_x
    flip_head_x = not flip_head_x
  end

  draw_head(p, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
  draw_body(p, body_id, flip_body_x, flip_body_y)

  if p.projectile then
    draw_projectile(p)
  end

  draw_particles(p)
end

function draw_head(p, id, x_adjustment, y_adjustment, flip_x, flip_y)
  shift_pal(p.character.head_pal_map)
  spr(p.character.head_sprites[id], p.x + x_adjustment * p.facing, p.y + y_adjustment, 1, 1, flip_x, flip_y)
  pal()
end

function draw_body(p, id, flip_x, flip_y)
  shift_pal(p.character.body_pal_map)
  spr(id, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function draw_projectile(p)
  local flip_x = false
  local index
  local sprites = p.character.projectile_sprites

  index = flr(p.projectile.frames_counter / p.character.projectile_fps) + 1

  if index > #sprites then
    index = 1
    p.projectile.frames_counter = 0
  end

  if p.facing == directions.backward then
    flip_x = not flip_x
  end

  for color in all(p.character.projectile_pal_map) do
    pal(color[1], color[2])
  end

  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, flip_x)
  pal()
end

function draw_particles(p)
  for particle_set in all(p.particle_sets) do
    for particle in all(particle_set.particles) do
      particle.x += particle.speed_x
      particle.y += particle.speed_y

      pset(particle.x, particle.y, particle_set.color)

      particle.current_lifespan += 1

      if particle.current_lifespan > particle.max_lifespan then
        del(particle_set.particles, particle)
      end
    end

    if #particle_set.particles == 0 then
      del(p.particle_sets, particle_set)
    end
  end
end

function draw_round_timer()
  local elapsed = is_round_beginning() and 0 or time() - game.current_combat.round_start_time
  local remaining = ceil(round_duration - elapsed)
  local x = get_hcenter(remaining)
  print(remaining, x, 8, 7)
end

function draw_finish_him_her()
  if game.current_combat.timers.finishing_move > timers.finishing_move / 2 then
    local pronoun = game.current_combat.round_loser.character.g == gender.her and "her" or "him"
    local text = "finish " .. pronoun
    draw_blinking_text(text)
  end
end

function draw_round_start()
  local text = ""

  if game.current_combat.timers.round_start > timers.round_start / 2 then
    text = "round " .. game.current_combat.round
  else
    text = "fight"
  end

  draw_blinking_text(text)
end

function draw_round_result()
  local winner = game.current_combat.round_winner
  local text = (winner == p1 and "p1" or "p2") .. " wins"
  draw_blinking_text(text)
end

function draw_new_player()
  local text = "a new challenger has emerged"
  draw_blinking_text(text)
end

function draw_hp()
  local offset = 8
  local h = 8
  local w = (128 - offset * 3) / 2
  local y = offset * 2

  for p in all({ p1, p2 }) do
    local x = offset + p.id * w + p.id * offset
    local hp_w = w * p.hp / 100
    hp_w = hp_w < 1 and 1 or hp_w

    rectfill(x, y, x + w - 1, y + h - 1, 8)
    rectfill(x, y, x + hp_w - 1, y + h - 1, 11)
    rect(x, y, x + w - 1, y + h - 1, 6)

    for i = 1, game.current_combat.rounds_won[p.id] do
      shift_pal("50")
      spr(192, x + (i - 1) * 8, y + h + 2)
      pal()
    end
  end
end

function draw_blinking_text(s)
  print(s, get_hcenter(s), get_vcenter(), get_blinking_color())
end