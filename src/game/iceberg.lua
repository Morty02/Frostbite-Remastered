local Iceberg = {}
Iceberg.__index = Iceberg

function Iceberg:new(x, y, width, height, speed, direction)
    local instance = setmetatable({}, Iceberg)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.speed = speed
    instance.direction = direction
    instance.originalColor = {0.7, 0.85, 0.95, 1}
    instance.usedColor = {0.5, 0.6, 0.7, 1}
    instance.color = instance.originalColor
    instance.isFresh = true
    return instance
end

function Iceberg:useForIgloo()
    if self.isFresh then
        self.isFresh = false
        self.color = self.usedColor
        return true
    end
    return false
end


function Iceberg:update(dt)
    local screenWidth = love.graphics.getWidth()
    if self.direction == "right" then
        self.x = self.x + self.speed * dt
        if self.x > screenWidth then
            self.x = -self.width
        end
    else 
        self.x = self.x - self.speed * dt
        if self.x + self.width < 0 then
            self.x = screenWidth
        end
    end
end

function Iceberg:draw()
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


return Iceberg