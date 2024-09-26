battle = {}

function battle:new(level)
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.enemies = {}
  obj.level = level
  return obj
end

function battle:draw()
  g.c:draw()
  h:draw()

  for e in all(self.enemies) do
    e:draw()
  end
end

function battle:setup()
  for i = 1, 2 do
    local x = g.max_x / 2 + 40 + i * 8
    local y = g.max_y / 2
    local e = enemy:new(x, y, 1)
    add(self.enemies, e)
  end
end

function battle:resolve()
  h:move()

  for e in all(self.enemies) do
    e:move()

    local pwr_ratio = h.power / e.power

    if h.x >= e.x then
      e:damage(h.power)
      h:damage(e.power)

      if e.defeated then
        del(self.enemies, e)
      else
        if pwr_ratio > 1 then
          e:move(min(pwr_ratio * g.dmg_bias, g.dmg_cap), true)
        elseif pwr_ratio < 1 then
          h:move(min(g.dmg_bias / pwr_ratio, g.dmg_cap), true)
        else
          h:move(g.dmg_bias * 2, true)
          e:move(g.dmg_bias * 2, true)
        end
      end
    end
  end

  if h.x > g.max_x or #self.enemies == 0 then
    self:victory()
  elseif h.x < 0 or h.defeated then
    self:defeat()
  end
end

function battle:defeat()
  self:finish()
end

function battle:victory()
  self:finish()
end

function battle:finish()
  h:reset_position()
  h:level_up()
  g.battle = nil
  g.mode = enums.modes.overworld
end