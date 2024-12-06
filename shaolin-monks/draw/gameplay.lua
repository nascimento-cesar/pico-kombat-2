function draw_gameplay()
  cls()

  if cb_round_state == "boss_defeated" then
    if ccp.defeat_animation_step == 1 then
      shift_pal "p07172737475767778797a7b7c7d7e7f7"
      draw_stage()
      pal()
      draw_pls()
    else
      draw_stage()
      draw_pls()

      if ccp.defeat_animation_step == 3 then
        draw_blinking_text "evil emperor has fallen!"
      end
    end
  else
    draw_stage()
    function_lookup("finished,finishing_mv,new_pl,starting,time_up", { draw_finished, draw_finishing_mv, draw_new_pl, draw_starting, draw_time_up }, cb_round_state)
    print(cb_round_remaining_time, get_hcenter(cb_round_remaining_time), 8, 7)
    local offset = 8
    local h, w, y = 8, (128 - offset * 3) / 2, offset * 2

    foreach_pl(function(p, p_id)
      local x, hp_w = offset + p_id * w + p_id * offset, max(w * p.hp / 100, 1)
      rectfill(x, y, x + w - 1, y + h - 1, 8)
      rectfill(x, y, x + hp_w - 1, y + h - 1, 11)
      rect(x, y, x + w - 1, y + h - 1, 6)
      for i = 1, cb_rounds_won[p_id] do
        shift_pal "p50"
        spr(192, x + (i - 1) * 8, y + h + 2)
        pal()
      end
    end)

    if ccp.has_finishing_mv_hit then
      draw_pl(ccp.tmp_pls_1)
      draw_pl(ccp.tmp_pls_2)
    end

    draw_pls()

    if p1.pj then
      draw_pj(p1)
    end

    if p2.pj then
      draw_pj(p2)
    end
  end
end

function draw_pls()
  if p1.cap.has_hit or cb_round_winner == p1 then
    draw_pl(p2)
    draw_pl(p1)
  else
    draw_pl(p1)
    draw_pl(p2)
  end
end

function draw_stage()
  palt(0, false)
  map(0, 0, 0, 0, 16, 16)
  pal()
end

function draw_pl(p)
  if not p or ccp.skip_p_rendering == p.id then
    return
  end

  local flip_bd_x, flip_bd_y, flip_hd_x, flip_hd_y, hd_x_adjustment, hd_y_adjustment, sp, is_dizzy, bd_id, hd_id, index = false, false, false, false, 0, 0, p.ca.sps[flr((p.caf - 1) / p.ca.fps) + 1], false
  local x, y, sp_sz_x, sp_sz_y = p.x, p.y, 1, 1

  if type(sp) == "table" then
    bd_id, hd_id, hd_x_adjustment, hd_y_adjustment, flip_bd_x, flip_bd_y, flip_hd_x, flip_hd_y = sp[1], sp[2], sp[3] or 0, sp[4] or 0, sp[5], sp[6], sp[7], sp[8]
  else
    bd_id, hd_id = sp, 1
  end

  if sub(hd_id, 1, 1) == "d" then
    hd_id, is_dizzy = sub(hd_id, 2), true
  end

  if sub(bd_id, 1, 1) == "t" then
    local tiles = tonum(sub(bd_id, 2, 2))
    bd_id = sub(bd_id, 3)
    x, y, hd_x_adjustment, sp_sz_x, sp_sz_y = tiles > 1 and x - (p.facing == backward and sp_w or 0) or x, tiles > 2 and y - sp_h or y, tiles > 1 and hd_x_adjustment - (p.facing == backward and sp_w or 0) or hd_x_adjustment, 2, tiles > 2 and 2 or 1
  end

  if sub(bd_id, 1, 1) == "x" then
    local x_adj = sub(bd_id, 2, 4)
    bd_id = sub(bd_id, 5)
    x += x_adj * p.facing
  end

  if p.facing == backward then
    flip_bd_x, flip_hd_x = not flip_bd_x, not flip_hd_x
  end

  if not is_st_eq(p, "invisible") then
    local hd_x, hd_y, bd_id, hd_id = x + hd_x_adjustment * p.facing, y + hd_y_adjustment, tonum(bd_id), tonum(hd_id)
    local hd_sp, is_halved_hd = hd_id and p.char.hd_sps[hd_id], hd_id == 108 or hd_id == 109

    if is_halved_hd then
      hd_sp = hd_id
    end

    draw_stroke(p, x, y, sp_sz_x, sp_sz_y, bd_id, flip_bd_x, flip_bd_y, hd_sp, hd_x, hd_y, flip_hd_x, flip_hd_y)

    if hd_id then
      if is_st_eq(p, "frozen") then
        shift_pal(frozen_hd_pal_map)
      else
        shift_pal(p.char.hd_pal_map)

        if is_dizzy then
          shift_pal "p37bfe7"
        end

        if is_halved_hd then
          shift_pal "pe8"
        end
      end

      spr(hd_sp, hd_x, hd_y, 1, 1, flip_hd_x, flip_hd_y)
      pal()
    end

    if bd_id then
      if not p.ca.skip_pal_shift then
        shift_pal(is_st_eq(p, "frozen") and frozen_bd_pal_map or p.char.bd_pal_map)
      end

      spr(bd_id, x, y, sp_sz_x, sp_sz_y, flip_bd_x, flip_bd_y)
      pal()
    end
  end

  draw_prts(p)
end

function draw_stroke(p, p_x, p_y, sp_sz_x, sp_sz_y, bd_id, flip_bd_x, flip_bd_y, hd_sp, hd_x, hd_y, flip_hd_x, flip_hd_y)
  shift_pal "p01112131415161718191a1b1c1d1e1f1"

  for axes in all(split "0|-1,-1|-1,-1|0,-1|1,0|1,1|1,1|0,1|-1") do
    local x, y = unpack_split(axes, "|")

    if bd_id then
      spr(bd_id, p_x + x, p_y + y, sp_sz_x, sp_sz_y, flip_bd_x, flip_bd_y)
    end

    if hd_sp then
      spr(hd_sp, hd_x + x, hd_y + y, 1, 1, flip_hd_x, flip_hd_y)
    end
  end

  pal()
end

function draw_pj(p)
  local sps, index = p.pj.sps, flr(p.pj.frames / p.char.pj_fps) + 1

  if index > #sps then
    index, p.pj.frames = 1, 0
  end

  shift_pal(p.char.pj_pal_map)
  spr(sps[index], p.pj.x, p.pj.y, 1, 1, p.pj.flip_x or p.pj.direction == backward)
  pal()

  if p.pj.has_rope then
    local y = p.pj.y + (p.char.pj_h / 2)
    line(p.x + sp_w, y, p.pj.rope_x, y, 4)
  end
end

function draw_prts(p)
  for prt_set in all(p.prt_sets) do
    for prt in all(prt_set.prts) do
      prt.x += prt.speed_x
      prt.y += prt.speed_y
      local hdlr = flr_rnd(2) == 1 and circ or circfill
      hdlr(prt.x, prt.y, prt_set.radius or 0, prt_set.color)
      prt.current_lifespan += 1

      if prt.current_lifespan > prt.max_lifespan then
        del(prt_set.prts, prt)
      end
    end

    if #prt_set.prts == 0 then
      del(p.prt_sets, prt_set)
    end
  end
end

function draw_finishing_mv()
  if cb_round_timers.finishing_mv > round_timers.finishing_mv / 2 then
    draw_blinking_text("finish " .. (cb_round_loser.char.gender == 1 and "him" or "her"))
  end
end

function draw_starting()
  draw_blinking_text(cb_round_timers.starting > round_timers.starting / 2 and "round " .. cb_round or "fight")
end

function draw_finished()
  draw_blinking_text(cb_round_winner and ((cb_round_winner == p1 and "p1" or "p2") .. " wins") or "draw")
end

function draw_new_pl()
  draw_blinking_text "a new challenger has emerged"
end

function draw_time_up()
  draw_blinking_text "time's up"
end