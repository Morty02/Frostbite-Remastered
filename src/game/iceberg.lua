local Iceberg = {}
Iceberg.__index = Iceberg

function Iceberg:new(x, y, width, height)
    local instance = setmetatable({}, Iceberg)
    instance.position = {x = x, y = y}
    instance.size = {width = width, height = height}
    return instance
end

function Iceberg:update(dt)

end

function Iceberg:draw()
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.width, self.size.height)
end

return Iceberg