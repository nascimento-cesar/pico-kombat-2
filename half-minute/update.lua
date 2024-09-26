function _update()
  if current_game_mode == game_modes.overworld then
    update_overworld_mode()
  elseif current_game_mode == game_modes.battle then
    update_battle_mode()
  end

  update_countdown()
end

function update_overworld_mode()
  if btnp(🅾️) then
    start_battle_mode()
  end
end

function update_battle_mode()
  hero.x += hero.speed

  for enemy in all(enemies) do
    enemy.x -= enemy.speed

    local power_ratio = hero.power / enemy.power

    if hero.x >= enemy.x then
      enemy.hp -= hero.power
      hero.hp -= enemy.power

      if enemy.hp <= 0 then
        del(enemies, enemy)
      else
        if power_ratio > 1 then
          enemy.x += min(power_ratio * damage_bias, damage_cap)
        elseif power_ratio < 1 then
          hero.x -= min(damage_bias / power_ratio, damage_cap)
        else
          hero.x -= damage_bias * 2
          enemy.x += damage_bias * 2
        end
      end
    end
  end

  if hero.x > max_x or enemies == 0 then
    handle_victory()
  elseif hero.x < 0 or hero.hp <= 0 then
    handle_defeat()
  end
end

function update_countdown()
  countdown = default_countdown - (time() - countdown_start_time)
end

function handle_victory()
  current_game_mode = game_modes.overworld
end

function handle_defeat()
  current_game_mode = game_modes.overworld
end

function start_battle_mode()
  generate_enemies()
  current_game_mode = game_modes.battle
end

function generate_enemies()
  for i = 1, 2 do
    add(
      enemies, {
        x = max_x / 2 + 40 + i * 8,
        y = max_y / 2,
        speed = 1,
        power = 1,
        hp = 10
      }
    )
  end
end