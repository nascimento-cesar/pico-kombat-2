function _draw()
  draw_game()
  draw_debug()
end

function draw_game()
  cls()

  if current_game_mode == game_modes.battle then
    draw_battle_mode()
  elseif current_game_mode == game_modes.overworld then
    draw_overworld_mode()
  end
end

function draw_battle_mode()
  draw_hero()
  draw_enemies()
end

function draw_overworld_mode()
  draw_countdown()
end

function draw_hero()
  pset(hero.x, hero.y, 3)
end

function draw_enemies()
  for enemy in all(enemies) do
    pset(enemy.x, enemy.y, 2)
  end
end

function draw_countdown()
  print(countdown, 0, 0, 7)
end

function draw_debug()
  print(hero.hp, 0, 50, 7)
end