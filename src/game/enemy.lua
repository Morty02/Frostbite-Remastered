local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x, y, type)
    local instance = setmetatable({}, Enemy)
    instance.x = x
    instance.y = y
    instance.type = type
    instance.speed = 100  
    return instance
end

function Enemy:update(dt)
    self.x = self.x - self.speed * dt 
end

function Enemy:draw()
    -- Draw the enemy based on its type
    if self.type == "polar_bear" then
        love.graphics.setColor(1, 1, 1)  
        love.graphics.rectangle("fill", self.x, self.y, 30, 30)  
    elseif self.type == "snow_goose" then
        love.graphics.setColor(0, 0, 0)  
        love.graphics.rectangle("fill", self.x, self.y, 20, 20)  
    end
end

return Enemy