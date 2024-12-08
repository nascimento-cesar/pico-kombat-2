function _draw()
  function_lookup("start,char_selection,next_cb,gameplay", { draw_start, draw_char_selection, draw_next_cb, draw_gameplay }, current_screen)
end