function _update()
  update_debug()

  if game.current_screen == "start" then
    update_start()
  elseif game.current_screen == "character_selection" then
    update_character_selection()
  elseif game.current_screen == "next_combat" then
    update_next_combat()
  elseif game.current_screen == "gameplay" then
    update_gameplay()
  end
end