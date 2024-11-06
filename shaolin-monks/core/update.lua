function _update()
  update_debug()

  if is_current_screen_eq "start" then
    update_start()
  elseif is_current_screen_eq "character_selection" then
    update_character_selection()
  elseif is_current_screen_eq "next_combat" then
    update_next_combat()
  elseif is_current_screen_eq "gameplay" then
    update_gameplay()
  end
end