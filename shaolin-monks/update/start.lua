function update_start()
  for p in all({ p1, p2 }) do
    if btnp(❎, p.id) then
      init_player(p)
      game.current_screen = screens.character_selection
    end
  end
end