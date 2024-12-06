function hdl_finishing_mv(p, vs)
  local finishing_mv, reac = ccp.finishing_mv, ccp.finishing_mv.reac

  if ccp.has_finishing_mv_started then
    if p.cap.is_dmg_sp and not ccp.has_finishing_mv_hit then
      ccp.has_finishing_mv_hit = true
      ccp.skip_p_rendering = vs.id
      play_sfx(acs.hook.hit_sfx)

      if reac == "decap" then
        setup_finishing_mv_reac(
          vs, split "4,#$n/x4/-2/-1/t/t/t/t|$n/x6/0/-2/t/t/t/t|$n/x4/2/1|$n/x6/0/2|$n/x4/-2/-1/t/t/t/t", split "8,#$51/n|$51/n|$51/n|$51/n|$4/n|$22/n", function(p)
            if not p.should_stop then
              mv_x(p, -1)
              mv_y(p, p.t < 10 and -1 or 1)
              p.should_stop = p.y - 4 >= y_bottom_limit
            end
          end,
          function(p)
            if p.t == 1 or p.t % 4 == 0 then
              if p.t == 1 or p.t <= 32 then
                spill_blood(p)
              elseif p.t <= 40 then
                spill_blood(p, nil, p.y + 1)
              elseif p.t <= 48 then
                spill_blood(p)
              end
            elseif p.t == 41 then
              shift_pl_x(p, -1)
              shift_pl_y(p, 1)
            end
            ccp.has_finishing_mv_ended = p.cap.is_animation_complete
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
        cb_round_state = "finished"
      end
    end
  else
    local x_diff = p.facing == forward and vs.x - (p.x + sp_w) or p.x - (vs.x + sp_w)

    if x_diff > finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = forward }, true)
    elseif x_diff < finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = backward }, true)
    else
      ccp.has_finishing_mv_started = true
      start_ac(p, finishing_mv)
    end
  end
end

function setup_finishing_mv_reac(p, params_1, params_2, clb_1, clb_2)
  local hdl = function(p, i, params, clb)
    if params then
      ccp["tmp_pls_" .. i] = {
        ca = {
          fps = params[1],
          sps = eval_str(params[2]),
          requires_forced_stop = true
        },
        caf = 0,
        cap = {},
        char = p.char,
        clb = clb or function() end,
        facing = p.facing,
        id = i + 10,
        prt_sets = {},
        st_timers = p.st_timers,
        t = 0,
        x = p.x,
        y = p.y
      }
    end
  end

  hdl(p, 1, params_1, clb_1)
  hdl(p, 2, params_2, clb_2)
end