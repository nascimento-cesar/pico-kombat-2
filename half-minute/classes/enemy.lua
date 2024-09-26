enemy = {}

function enemy:new(x, y, level)
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.defeated = false
  obj.hp = level * 10
  obj.level = level
  obj.power = level
  obj.speed = level
  obj.x = x
  obj.y = y
  return obj
end

function enemy:draw()
  pset(self.x, self.y, 2)
end

function enemy:move(x, backwards)
  self.x -= (x or self.speed) * (backwards == true and -1 or 1)
end

function enemy:damage(d)
  self.hp -= d
  self.defeated = self.hp <= 0 or false
end