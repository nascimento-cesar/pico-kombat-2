game = {}

function game:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.b = nil
  obj.c = countdown:new()
  obj.dmg_cap = 127 / 2
  obj.dmg_bias = 5
  obj.enemies = {}
  obj.max_x = 127
  obj.max_y = 127
  obj.mode = enums.modes.overworld
  return obj
end

function game:overworld()
  if btnp(🅾️) then
    self:start_battle()
  end
end

function game:start_battle()
  g.b = battle:new(1)
  g.b:setup()
  self.mode = enums.modes.battle
end

function game:battle()
  g.b:resolve()
end