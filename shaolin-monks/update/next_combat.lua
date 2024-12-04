function update_next_combat()
  music(-1, 200)
  local main_player = get_main_player()

  if main_player then
    local next_challenger = get_next_challenger(main_player)
    get_vs(main_player).char = next_challenger
  end

  current_screen = "gameplay"
  define_combat_variables({ 1, time(), round_duration, "starting", nil, { [p1_id] = 0, [p2_id] = 0 }, {} })
  setup_new_round()
end

function get_next_challenger(p)
  local char_id = p.next_combats[1] or 13
  local challenger = chars[char_id]

  if p.char == challenger and #p.next_combats == 12 then
    deli(p.next_combats, 1)
    add(p.next_combats, char_id)

    return get_next_challenger(p)
  end

  return challenger
end