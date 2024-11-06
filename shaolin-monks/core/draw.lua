function _draw()
  if is_current_screen_eq "start" then
    draw_start()
  elseif is_current_screen_eq "character_selection" then
    draw_character_selection()
  elseif is_current_screen_eq "next_combat" then
    draw_next_combat()
  elseif is_current_screen_eq "gameplay" then
    draw_gameplay()
  end

  draw_debug()
end