function _update()
  if g.mode == enums.modes.overworld then
    g:overworld()
  elseif g.mode == enums.modes.battle then
    g:battle()
  end

  g.c:update()
end