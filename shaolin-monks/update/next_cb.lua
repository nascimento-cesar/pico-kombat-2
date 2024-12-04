function update_next_cb()
  music(-1, 200)
  local main_pl = get_main_pl()

  if main_pl then
    local next_challenger = get_next_challenger(main_pl)
    get_vs(main_pl).char = next_challenger
  end

  current_screen = "gameplay"
  define_cb_variables({ 1, time(), round_duration, "starting", nil, { [p1_id] = 0, [p2_id] = 0 }, {} })
  setup_new_round()
end

function get_next_challenger(p)
  local char_id = p.next_cbs[1] or 13
  local challenger = chars[char_id]

  if p.char == challenger and #p.next_cbs == 12 then
    deli(p.next_cbs, 1)
    add(p.next_cbs, char_id)

    return get_next_challenger(p)
  end

  return challenger
end