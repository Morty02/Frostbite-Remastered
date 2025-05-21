local Player = require("game.player")
local Iceberg = require("game.iceberg")

local player
local iceberg

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    player = Player:new(100, 300)
    iceberg = Iceberg:new(80, 350, 100, 30)
end

function love.update(dt)

end

function love.draw()
    iceberg:draw()
    player:draw()
end

function love.keypressed(key)

end

function love.keyreleased(key)
end