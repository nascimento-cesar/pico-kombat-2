function eval_str(v)
  if v == "t" then
    return true
  elseif v == "f" then
    return false
  elseif sub(v, 1, 1) == "#" then
    return split_sps(sub(v, 2))
  elseif v ~= "n" then
    return v
  end
end

function flr_rnd(n)
  return flr(rnd(n))
end

function foreach_pl(clb)
  for p in all { p1, p2 } do
    local vs = get_vs(p)
    clb(p, p.id, vs, vs.id)
  end
end

function function_lookup(keys, values, key)
  local f = string_to_hash(keys, values)[key]
  return f and f()
end

function split_sps(s, separator)
  local s = split(s, separator or "|")

  for i, v in ipairs(s) do
    s[i] = sub(v, 1, 1) == "$" and split_sps(sub(v, 2), "/") or eval_str(v)
  end

  return s
end

function string_to_hash(keys, values, obj)
  local obj, values = obj or {}, split(values) or values

  for i, k in ipairs(split(keys) or keys) do
    obj[k] = eval_str(values[i])
  end

  return obj
end

function unpack_split(s, separator, convert)
  return unpack(split(s, separator, convert and true))
end

function play_sfx(id, channel)
  local channel = channel or 2
  sfx(-1, 50 + channel)
  sfx(id, channel)
end