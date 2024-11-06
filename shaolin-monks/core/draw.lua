function _draw()
  string_to_hash("start,character_selection,next_combat,gameplay", { draw_start, draw_character_selection, draw_next_combat, draw_gameplay })[current_screen]()
  draw_debug()
end