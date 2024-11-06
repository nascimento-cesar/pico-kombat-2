function _update()
  update_debug()
  string_to_hash("start,character_selection,next_combat,gameplay", { update_start, update_character_selection, update_next_combat, update_gameplay })[current_screen]()
end