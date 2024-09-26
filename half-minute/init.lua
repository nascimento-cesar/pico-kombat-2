function _init()
  max_x = 127
  max_y = 127
  game_modes = {
    overworld = 0,
    battle = 1
  }
  current_game_mode = game_modes.overworld
  current_level = 2
  base_hp = 10
  hero = {
    x = max_x / 2,
    y = max_y / 2,
    speed = 1,
    power = current_level,
    hp = base_hp
  }
  enemies = {}
  damage_bias = 5
  damage_cap = max_x / 2
  default_countdown = 60.0
  countdown = default_countdown
  countdown_start_time = time()
end