function _draw()
  if game.current_screen == screens.start then
    draw_start()
  elseif game.current_screen == screens.character_selection then
    draw_character_selection()
  elseif game.current_screen == screens.next_combat then
    draw_next_combat()
  elseif game.current_screen == screens.gameplay then
    draw_gameplay()
  end
end