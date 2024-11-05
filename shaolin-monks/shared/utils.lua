function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end