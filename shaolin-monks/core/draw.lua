function _draw()
  if game.current_screen == "start" then
    draw_start()
  elseif game.current_screen == "character_selection" then
    draw_character_selection()
  elseif game.current_screen == "next_combat" then
    draw_next_combat()
  elseif game.current_screen == "gameplay" then
    draw_gameplay()
  end

  draw_debug()
end