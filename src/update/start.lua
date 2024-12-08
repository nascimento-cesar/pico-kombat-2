function update_start()
  music(-1, 200)
  foreach_pl(function(p, p_id)
    if btnp(❎, p_id) then
      init_pl(p)
      current_screen = "char_selection"
    end
  end)
end