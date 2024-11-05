function get_blinking_color(c1, c2, s)
  c1 = c1 or 7
  c2 = c2 or 8
  s = s or 4

  return sin(time() * s) > 0 and c1 or c2
end

function get_hcenter(s)
  return 64 - (s and #tostr(s) or 0) * 2
end

function get_vcenter()
  return 61
end