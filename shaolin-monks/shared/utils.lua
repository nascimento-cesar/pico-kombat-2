function any_match(arr, val)
  arr = type(arr) == "string" and split(arr) or arr

  for item in all(arr) do
    if item == val then
      return true
    end
  end

  return false
end

function eval_str(v)
  if v == "true" then
    return true
  elseif v == "false" then
    return false
  elseif sub(v, 1, 1) == "#" then
    return split_sprites(sub(v, 2))
  elseif sub(v, 1, 1) == "*" then
    return ({
      a = { attack, fire_projectile, flinch, walk, lk_flying_kick, lk_bicycle_kick, stumble },
      r = { flinch, propelled_up, swept, frozen, propelled_back, stumble }
    })[sub(v, 2, 2)][tonum(sub(v, 3))]
  elseif v ~= "nil" then
    return v
  end
end

function foreach_player(callback)
  for p in all { p1, p2 } do
    local vs = get_vs(p)
    callback(p, p.id, vs, vs.id)
  end
end

function function_from_hash(keys, values, key)
  local f = string_to_hash(keys, values)[key]
  return f and f()
end

function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end

  return obj1
end

function split_sprites(s, separator)
  local s = split(s, separator or "|")

  for i, v in ipairs(s) do
    s[i] = sub(v, 1, 1) == "$" and split_sprites(sub(v, 2), "/") or eval_str(v)
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