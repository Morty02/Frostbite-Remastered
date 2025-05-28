local Bird = {}
Bird.__index = Bird

function Bird:new(x, y, direction)
    local instance = setmetatable({}, Bird)
    instance.x = x
    instance.y = y
    instance.width = 28
    instance.height = 18
    instance.speed = 120 + math.random(0,40)
    instance.direction = direction or (math.random() < 0.5 and "left" or "right")
    instance.isActive = true
    return instance
end

function Bird:update(dt)
    if self.direction == "right" then
        self.x = self.x + self.speed * dt
        if self.x > love.graphics.getWidth() then self.x = -self.width end
    else
        self.x = self.x - self.speed * dt
        if self.x + self.width < 0 then self.x = love.graphics.getWidth() end
    end
end

function Bird:draw()
    if self.isActive then
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.polygon("fill", 
            self.x, self.y + self.height/2,
            self.x + self.width/2, self.y,
            self.x + self.width, self.y + self.height/2,
            self.x + self.width/2, self.y + self.height
        )
        love.graphics.setColor(1,1,1)
    end
end

return Bird