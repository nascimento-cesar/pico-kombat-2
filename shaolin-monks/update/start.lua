function update_start()
  music(-1, 200)
  foreach_player(function(p, p_id)
    if btnp(❎, p_id) then
      init_player(p)
      current_screen = "character_selection"
    end
  end)
end