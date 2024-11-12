function shift_pal(pallete)
  pallete = sub(pallete or "p", 2)

  for i = 1, #pallete, 2 do
    pal(
      tonum("0x0" .. sub(pallete, i, i)),
      tonum("0x0" .. sub(pallete, i + 1, i + 1))
    )
  end
end

function draw_blinking_text(s)
  print(s, get_hcenter(s), get_vcenter(), get_blinking_color())
end

function draw_debug()
  local i = 1

  for k, v in pairs(debug) do
    local s = ""

    if type(v) == "table" then
      for v2 in all(v) do
        if type(v2) == "boolean" then
          v2 = v2 and "true" or "false"
        end

        if s ~= "" then
          s = s and s .. ", " .. v2 or v2
        else
          s = v2
        end
      end
    else
      if type(v) == "boolean" then
        v = v and "true" or "false"
      end

      s = v
    end

    print(k .. ": " .. s, 0, (i - 1) * 10, 7)

    i += 1
  end
end

function get_blinking_color(c1, c2, s)
  c1, c2, s = c1 or 7, c2 or 8, s or 4

  return sin(time() * s) > 0 and c1 or c2
end

function get_hcenter(s)
  return 64 - (s and #tostr(s) or 0) * 2
end

function get_vcenter()
  return 61
end