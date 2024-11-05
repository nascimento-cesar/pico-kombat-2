function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end

function foreach_player(callback)
  for p in all { p1, p2 } do
    callback(p)
  end
end