local Level = {}
Level.__index = Level

local Player = require("game.player")
local Iceberg = require("game.iceberg")

function Level:new()
    local instance = {
        player = nil,
        icebergs = {},
        rows = 5,
        rowHeight = 45  
    }
    setmetatable(instance, Level)
    return instance
end


function Level:load()
    local spawnX = love.graphics.getWidth() / 2
    local sueloY = 300
    self.sueloY = sueloY 
    self.spawnY = sueloY - 20
    self.player = Player:new(spawnX, self.spawnY)

    self.icebergs = {}
    for i = 1, self.rows do
        local rowY = sueloY + (i * self.rowHeight)
        local direction = (i % 2 == 0) and "left" or "right"
        for j = 1, 4 do
            local x = j * 150
            table.insert(self.icebergs, Iceberg:new(x, rowY, direction))
        end
    end
end

function Level:update(dt)
    for _, iceberg in ipairs(self.icebergs) do
        iceberg:update(dt)
    end
    self.player:update(dt, self.icebergs, self) 
end

function Level:draw()
    
love.graphics.setColor(0, 0.4, 1, 0.5)
love.graphics.rectangle("fill", 0, self.sueloY, love.graphics.getWidth(), love.graphics.getHeight() - self.sueloY)

    
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(0, self.spawnY + 20, love.graphics.getWidth(), self.spawnY + 20) 

    for _, iceberg in ipairs(self.icebergs) do
        iceberg:draw()
    end
    self.player:draw()
end

return Level
