local Player = {}
Player.__index = Player

function Player:new(x, y, initialRow)
    local instance = setmetatable({}, Player)
    instance.x = x
    instance.y = y 
    instance.width = 20
    instance.height = 20
    instance.color = {1, 0.8, 0.2, 1} 

    instance.isJumping = false
    instance.jumpStartY = 0
    instance.jumpTargetY = 0
    instance.jumpDuration = 0.2 
    instance.jumpElapsedTime = 0
    instance.airControlSpeed = 80 

    instance.onIceberg = nil 
    instance.currentRow = initialRow 
    instance.targetRow = initialRow

    
    instance.spriteSheet = love.graphics.newImage("assets/sprites/player_walk.png")
    instance.frameWidth = 20
    instance.frameHeight = 20
    instance.frames = {}
    instance.currentFrame = 1
    instance.animationTimer = 0
    instance.animationSpeed = 0.12
    instance.numFrames = 4
    instance.facing = "right" 

    for i = 0, instance.numFrames - 1 do
        table.insert(instance.frames, love.graphics.newQuad(
            i * instance.frameWidth, 0, instance.frameWidth, instance.frameHeight,
            instance.spriteSheet:getDimensions()
        ))
    end

    return instance
end


function Player:jumpToRow(targetRowIndex, getRowTopYFunc, numTotalRows)
    if self.isJumping then return end 
    if targetRowIndex < 1 or targetRowIndex > numTotalRows then return end
    self.isJumping = true
    self.jumpStartY = self.y
    self.jumpTargetY = getRowTopYFunc(targetRowIndex) - self.height
    self.jumpElapsedTime = 0
    self.onIceberg = nil
    self.targetRow = targetRowIndex
end

function Player:update(dt, getIcebergsInRowFunc, gameOverCallback)
    if self.pushing then
        
        local totalPushDistance = self.pushSpeed * self.pushDuration
        local pushProgress = math.min(1, (self.pushTime + dt) / self.pushDuration)
        local dx = totalPushDistance * (pushProgress - (self.pushTime / self.pushDuration))
        dx = dx * (self.pushDir == "right" and 1 or -1)
        self.x = math.max(0, math.min(self.x + dx, love.graphics.getWidth() - self.width))
        self.pushTime = self.pushTime + dt
        if self.pushTime >= self.pushDuration then
            self.pushing = false
            self.pushDir = nil
            self.pushSpeed = 0
            self.pushTime = 0
            self.pushDuration = 0
        end
        return
    end

    if self.isJumping then
        self.jumpElapsedTime = self.jumpElapsedTime + dt
        local progress = self.jumpElapsedTime / self.jumpDuration

        
        if love.keyboard.isDown("left") then
            self.x = self.x - self.airControlSpeed * dt
        elseif love.keyboard.isDown("right") then
            self.x = self.x + self.airControlSpeed * dt
        end
        self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))

        if progress < 1 then
            self.y = self.jumpStartY + (self.jumpTargetY - self.jumpStartY) * progress
        else
            self.y = self.jumpTargetY
            self.isJumping = false
            self.currentRow = self.targetRow

            local icebergsInCurrentRow = getIcebergsInRowFunc(self.currentRow)
            local landedIceberg = self:_checkLanding(icebergsInCurrentRow)

            if landedIceberg then
                if self.currentRow == 1 and landedIceberg == true then
                    
                    self.onIceberg = nil
                    return
                end
                self.onIceberg = landedIceberg
                self.y = landedIceberg.y - self.height

                if landedIceberg.useForIgloo and landedIceberg:useForIgloo() then
                    self.iglooBlocksCollected = (self.iglooBlocksCollected or 0) + 1
                end
            else
                gameOverCallback()
            end
        end
    else
        
        if self.onIceberg then
            
            if love.keyboard.isDown("left") then
                self.x = self.x - self.airControlSpeed * dt
            elseif love.keyboard.isDown("right") then
                self.x = self.x + self.airControlSpeed * dt
            end

            
            self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))

            
            local moveSpeed = self.onIceberg.speed * dt
            if self.onIceberg.direction == "right" then
                self.x = self.x + moveSpeed
            else
                self.x = self.x - moveSpeed
            end

            
            self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))

            
            if self.x < self.onIceberg.x or self.x + self.width > self.onIceberg.x + self.onIceberg.width then
                print("¡El jugador se cayó del iceberg al agua!")
                self.onIceberg = nil
                gameOverCallback()
                return
            end
        
            
        elseif self.currentRow == 1 then
            
            if love.keyboard.isDown("left") then
                self.x = self.x - self.airControlSpeed * dt
            elseif love.keyboard.isDown("right") then
                self.x = self.x + self.airControlSpeed * dt
            end
            
            self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))
        end
    end

    local moving = false
    if love.keyboard.isDown("left") then
        self.x = self.x - self.airControlSpeed * dt
        moving = true
        self.facing = "left"
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.airControlSpeed * dt
        moving = true
        self.facing = "right"
    end

    if moving then
        self.animationTimer = self.animationTimer + dt
        if self.animationTimer >= self.animationSpeed then
            self.animationTimer = self.animationTimer - self.animationSpeed
            self.currentFrame = (self.currentFrame % self.numFrames) + 1
        end
    else
        self.currentFrame = 1 
    end
end

function Player:_checkLanding(icebergsInRow)
    local playerFeetY = self.y + self.height
    print(string.format("Iniciando _checkLanding. Jugador X: %.2f, Pies Y: %.2f", self.x, playerFeetY))
    if #icebergsInRow == 0 then
        
        if self.currentRow == 1 then
            print("  Aterrizaje seguro en la plataforma de spawn (fila 1).")
            return true
        end
        print("  No hay icebergs en la fila para comprobar.")
        return nil
    end

    for i, iceberg in ipairs(icebergsInRow) do
        local playerRight = self.x + self.width
        local icebergRight = iceberg.x + iceberg.width

        local overlapsX = playerRight > iceberg.x and self.x < icebergRight
        local feetOnTop = math.abs(playerFeetY - iceberg.y) < 5 

        print(string.format("  Comprobando Iceberg #%d: X[%.2f-%.2f], Ancho: %.2f, SupY: %.2f", i, iceberg.x, icebergRight, iceberg.width, iceberg.y))
        print(string.format("    overlapsX: %s, feetOnTop: %s (PlayerFeetY: %.2f vs IcebergSupY: %.2f, Diff: %.2f)",
                            tostring(overlapsX), tostring(feetOnTop), playerFeetY, iceberg.y, playerFeetY - iceberg.y))

        if overlapsX and feetOnTop then
            print(string.format("    ¡ÉXITO! Aterrizaje detectado en Iceberg #%d.", i))
            return iceberg
        end
    end

    print("  _checkLanding finalizado: NO SE ENCONTRÓ ATERRIZAJE.")
    return nil
end

function Player:draw()
    if self.spriteSheet and self.frames[self.currentFrame] then
        love.graphics.setColor(1,1,1)
        local sx = self.facing == "left" and -1 or 1
        local ox = self.facing == "left" and self.frameWidth or 0
        love.graphics.draw(self.spriteSheet, self.frames[self.currentFrame], self.x + ox, self.y, 0, sx, 1)
    else
        love.graphics.setColor(unpack(self.color))
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

return Player