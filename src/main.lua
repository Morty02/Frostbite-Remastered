local Player = require("game.player")
local Iceberg = require("game.iceberg")
local Fish = require("game.fish")
local Bird = require("game.enemy")


local player
local rowsData = {} 
local numRows = 6 
local screenWidth, screenHeight
local riverBackgroundColor = {0.1, 0.3, 0.7, 1} 

local gameState = "loading" 

local icebergBaseHeight = 25
local verticalSpacingBetweenRows 



local levelAreaHeightRatio = 0.5

function getRowSurfaceY(rowIndex)
    
    local levelAreaTop = screenHeight * (1 - levelAreaHeightRatio)
    local levelAreaHeight = screenHeight * levelAreaHeightRatio
    if numRows > 1 then
        verticalSpacingBetweenRows = levelAreaHeight / (numRows - 1)
    else
        verticalSpacingBetweenRows = levelAreaHeight
    end
    return levelAreaTop + ((rowIndex - 1) * verticalSpacingBetweenRows)
end


local bear = {
    width = 50,
    height = 35,
    speed = 100,
    x = 0, 
    y = 0, 
    direction = "left",
    chasing = false
}

local function resetBearPosition()
    bear.x = screenWidth - bear.width
    bear.y = rowsData[1].y - bear.height
    bear.direction = "left"
    bear.chasing = false
end

local fishRows = {}

local function initializeFishRows()
    fishRows = {}
    
    for i = 2, numRows do
        local y1 = getRowSurfaceY(i-1)
        local y2 = getRowSurfaceY(i)
        
        local fishY = y1 + (y2 - y1) / 2
        table.insert(fishRows, fishY)
    end
end


function initializeGame()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    rowsData = {}
    math.randomseed(os.time())

    local numIcebergsPerRow = 4
    local icebergWidthRatio = 0.15 
    local icebergWidth = screenWidth * icebergWidthRatio
    local gapWidth = (screenWidth - (numIcebergsPerRow * icebergWidth)) / (numIcebergsPerRow + 1)
    local oddSpeed = 60
    local evenSpeed = 60

    for i = 1, numRows do
        local currentRowY = getRowSurfaceY(i)
        if i == 1 then
            rowsData[i] = { y = currentRowY, platform = true }
        else
            rowsData[i] = { y = currentRowY, icebergs = {} }
            local direction = (i % 2 == 0) and "left" or "right"
            local speed = (i % 2 == 0) and evenSpeed or oddSpeed
            for j = 1, numIcebergsPerRow do
                local x = gapWidth + (j - 1) * (icebergWidth + gapWidth)
                table.insert(rowsData[i].icebergs, Iceberg:new(
                    x, currentRowY, icebergWidth, icebergBaseHeight, speed, direction
                ))
            end
        end
    end

    
    local startRowIndex = 1
    local platformWidth = screenWidth 
    local platformX = 0
    local playerX = platformX + platformWidth / 2 - 10 
    local playerY = getRowSurfaceY(startRowIndex) - 20

    player = Player:new(playerX, playerY, startRowIndex)
    player.lives = 3
    player.iglooBlocksCollected = 0
    player.onIceberg = nil
    player.pushing = false
    player.pushDir = nil
    player.pushSpeed = 0
    player.pushTime = 0
    player.pushDuration = 0

    gameState = "playing"

    resetBearPosition()
    initializeFishRows() 
end


function getIcebergsForRow(rowIndex)
    if rowIndex == 1 then
        return {} 
    end
    if rowsData[rowIndex] and rowsData[rowIndex].icebergs then
        return rowsData[rowIndex].icebergs
    end
    return {}
end


function triggerGameOver()
    if gameState == "playing" then
        player.lives = player.lives - 1
        if player.lives > 0 then
            
            temperatureTimer = 0

            
            local startRowIndex = 1
            local platformWidth = screenWidth
            local platformX = 0
            player.currentRow = startRowIndex
            player.targetRow = startRowIndex
            player.y = getRowSurfaceY(startRowIndex) - player.height
            player.x = platformX + platformWidth / 2 - player.width / 2
            player.isJumping = false
            player.onIceberg = nil 
            player.jumpElapsedTime = 0
            player.jumpStartY = 0
            player.jumpTargetY = 0
            player.jumpDuration = 0.2 
            player.jumpElapsedTime = 0
            gameState = "playing"
            resetBearPosition()
        elseif player.lives == 0 then
            gameState = "gameOver"
            love.graphics.print("Game Over! Presiona 'R' para reiniciar.", screenWidth / 2 - 100, screenHeight / 2)
        else
            gameState = "gameOver" 
        end
    end
end

function updateBear(dt)
    local platformY = rowsData[1].y - bear.height
    bear.y = platformY

    
    if player and player.currentRow == 1 and not player.isJumping then
        bear.chasing = true
        
        if math.abs((player.x + player.width/2) - (bear.x + bear.width/2)) > 2 then
            if player.x + player.width/2 < bear.x + bear.width/2 then
                bear.x = bear.x - bear.speed * dt
                bear.direction = "left"
            else
                bear.x = bear.x + bear.speed * dt
                bear.direction = "right"
            end
        end
    else
        bear.chasing = false
        
        if bear.direction == "left" then
            bear.x = bear.x - bear.speed * dt
            if bear.x <= 0 then
                bear.x = 0
                bear.direction = "right"
            end
        else
            bear.x = bear.x + bear.speed * dt
            if bear.x + bear.width >= screenWidth then
                bear.x = screenWidth - bear.width
                bear.direction = "left"
            end
        end
    end

    
    if player and player.currentRow == 1 and not player.isJumping then
        if player.x < bear.x + bear.width and player.x + player.width > bear.x and
           player.y < bear.y + bear.height and player.y + player.height > bear.y then
            triggerGameOver()
        end
    end
end

function love.load()
    love.window.setTitle("Aventura en el Río Helado")
    math.randomseed(os.time())
    initializeGame() 
end

local temperature = 100
local temperatureDecreaseRate = 1 
local temperatureTimer = 0 
local fishSpawnTimer = 0
local fishes = {}
local birds = {}
local birdSpawnTimer = 0

function spawnFish()
    
    local fishRowIndex = math.random(1, #fishRows)
    local y = fishRows[fishRowIndex]
    
    for _, fish in ipairs(fishes) do
        if fish.isActive and math.abs(fish.y - y) < 1 then
            return 
        end
    end
    local direction = math.random() < 0.5 and "left" or "right"
    local x
    if direction == "left" then
        x = screenWidth
    else
        x = 0
    end
    local fish = Fish:new(x, y)
    fish.direction = direction
    table.insert(fishes, fish)
end

function spawnBird()
    local birdRowIndex = math.random(1, #fishRows)
    local y = fishRows[birdRowIndex]
    
    for _, bird in ipairs(birds) do
        if bird.isActive and math.abs(bird.y - y) < 1 then
            return 
        end
    end
    local direction = math.random() < 0.5 and "left" or "right"
    local x = (direction == "left") and screenWidth or 0
    local bird = Bird:new(x, y, direction)
    table.insert(birds, bird)
end

function love.update(dt)
    if gameState == "playing" then
        
        temperatureTimer = temperatureTimer + dt
        if temperatureTimer >= 1 then
            temperature = math.max(0, temperature - temperatureDecreaseRate)
            temperatureTimer = temperatureTimer - 1
        end

        player:update(dt, getIcebergsForRow, triggerGameOver)

        
        if player.pushing then
            local dx = player.pushSpeed * dt * (player.pushDir == "right" and 1 or -1)
            player.x = math.max(0, math.min(player.x + dx, screenWidth - player.width))
            player.pushTime = player.pushTime + dt
            if player.pushTime >= player.pushDuration then
                player.pushing = false
                player.pushDir = nil
                player.pushSpeed = 0
                player.pushTime = 0
                player.pushDuration = 0
            end
        end

        for i = 1, numRows do
            if rowsData[i].icebergs then
                for _, iceberg in ipairs(rowsData[i].icebergs) do
                    iceberg:update(dt)
                end
            end
        end

        fishSpawnTimer = fishSpawnTimer - dt
        if fishSpawnTimer <= 0 then
            spawnFish()
            fishSpawnTimer = 3 + math.random()
        end
        for _, fish in ipairs(fishes) do
            fish:update(dt)
            
            if fish.isActive and player and
                player.x < fish.x + fish.width and player.x + player.width > fish.x and
                player.y < fish.y + fish.height and player.y + player.height > fish.y then
                fish.isActive = false
                temperature = math.min(100, temperature + 20)
                player.score = (player.score or 0) + 100
            end
        end

        birdSpawnTimer = birdSpawnTimer - dt
        if birdSpawnTimer <= 0 then
            spawnBird()
            birdSpawnTimer = 4 + math.random()
        end
        for _, bird in ipairs(birds) do
            bird:update(dt)
            
            if bird.isActive and player and
                player.x < bird.x + bird.width and player.x + player.width > bird.x and
                player.y < bird.y + bird.height and player.y + player.height > bird.y then
                
                
                player.pushing = true
                player.pushDir = bird.direction
                player.pushSpeed = bird.speed
                player.pushTime = 0
                player.pushDuration = 0.5 
            end
        end

        if temperature <= 0 then
            triggerGameOver()
        end

        updateBear(dt)
    elseif gameState == "gameOver" then
        
    end
end

function love.draw()
    
    love.graphics.setColor(unpack(riverBackgroundColor))
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    
    for i = 1, numRows do
        if rowsData[i] and rowsData[i].icebergs then
            for _, iceberg in ipairs(rowsData[i].icebergs) do
                iceberg:draw()
            end
        end
    end

    
    if player then
        player:draw()
    end

    
    local blockW, blockH = 30, 20
    local blocks = player and player.iglooBlocksCollected or 0
    for i = 1, blocks do
        love.graphics.setColor(0.9, 0.9, 1)
        love.graphics.rectangle("fill", 30 + (i-1)*(blockW+5), 60, blockW, blockH)
        love.graphics.setColor(0.7, 0.7, 1)
        love.graphics.rectangle("line", 30 + (i-1)*(blockW+5), 60, blockW, blockH)
    end

    
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", 20, 45, temperature * 2, 15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 20, 45, 200, 15)
    love.graphics.print("Temp: " .. math.floor(temperature), 230, 45)

    
    for _, fish in ipairs(fishes) do
        fish:draw()
    end
        
    for _, bird in ipairs(birds) do
        bird:draw()
    end
    
    love.graphics.setColor(1,1,1)
    love.graphics.print("Puntos: " .. tostring(player.score or 0), 20, 70)

    
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", bear.x, bear.y, bear.width, bear.height)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", bear.x, bear.y, bear.width, bear.height)

    
    if rowsData[1] and rowsData[1].platform then
        local platformWidth = screenWidth 
        local platformHeight = icebergBaseHeight
        local platformX = 0 
        local platformY = rowsData[1].y
        love.graphics.setColor(0.7, 0.5, 0.2, 1)
        love.graphics.rectangle("fill", platformX, platformY, platformWidth, platformHeight)
        love.graphics.setColor(0.5, 0.3, 0.1, 1)
        love.graphics.rectangle("line", platformX, platformY, platformWidth, platformHeight)
    end

    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    if player and player.lives then
        love.graphics.print("Vidas: " .. tostring(player.lives), 20, 20)
    end

    
    if gameState == "gameOver" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(28))
        love.graphics.print("Game Over! Presiona 'R' para reiniciar.", screenWidth / 2 - 200, screenHeight / 2)
    end
end

function love.keypressed(key)
    if gameState == "playing" then
        if not player.isJumping then 
            if key == "up" then
                player:jumpToRow(player.currentRow - 1, getRowSurfaceY, numRows)
            elseif key == "down" then
                player:jumpToRow(player.currentRow + 1, getRowSurfaceY, numRows)
            elseif key == "left" then 
                
                
            elseif key == "right" then
                
            end
        end
    elseif gameState == "gameOver" then
        if key == "r" then
            initializeGame() 
        end
    end

    if key == "escape" then
        love.event.quit()
    end
end