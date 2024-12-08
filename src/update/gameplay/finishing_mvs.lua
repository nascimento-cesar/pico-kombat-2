function hdl_finishing_mv(p, vs)
  local finishing_mv, reac, pj_ac = ccp.finishing_mv, ccp.finishing_mv.reac, ccp.finishing_mv.pj

  if ccp.has_finishing_mv_started then
    if ((not pj_ac and p.cap.is_dmg_sp) or (pj_ac and ccp.has_hit_pj)) and not ccp.has_finishing_mv_hit then
      local no_head_sps, sliced_sps, lift_sps = "8,#$51/n|$51/n|$51/n|$51/n|$4/n|$x-03y+0222/n", "4,#$57/d4/-5/0/f/f/t/t|$56/d1/0/1/t/t/t/t|$57/d4/5/0/t/t/f/f|$56/d1/0/-1|$y-0157/d4/-5/0/f/f/t/t", "1,#$23/d1,-1,-2"
      ccp.has_finishing_mv_hit = true
      ccp.skip_p_rendering = vs.id

      if reac == "chomp" then
        setup_finishing_mv_reac(vs, 37, "16,#$n/n", nil, no_head_sps, reac_drop_dead)
      elseif reac == "explode" then
        setup_finishing_mv_reac(vs, 37, "6,#$t2x-08140/n|$t2x-08142/n|$t2x-08156/n", reac_explode)
      elseif reac == "no_head" then
        setup_finishing_mv_reac(vs, 36, "4,#$n/d4/-2/-1/t/t/t/t|$n/d6/0/-2/t/t/t/t|$n/d4/2/1|$n/d6/0/2|$n/d4/-2/-1/t/t/t/t", reac_propelled, no_head_sps, reac_drop_dead)
      elseif reac == "halved" then
        setup_finishing_mv_reac(vs, 37, "32,#$t2152/n|$t2y+01154/n,-4", reac_drop_dead)
      elseif reac == "ripped" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, 37, "36,#$54/n|$55/n", reac_drop_dead, "12,#$56/d1/n/-1,4,-4", function(p)
            if p.cap.is_animation_complete then
              setup_finishing_mv_reac(p, nil, nil, nil, sliced_sps, reac_propelled)
            end
          end
        )
      elseif reac == "soul_steal" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, 37, lift_sps, function(p)
            if p.t == 32 then
              setup_finishing_mv_reac(p, nil, "24,#$160/n|$x-01y+03161/n,0,0,t", nil, "4,#$x+02162/n|$x+03163/n|$x+04164/n|$x+04y+01165|$x+05y+02165/n|$x+06y+02166/n|$n/n,0,0,t")
            end
          end
        )
      end
    end

    if ccp.has_finishing_mv_hit then
      local tmp_pls_1, tmp_pls_2 = ccp.tmp_pls_1, ccp.tmp_pls_2

      update_pl(tmp_pls_1)
      tmp_pls_1.clb(tmp_pls_1)

      if tmp_pls_2 then
        update_pl(tmp_pls_2)
        tmp_pls_2.clb(tmp_pls_2)
      end

      if ccp.has_finishing_mv_ended then
        p.st_timers.invisible = 0
        cb_round_state = "finished"
      end
    end
  else
    local x_diff = flr(p.facing == forward and vs.x - (p.x + sp_w) or p.x - (vs.x + sp_w))

    if x_diff > finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = forward }, true)
    elseif x_diff < finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = backward }, true)
    else
      ccp.has_finishing_mv_started = true
      start_ac(p, pj_ac and p.char.special_atks[pj_ac] or finishing_mv)
    end
  end
end

function setup_finishing_mv_reac(p, sfx_id, params_1, clb_1, params_2, clb_2)
  local hdl = function(p, i, params, clb)
    if params then
      fps, sps, x_inc, y_inc, skip_pal_shift = unpack_split(params)

      if sfx_id then
        play_sfx(sfx_id)
      end

      ccp["tmp_pls_" .. i] = string_to_hash(
        "ca,caf,cap,char,clb,facing,id,prt_sets,st_timers,t,x,y", { { fps = fps, sps = eval_str(sps), requires_forced_stop = true, skip_pal_shift = eval_str(skip_pal_shift) }, 0, {}, p.char, clb or function() end, p.facing, i + 10, {}, p.st_timers, 0, p.x + (x_inc or 0) * p.facing, p.y + (y_inc or 0) }
      )
    end
  end

  hdl(p, 1, params_1, clb_1)
  hdl(p, 2, params_2, clb_2)
end

function reac_drop_dead(p)
  if p.t == 1 or p.t % 4 == 0 then
    spill_blood(p)
  end
  ccp.has_finishing_mv_ended = p.cap.is_animation_complete
end

function reac_explode(p)
  p.st_timers.frozen = 0
  for i = 1, 5 do
    reac_drop_dead(p)
  end
end

function reac_propelled(p)
  if not p.should_stop then
    mv_x(p, -1, nil)
    mv_y(p, p.t < 10 and -1 or 1)
    p.should_stop = p.y - 4 >= y_bottom_limit
  end
end