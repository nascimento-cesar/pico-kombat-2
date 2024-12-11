function hdl_special_atk(p)
  local vs, hdlr, params = get_vs(p), unpack_split(p.ca.hdlr, "#")

  if hdlr == "st_morph" then
    if not is_st_eq(p, "morphed") then
      p.is_morphed, p.st_timers.morphed, p.char = true, 300, chars[tonum(params)]
    end

    return
  end

  string_to_hash(
    "pj,slide,bk_blade_fury,jc_high_green_bolt,jc_nut_cracker,jc_shadow_kick,jc_uppercut,jx_back_breaker,jx_gotcha,jx_ground_pound,kl_diving_kick,kl_hat_toss,kl_spin,kl_teleport,kn_fan_lift,kn_flying_punch,lk_bicycle_kick,lk_flying_kick,ml_ground_roll,ml_teleport_kick,rd_electric_grab,rd_teleport,rd_torpedo,rp_force_ball,rp_invisibility,sc_spear,sc_teleport_punch,sk_pj,sk_sledgehammer,sz_freeze", {
      pj,
      slide,
      function(p, vs)
        if p.t >= get_total_frames(p, 3) then
          finish_ac(p)
        else
          atk(
            p,
            function(p, vs)
              p.t = 0
              mv_x(vs, -1)
              mv_y(vs, -1)
            end,
            function(p, vs)
              if p.t >= get_total_frames(p, 3) then
                finish_ac(vs)
                setup_next_ac(p, "thrown_backward", nil, true)
              elseif p.t % 5 == 0 then
                spill_blood(p)
              end
            end
          )
        end
      end,
      function(p)
        create_pj(
          p, nil, function(p)
            if p.pj.top_height_reached then
              p.pj.y *= 1.05
            else
              p.pj.y /= 1.05
              p.pj.top_height_reached = p.pj.y <= y_upper_limit
            end
          end
        )
      end,
      function(p)
        if p.t >= get_total_frames(p, 4) then
          finish_ac(p)
        else
          atk(p)
        end
      end,
      function(p)
        slide(p, nil, 3, 10)
      end,
      function(p)
        if p.cap.top_height_reached then
          if not is_timer_active(p.cap, "delay", 3) then
            setup_next_ac(p, "jump", nil, true)
          end
        else
          atk(p)
          mv_x(p, offensive_speed)
          mv_y(p, -offensive_speed)
          p.cap.top_height_reached = p.y <= y_upper_limit
        end
      end,
      function(p, vs)
        p.cap.skip_sfx = true
        atk(
          p, function(p, vs)
            vs.y = p.y - (vs.caf > 8 and 5 or 6)
            vs.x = p.x
          end,
          function(p, vs)
            if p.caf == 12 then
              play_sfx(vs.ca.hit_sfx)
            end
          end
        )
        if not p.cap.has_hit then
          setup_next_ac(p, "jump", p.cap, true)
        end
      end,
      function(p, vs)
        if vs.hp <= 0 then
          finish_ac(p)
          setup_next_ac(vs, "fainted", nil, true)
        elseif p.cap.has_hit then
          if not is_timer_active(p.cap, "delay", 15) or p.cap.skip_delay then
            p.cap.punches, p.cap.max_punches = p.cap.punches or 1, p.cap.max_punches or 2
            local is_last_punch = p.cap.punches >= p.cap.max_punches
            if p.t >= get_total_frames(p, 1) then
              setup_next_ac(
                p, "punch", {
                  is_x_shiftable = 0,
                  skip_reac = not is_last_punch,
                  next_ac = is_last_punch and acs.idle or p.char.special_atks["gotcha"],
                  next_ac_params = is_last_punch and {} or { punches = p.cap.punches + 1, skip_delay = true, skip_sfx = true },
                  reac = is_last_punch and "thrown_backward"
                }, true
              )
            end
          end
        else
          if p.t >= get_total_frames(p, 2) and vs.ca ~= acs.grabbed then
            finish_ac(p)
          else
            atk(p)
          end
        end
      end,
      function(p, vs)
        if p.t >= get_total_frames(p, 4) then
          finish_ac(p)
        else
          atk(
            p,
            nil,
            function(p)
              mv_x(p, -1)
              if p.t >= get_total_frames(p, 2) then
                finish_ac(p)
              end
            end,
            nil,
            function(p, vs)
              return vs.y == y_bottom_limit
            end
          )
        end
      end,
      function(p)
        setup_next_ac(
          p,
          "jump_kick",
          {
            direction = forward,
            is_landing = true,
            x_speed = offensive_speed,
            block_clb = function(p)
              setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
            end
          },
          true
        )
      end,
      function(p)
        create_pj(
          p,
          nil,
          nil,
          nil,
          function(p)
            ccp.force_reac = true
            destroy_pj(p)
          end
        )
      end,
      function(p)
        local total_frames = get_total_frames(p)
        if p.t >= total_frames * 2 then
          finish_ac(p)
        else
          atk(p)
        end
      end,
      function(p, vs)
        teleport(
          p,
          vs,
          "jump",
          nil,
          function(p, vs)
            p.x = vs.x - sp_w * vs.facing
            p.facing *= -1
            fix_pls_orientation()
          end
        )
      end,
      function(p)
        create_pj(
          p,
          30,
          function(p)
            p.pj.x_speed = 0
          end,
          nil,
          function() end,
          function(p)
            local total_frames = get_total_frames(p)
            if p.t >= total_frames * 5 then
              setup_next_ac(p, "fall", nil, true)
            elseif p.t < total_frames then
              mv_x(p, -1)
              mv_y(p, -1)
            end
          end
        )
      end,
      function(p)
        atk(p, finish_ac)
        if p.cap.top_height_reached then
          set_current_ac_animation_lock(p, false)
          if p.t >= get_total_frames(p, 8) then
            if not is_timer_active(p.cap, "delay", 3) then
              setup_next_ac(p, "jump", nil, true)
            end
          else
            mv_x(p, offensive_speed * 1.5)
          end
        else
          set_current_ac_animation_lock(p, true)
          mv_y(p, -offensive_speed * 1.5)
          p.cap.top_height_reached = p.y <= y_upper_limit + sp_h
        end
      end,
      function(p, vs)
        local total_frames = get_total_frames(p)
        if p.t < 3 then
          p.y -= 1
        end
        if p.cap.has_hit then
          if vs.t >= total_frames * 3 then
            finish_ac(p)
            finish_ac(vs)
            p.y = y_bottom_limit
          else
            mv_x(p, offensive_speed / 2)
            mv_x(vs, -offensive_speed / 2)
          end
        else
          if p.t >= total_frames * 2 then
            finish_ac(p)
          else
            mv_x(p, offensive_speed)
            atk(
              p,
              nil,
              nil,
              function(p)
                setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
              end
            )
          end
        end
      end,
      function(p)
        slide(p, nil, 5, 10)
      end,
      function(p)
        slide(
          p, nil, 3, nil, true, function(p)
            setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
          end
        )
      end,
      function(p, vs)
        teleport(
          p,
          vs,
          "jump_kick",
          {
            is_landing = true,
            block_clb = function(p)
              setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
            end
          },
          function(p, vs)
            p.x = vs.x + ((sp_w * vs.facing) / 2)
            p.y = y_upper_limit
          end
        )
      end,
      function(p, vs)
        if not p.cap.has_hit and p.t >= get_total_frames(p, 3) then
          finish_ac(p)
        else
          atk(
            p, nil, function(p, vs)
              p.cap.skip_reac = ccp.finishing_mv
              if p.t >= get_total_frames(p, 4) then
                finish_ac(vs)
                setup_next_ac(p, "fall", nil, true)
                ccp.force_reac = true
              elseif p.t < 3 then
                mv_x(p, -1)
                mv_y(p, -1)
              end
            end
          )
        end
      end,
      function(p, vs)
        teleport(
          p, vs, "idle", nil, function(p, vs)
            p.x = vs.x - sp_w * vs.facing
            p.y = y_bottom_limit
            p.facing *= -1
            fix_pls_orientation()
          end
        )
      end,
      function(p, vs)
        if not p.cap.has_hit and p.t >= get_total_frames(p, 2) then
          finish_ac(p)
        else
          p.cap.skip_sfx = true
          mv_x(p, offensive_speed)
          atk(
            p,
            nil,
            function(p, vs)
              if is_limit_left(p.x) or is_limit_right(p.x) then
                play_sfx(vs.ca.hit_sfx)
                setup_next_ac(vs, "jump", { direction = backward }, true)
                setup_next_ac(p, "fall", nil, true)
              else
                mv_x(p, -offensive_speed)
              end
            end,
            function(p)
              setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
            end
          )
        end
      end,
      function(p)
        create_pj(
          p, 90, function(p)
            p.pj.x_speed = 0.5
          end
        )
      end,
      function(p)
        if p.t >= get_total_frames(p) and p.st_timers.invisible == 0 then
          p.st_timers.invisible = 300
        end
      end,
      function(p)
        create_pj(
          p,
          nil,
          function(p)
            p.pj.has_rope = true
            p.pj.rope_x = p.pj.direction == forward and p.pj.x or p.pj.x + 6
          end,
          nil,
          function(p)
            p.pj.x_speed = 0
          end,
          function(p, vs)
            if p.t >= get_total_frames(p, 10) then
              if has_collision(p.x, p.y, vs.x, vs.y, nil, 12, 12, 12, 12) then
                finish_ac(vs)
                setup_next_ac(p, "stumble", nil, true)
                destroy_pj(vs)
                p.cap.reac_clb = function(p)
                  if p.t >= get_total_frames(p, 4) then
                    finish_ac(p)
                  end
                end
              else
                vs.pj.x += offensive_speed * p.facing
                mv_x(p, offensive_speed)
              end
            end
          end
        )
      end,
      function(p)
        if not p.cap.has_teleported then
          if not p.cap.has_changed_orientation then
            p.facing *= -1
            p.cap.has_changed_orientation = true
          end
          if not is_limit_left(p.x) and not is_limit_right(p.x) then
            mv_x(p, offensive_speed)
          else
            p.cap.has_teleported = true
            p.x = is_limit_left(p.x) and map_max_x or map_min_x
            p.y = y_upper_limit
          end
        else
          setup_next_ac(
            p,
            "jump_punch",
            {
              is_landing = true, direction = forward, x_speed = offensive_speed, block_clb = function(p)
                setup_next_ac(p, "jump", { blocks_aerial_acs = true }, true)
              end
            },
            true
          )
        end
      end,
      function(p)
        create_pj(
          p, nil, function(p)
            p.pj.x_speed = pj_speed * 1.5
          end
        )
      end,
      function(p)
        create_pj(
          p, nil, function(p)
            p.pj.x_speed = 0
          end,
          function(p)
            local total_frames = get_total_frames(p)
            if p.pj.t > 21 then
              destroy_pj(p)
              finish_ac(p)
            else
              local t = p.pj.t
              if t <= 3 then
                p.pj.sps, p.pj.x, p.pj.y, p.pj.flip_x = { 126 }, p.x - 4, p.y - 5, true
              elseif t <= 6 then
                p.pj.sps, p.pj.x, p.pj.y, p.pj.flip_x = { 125 }, p.x + 2, p.y - 6, false
              elseif t <= 9 then
                p.pj.sps, p.pj.x, p.pj.y = { 126 }, p.x + 8, p.y - 5
              else
                p.pj.sps, p.pj.x, p.pj.y = { 127 }, p.x + 8, p.y - 1
              end
            end
          end,
          function(p) end
        )
      end,
      function(p)
        create_pj(
          p, nil, nil, nil, function(p, vs)
            if ccp.finishing_mv then
              ccp.force_reac, p.pj.params.skip_reac = true, true
            else
              if not is_st_eq(vs, "frozen") then
                vs.st_timers.frozen = ccp.is_sz_f1_1_done and 2400 or 60
              else
                vs.st_timers.frozen, p.st_timers.frozen = 0, 60
              end
            end
            destroy_pj(p)
          end
        )
      end
    }
  )[hdlr](
    p, vs
  )
end

function destroy_pj(p)
  p.pj = nil
end

function pj(p)
  create_pj(p)
end

function create_pj(p, max_t, before_clb, after_clb, collision_clb, reac_clb)
  if not p.cap.has_fired_pj and (not p.ca.dmg_sp or (p.ca.dmg_sp and p.cap.is_dmg_sp)) then
    p.pj = p.pj or string_to_hash("ac,after_clb,before_clb,collision_clb,direction,frames,max_t,params,reac_clb,sps,x,y", { p.ca, after_clb, before_clb, collision_clb, p.facing, 0, max_t, p.cap, reac_clb, p.char.pj_sps, p.x + sp_w * p.facing, p.y + 5 - ceil(p.char.pj_h / 2) })
    p.cap.has_fired_pj = true
  end
end

function update_pj(p)
  if cb_round_state == "finished" then
    destroy_pj(p)
  end

  if p.pj then
    local vs, ac, params = get_vs(p), p.pj.ac, p.pj.params

    p.pj.t = (p.pj.t or 0) + 1

    if p.pj.before_clb then
      p.pj.before_clb(p, vs)
    end

    p.pj.x += (p.pj.x_speed or pj_speed) * p.pj.direction
    p.pj.frames += 1

    if not p.pj.has_hit and not p.pj.has_blocked and has_collision(p.pj.x, p.pj.y, vs.x, vs.y, nil, 6) then
      if vs.ca == acs.block then
        p.pj.has_blocked = true
        play_sfx(acs.block.hit_sfx)
        deal_damage(vs, 1)
        destroy_pj(p)
      else
        if p.pj.ac.hit_sfx then
          play_sfx(p.pj.ac.hit_sfx)
        end

        p.pj.has_hit = true
        hit(ac, params, vs)
        vs.cap.reac_clb = p.pj.reac_clb

        if p.pj.collision_clb then
          p.pj.collision_clb(p, vs)
        else
          destroy_pj(p)
        end
      end
    elseif is_limit_right(p.pj.x) or is_limit_left(p.pj.x) or (p.pj.y > y_bottom_limit + sp_h * 2) then
      destroy_pj(p)
    end

    if p.pj and p.pj.after_clb then
      p.pj.after_clb(p, vs)
    end

    if p.pj and p.pj.max_t and p.pj.t > p.pj.max_t then
      destroy_pj(p)
    end

    if not p.pj and p.ca.requires_forced_stop and not p.ca.is_aerial then
      finish_ac(p)
    end
  end
end

function slide(p, _, cycles, delay, ignore_collision, block_clb)
  if (p.cap.has_hit and not ignore_collision) or p.t >= get_total_frames(p, cycles or 3) then
    if not is_timer_active(p.cap, "delay", delay or 0) then
      finish_ac(p)
    end
  else
    if not p.cap.has_hit or ignore_collision then
      mv_x(p, offensive_speed)
    end

    atk(p, nil, nil, block_clb)
  end
end

function teleport(p, vs, next_ac_name, next_ac_params, teleport_clb)
  if not p.cap.has_teleported then
    if p.y < y_bottom_limit + (sp_h * 2) + stroke_width then
      mv_y(p, jump_speed)
    else
      p.cap.has_teleported = true
      teleport_clb(p, vs)
    end
  else
    setup_next_ac(p, next_ac_name, next_ac_params, true)
  end
end