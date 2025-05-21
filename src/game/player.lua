local Player = {}
Player.__index = Player

function Player:new(x, y, speed)
    local instance = setmetatable({}, Player)
    instance.x = x or 0
    instance.y = y or 0
    instance.speed = speed or 200
    return instance
end

function Player:move(dx, dy, dt)
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function Player:jump()

end

function Player:draw()
    love.graphics.setColor(1, 1, 1) 
    love.graphics.rectangle("fill", self.x, self.y, 32, 32) 
end

return Player