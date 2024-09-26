hero = {}

function hero:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.defeated = false
  obj.hp = 100
  obj.level = 1
  obj.power = 1
  obj.speed = 1
  obj.x = g.max_x / 2
  obj.y = g.max_y / 2
  return obj
end

function hero:draw()
  pset(self.x, self.y, 3)
end

function hero:move(x, backwards)
  self.x += (x or self.speed) * (backwards == true and -1 or 1)
end

function hero:damage(d)
  self.hp -= d
  self.defeated = self.hp <= 0 or false
end

function hero:reset_position()
  self.x = g.max_x / 2
  self.y = g.max_y / 2
end

function hero:level_up()
  self.level += 1
  self.power *= self.level
end