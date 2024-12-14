function hdl_finishing_mv(p, vs)
  local finishing_mv, reac, s_ac = ccp.finishing_mv, ccp.finishing_mv.reac, ccp.finishing_mv.s_ac

  if ccp.has_finishing_mv_started then
    if (ccp.force_reac or (not s_ac and p.cap.is_dmg_sp)) and not ccp.has_finishing_mv_hit then
      local no_head_sps, sliced_sps, lift_sps, explode_sps = "8,#$51/n|$51/n|$51/n|$51/n|$4/n|$x-03y+0222/n", "4,#$57/d4/-5/0/f/f/t/t|$56/d1/0/1/t/t/t/t|$57/d4/5/0/t/t/f/f|$56/d1/0/-1|$y-0157/d4/-5/0/f/f/t/t", "1,#$23/d1,-1,-2", "6,#$t2x-08140/n|$t2x-08142/n|$t2x-08156/n"
      ccp.has_finishing_mv_hit = true
      ccp.skip_p_rendering = vs.id

      if reac == "chomp" then
        setup_finishing_mv_reac(vs, 37, "16,#$n/n", nil, no_head_sps, reac_drop_dead)
      elseif reac == "explode" then
        setup_finishing_mv_reac(vs, 37, explode_sps, reac_explode)
      elseif reac == "kiss" then
        setup_finishing_mv_reac(
          vs, 41, "1,#$49/d1", function(p)
            if p.t == 32 then
              setup_finishing_mv_reac(p, 37, explode_sps, reac_explode)
            end
          end, "2,#$158/n|$x-01y-01158/n|$x-02y-02158/n|$x-05y-03159/n|$x-06y-04159/n|$x-07y-05159/n|$x-08y-06158/n|$n/n,0,0,t"
        )
      elseif reac == "no_head" then
        setup_finishing_mv_reac(vs, 36, "4,#$n/d4/-2/-1/t/t/t/t|$n/d6/0/-2/t/t/t/t|$n/d4/2/1|$n/d6/0/2|$n/d4/-2/-1/t/t/t/t", reac_propelled, no_head_sps, reac_drop_dead)
      elseif reac == "split" then
        setup_finishing_mv_reac(vs, 40, "32,#$t2152/n|$t2y+01154/n,-4", reac_drop_dead)
      elseif reac == "arms_ripped" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, 37, "36,#$62/d1|$63/d4/-8/2/f/f/t/t", reac_drop_dead, "12,#$x+04y-02181/n", function(p)
            if p.cap.is_animation_complete then
              setup_finishing_mv_reac(p, nil, nil, nil, "4,#$181/n/0/0/t/f|$181/n/0/0/t/t|$181/n/0/0/f/f|$181/n/0/0/f/t|$181/n/0/0/t/f", reac_propelled)
            end
          end
        )
      elseif reac == "ripped" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, 37, "36,#$54/n|$55/n", reac_drop_dead, "12,#$56/d1/n/-1,4,-4", function(p)
            if p.cap.is_animation_complete then
              setup_finishing_mv_reac(p, nil, nil, nil, sliced_sps, reac_propelled)
            end
          end
        )
      elseif reac == "sliced" then
        setup_finishing_mv_reac(vs, 40, "36,#$54/n|$55/n", reac_drop_dead, sliced_sps, reac_propelled)
      elseif reac == "toast" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, 19, "2,#$x-18112/n|$x-16113/n|$x-14114/n|$x-12112/n|$x-10113/n|$x-08114/n|$x-06112/n|$x-04113/n,0,0,t", function(p)
            if p.cap.is_animation_complete then
              ccp.tmp_pls_1, ccp.tmp_pls_2 = nil, nil
              setup_finishing_mv_reac(vs, 39, "2,#$108/n|$109/n|$110/n|$109/n|$108/n|$109/n|$110/n|$109/n|$108/n|$193/n|$193/n|$194/n|$194/n|$195/n|$195/n,0,0,t", reac_drop_dead)
            end
          end, "1,#$49/d1"
        )
        ccp.tmp_pls_1.facing *= -1
      elseif reac == "soul_steal" then
        ccp.draw_over_p = true
        setup_finishing_mv_reac(
          vs, nil, lift_sps, function(p)
            if p.t == 32 then
              setup_finishing_mv_reac(p, 38, "24,#$160/n|$x-01y+03161/n,0,0,t", nil, "4,#$x+01162/n|$x+02163/n|$x+03y+01164/n|$x+04y+01165/n|$x+04y+01166|$x+05y+02166/n|$x+06y+02167/n|$n/n,0,0,t")
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
        p.st_timers.invisible, cb_round_state = 0, "finished"
      end
    end
  else
    local distance, is_limit = get_x_diff(p, vs), is_limit_screen(p.x)

    if distance == finishing_mv.distance then
      ccp.has_finishing_mv_started = true
      start_ac(p, s_ac and p.char.special_atks[s_ac] or finishing_mv)
    elseif is_limit and not ccp.is_fm_adjusting then
      ccp.is_fm_adjusting = is_limit
      setup_next_ac(p, "jump", { direction = forward }, true)
    else
      setup_next_ac(p, "walk", { direction = distance > finishing_mv.distance and forward or backward })
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
  if p.cap.is_animation_complete then
    ccp.has_finishing_mv_ended = true
    p.y = y_bottom_limit
  end
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