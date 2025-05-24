local Level = require("game.level")

function love.load()
    love.window.setTitle("Frostbite Remaster")
    level = Level:new()
    level:load()
end

function love.update(dt)
    level:update(dt)
end

function love.draw()
    level:draw()
end
