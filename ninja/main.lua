function _update()
  player_update()
  player_animate()
  player_camera()
end

function _draw()
  cls()
  map(0, 0)
  spr(player.sp, player.x, player.y, 1, 1, player.flp)

  --------test-------
  rect(x1r, y1r, x2r, y2r)
  print("⬅️= " .. collide_l, player.x, player.y - 10)
  print("➡️= " .. collide_r, player.x, player.y - 16)
  print("⬆️= " .. collide_u, player.x, player.y - 22)
  print("⬇️= " .. collide_d, player.x, player.y - 28)
  -------------------
end