local Fish = {}
Fish.__index = Fish

function Fish:new(x, y)
    local instance = setmetatable({}, Fish)
    instance.x = x
    instance.y = y
    instance.width = 18
    instance.height = 12
    instance.speed = 60 + math.random(0,40)
    instance.direction = math.random() < 0.5 and "left" or "right"
    instance.isActive = true
    return instance
end

function Fish:update(dt)
    if self.direction == "right" then
        self.x = self.x + self.speed * dt
        if self.x > love.graphics.getWidth() then self.x = -self.width end
    else
        self.x = self.x - self.speed * dt
        if self.x + self.width < 0 then self.x = love.graphics.getWidth() end
    end
end

function Fish:draw()
    if self.isActive then
        love.graphics.setColor(0.2, 0.7, 1)
        love.graphics.ellipse("fill", self.x + self.width/2, self.y + self.height/2, self.width/2, self.height/2)
        love.graphics.setColor(1,1,1)
    end
end

return Fish