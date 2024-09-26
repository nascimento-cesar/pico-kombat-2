countdown = {}

function countdown:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.t = 30.0
  obj.t0 = time()
  return obj
end

function countdown:draw()
  print(self.t, 0, 0, 7)
end

function countdown:update()
  self.t = 30.0 - (time() - self.t0)
end