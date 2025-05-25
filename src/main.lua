
local Player = require("game.player")
local Iceberg = require("game.iceberg")


local player
local rowsData = {} 
local numRows = 5
local screenWidth, screenHeight
local riverBackgroundColor = {0.1, 0.3, 0.7, 1} 

local gameState = "loading" 

local icebergBaseHeight = 25
local verticalSpacingBetweenRows 


function getRowSurfaceY(rowIndex)
    
    local firstRowTopMargin = screenHeight * 0.15
    return firstRowTopMargin + ((rowIndex - 1) * verticalSpacingBetweenRows)
end


function getIcebergsForRow(rowIndex)
    if rowsData[rowIndex] and rowsData[rowIndex].icebergs then
        return rowsData[rowIndex].icebergs
    end
    return {} 
end


function triggerGameOver()
    if gameState == "playing" then
        player.lives = player.lives - 1
        
        if player.lives > 0 then
            
            local startRowIndex = math.ceil(numRows / 2)
            player.currentRow = startRowIndex
            player.targetRow = startRowIndex
            player.y = getRowSurfaceY(startRowIndex) - player.height
            player.x = screenWidth / 2 - player.width/2
            player.isJumping = false
            player.onIceberg = nil 
            
            player.jumpElapsedTime = 0
            player.jumpStartY = 0
            player.jumpTargetY = 0
            player.jumpDuration = 0.2 
            player.jumpElapsedTime = 0
            
            local currentRowIcebergs = getIcebergsForRow(startRowIndex)
            if #currentRowIcebergs == 0 then
                
                
                
                player.onIceberg = nil
            else
                
                player.onIceberg = currentRowIcebergs[1]
                player.y = player.onIceberg.y - player.height
                player.x = player.onIceberg.x + player.onIceberg.width / 2 - player.width / 2
            end
            
            gameState = "playing"
        elseif player.lives == 0 then
            
            gameState = "gameOver"
            
            
            love.graphics.print("Game Over! Presiona 'R' para reiniciar.", screenWidth / 2 - 100, screenHeight / 2)
            
        else
            gameState = "gameOver" 
        end
    end
end


function initializeGame()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    
    local gameAreaHeight = screenHeight * 0.70
    local firstRowTopMargin = screenHeight * 0.15
    if numRows > 1 then
        verticalSpacingBetweenRows = gameAreaHeight / (numRows -1)
    else
        verticalSpacingBetweenRows = gameAreaHeight
    end

    rowsData = {}
    math.randomseed(os.time())

    
    local icebergPatterns = { odd = {}, even = {} }
    for group, rows in pairs({ odd = {1,3,5}, even = {2,4} }) do
        local pattern = {}
        local numIcebergsThisRow = math.random(2, 4)
        local totalIcebergWidthRatio = 0.6
        local averageIcebergWidth = (screenWidth * totalIcebergWidthRatio) / numIcebergsThisRow
        local gapWidth = (screenWidth * (1 - totalIcebergWidthRatio)) / (numIcebergsThisRow + 1)
        local direction = (group == "even") and "left" or "right"
        local currentX = gapWidth

        for j = 1, numIcebergsThisRow do
            local icebergWidth = averageIcebergWidth * (math.random(80, 120) / 100)
            local speed = math.random(40, 80)
            local initialXOffset = (direction == "right") and math.random(0, screenWidth/2) or -math.random(0, screenWidth/2)
            local startX = (currentX + initialXOffset) % screenWidth
            if startX + icebergWidth > screenWidth then startX = startX - (startX + icebergWidth - screenWidth) end
            if startX < 0 then startX = 0 end

            table.insert(pattern, {x = startX, width = icebergWidth, speed = speed, direction = direction})
            currentX = currentX + icebergWidth + gapWidth
        end
        icebergPatterns[group] = pattern
    end

    for i = 1, numRows do
        local currentRowY = getRowSurfaceY(i)
        rowsData[i] = { y = currentRowY, icebergs = {} }
        local group = (i % 2 == 0) and "even" or "odd"
        local pattern = icebergPatterns[group]
        for _, icebergData in ipairs(pattern) do
            table.insert(rowsData[i].icebergs, Iceberg:new(
                icebergData.x, currentRowY, icebergData.width, icebergBaseHeight, icebergData.speed, icebergData.direction
            ))
        end
    end

    
    local startRowIndex = math.ceil(numRows / 2) 
    local playerX = screenWidth / 2 - 10 
    local playerY = getRowSurfaceY(startRowIndex) - 20 

    player = Player:new(playerX, playerY, startRowIndex)
    player.lives = 3
    player.iglooBlocksCollected = 0

    
    local initialIcebergs = getIcebergsForRow(startRowIndex)
    local landedIceberg = player:_checkLanding(initialIcebergs)
    if landedIceberg then
        player.onIceberg = landedIceberg
        player.y = landedIceberg.y - player.height 
        player.x = landedIceberg.x + landedIceberg.width / 2 - player.width / 2 
    else
        
        
        
        
        
        
        if #initialIcebergs > 0 then 
            player.onIceberg = initialIcebergs[1]
            player.y = initialIcebergs[1].y - player.height
            player.x = initialIcebergs[1].x + initialIcebergs[1].width / 2 - player.width / 2
        else
             print("ADVERTENCIA: No hay icebergs en la fila de inicio para el jugador.")
        end
    end
    
    gameState = "playing"
end


function love.load()
    love.window.setTitle("Aventura en el Río Helado")
    math.randomseed(os.time())
    initializeGame() 
end

function love.update(dt)
    if gameState == "playing" then
        player:update(dt, getIcebergsForRow, triggerGameOver)

        for i = 1, numRows do
            for _, iceberg in ipairs(rowsData[i].icebergs) do
                iceberg:update(dt)
            end
        end
    elseif gameState == "gameOver" then
        
    end
end

function love.draw()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    if player and player.lives then
        love.graphics.print("Vidas: " .. tostring(player.lives), 20, 20)
    end

    
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

    
    if gameState == "gameOver" then
        love.graphics.setColor(1, 0, 0, 0.8) 
        love.graphics.rectangle("fill", 0, screenHeight / 2 - 50, screenWidth, 130)
        
        love.graphics.setColor(1, 1, 1) 
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("¡CAÍSTE AL AGUA!", 0, screenHeight / 2 - 30, screenWidth, "center")
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("Presiona 'R' para reiniciar", 0, screenHeight / 2 + 20, screenWidth, "center")
        love.graphics.setFont(love.graphics.newFont(12)) 
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