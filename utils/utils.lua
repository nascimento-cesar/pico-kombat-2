function hcenter(s)
  -- screen center minus the
  -- string length times the
  -- pixels in a char's width,
  -- cut in half
  return 64 - #s * 2
end

function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end