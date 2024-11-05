function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end

function foreach_player(callback)
  for p in all { p1, p2 } do
    local vs = get_vs(p)
    callback(p, p.id, vs, vs.id)
  end
end