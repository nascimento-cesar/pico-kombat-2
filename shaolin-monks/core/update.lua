function _update()
  update_debug()

  if game.current_screen == screens.start then
    update_start()
  elseif game.current_screen == screens.character_selection then
    update_character_selection()
  elseif game.current_screen == screens.next_combat then
    update_next_combat()
  elseif game.current_screen == screens.gameplay then
    update_gameplay()
  end
end