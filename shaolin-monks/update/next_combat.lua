function update_next_combat()
  foreach_player(function(p, _, vs)
    if not vs.character then
      vs.character = get_next_challenger(p)
    end
  end)
  current_screen = "gameplay"
  define_combat_variables({ (combat_stage or 0) + 1 or 1, 1, nil, time(), "countdown", nil, { [p1_id] = 0, [p2_id] = 0 }, {} })
  setup_new_round()
end

function get_next_challenger(p)
  local challenger = characters[p.next_combats[1]]
  deli(p.next_combats, 1)

  if p.character == challenger then
    return get_next_challenger(p)
  end

  return challenger
end