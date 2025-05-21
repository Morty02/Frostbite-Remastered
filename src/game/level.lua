local Level = {}
Level.__index = Level

function Level:new()
    local instance = {
        icebergs = {},
        enemies = {},
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
    }
    setmetatable(instance, Level)
    return instance
end

function Level:load()

end

function Level:update(dt)
    for _, iceberg in ipairs(self.icebergs) do
        iceberg:update(dt)
    end
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end
end

function Level:draw()
    for _, iceberg in ipairs(self.icebergs) do
        iceberg:draw()
    end
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

return Level