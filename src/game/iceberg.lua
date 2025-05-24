local Iceberg = {}
Iceberg.__index = Iceberg

function Iceberg:new(x, y, direction)
    local instance = {
        x = x,
        y = y,
        width = 60,
        height = 20,
        speed = 50,
        direction = direction or "right"
    }
    setmetatable(instance, Iceberg)
    return instance
end

function Iceberg:update(dt)
    if self.direction == "right" then
        self.x = self.x + self.speed * dt
        if self.x > love.graphics.getWidth() then
            self.x = -self.width
        end
    else
        self.x = self.x - self.speed * dt
        if self.x < -self.width then
            self.x = love.graphics.getWidth()
        end
    end
end

function Iceberg:draw()
    love.graphics.setColor(0.7, 0.9, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Iceberg
