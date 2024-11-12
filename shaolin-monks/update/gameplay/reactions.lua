function flinch(p)
  if not is_action_eq(p, "flinch") then
    start_action(p, actions.flinch)
    move_x(p, -flinch_speed)
  end
end

function frozen(p)
  if p.frozen_timer <= 0 then
    p.frozen_timer = 60
  else
    p.frozen_timer = 0
    frozen(get_vs(p))
  end
end

function propelled(p)
  if not is_action_eq(p, "propelled") then
    start_action(p, actions.propelled, { direction = backward })
  end
end

function swept(p)
  if not is_action_eq(p, "swept") then
    move_x(p, -swept_speed)
    start_action(p, actions.swept)
  end
end