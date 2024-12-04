function _draw()
  function_lookup("start,char_selection,next_combat,gameplay", { draw_start, draw_char_selection, draw_next_combat, draw_gameplay }, current_screen)
end