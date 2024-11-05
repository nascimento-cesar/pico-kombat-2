function update_start()
  foreach_player(function(p)
    if btnp(❎, p.id) then
      init_player(p)
      game.current_screen = "character_selection"
    end
  end)
end