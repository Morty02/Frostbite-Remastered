local Player = {}
Player.__index = Player

Player.downPressed = false
Player.upPressed = false

function Player:new(x, y)
    local instance = {
        x = x,
        y = y,
        width = 20,
        height = 20,
        speed = 100,
        onIceberg = false,
        currentIceberg = nil,
        jumping = false,
        jumpTargetY = nil,
        jumpDuration = 0.2,
        jumpElapsed = 0
    }
    setmetatable(instance, Player)
    return instance
end

function Player:startJump(targetY)
    self.jumping = true
    self.jumpStartY = self.y
    self.jumpTargetY = targetY
    self.jumpElapsed = 0
end

function Player:update(dt, icebergs, level)
    
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    end

    
    if self.jumping then
        self.jumpElapsed = self.jumpElapsed + dt
        local t = math.min(self.jumpElapsed / self.jumpDuration, 1)
        
        self.y = self.jumpStartY + (self.jumpTargetY - self.jumpStartY) * t

        
        if love.keyboard.isDown("left") then
            self.x = self.x - self.speed * dt
        elseif love.keyboard.isDown("right") then
            self.x = self.x + self.speed * dt
        end

        
        if t >= 1 then
            self.jumping = false
            self.jumpDuration = 0.2 

            if self.fallingToWater then
                self.fallingToWater = false
                level:load()
                return
            end

            
            self.onIceberg = false
            for _, iceberg in ipairs(icebergs) do
                if self:isOnTopOf(iceberg) then
                    self.onIceberg = true
                    self.currentIceberg = iceberg
                    break
                end
            end
            local sobreSueloVisual = math.abs(self.y + self.height - (level.spawnY + 20)) < 5
            local sobreSuelo = math.abs(self.y + self.height - level.sueloY) < 5
            if not self.onIceberg and not sobreSueloVisual and not sobreSuelo then
                level:load()
            end
        end
        
        return
    end

    
    self.onIceberg = false
    self.currentIceberg = nil
    for _, iceberg in ipairs(icebergs) do
        if self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width then
            if math.abs(self.y + self.height - iceberg.y) < 5 then
                self.onIceberg = true
                self.currentIceberg = iceberg
                break
            end
        end
    end

    
    if self.onIceberg and self.currentIceberg then
        self.x = self.x + self.currentIceberg.speed * dt * (self.currentIceberg.direction == "right" and 1 or -1)
    end

    local primerFilaY = level.sueloY + level.rowHeight

    
    if love.keyboard.isDown("up") then
        if not self.upPressed then
            self.upPressed = true

            local sueloVisualY = level.spawnY + 20

            
            if math.abs(self.y + self.height - sueloVisualY) < 5 then
                return
            end

            
            if self.onIceberg and math.abs(self.y + self.height - (level.sueloY + level.rowHeight)) < 5 then
                self:startJump(sueloVisualY - self.height)
                return
            end

            
            if math.abs(self.y + self.height - sueloVisualY) < 5 then
                self.y = level.sueloY + level.rowHeight
                return
            end

            
            local targetY = nil
            for _, iceberg in ipairs(icebergs) do
                if self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width then
                    if iceberg.y < self.y then
                        if not targetY or iceberg.y > targetY then
                            targetY = iceberg.y
                        end
                    end
                end
            end
            if targetY then
                self.y = targetY - self.height
            elseif self.onIceberg or math.abs(self.y + self.height - level.sueloY) < 5 then
                self.y = self.y - self.speed * dt
            end
        end
    else
        self.upPressed = false
    end


    
    if love.keyboard.isDown("down") then
        if not self.downPressed then
            self.downPressed = true

            local icebergDestino = nil
            local filaActualY = nil

            
            for _, iceberg in ipairs(icebergs) do
                if math.abs(self.y + self.height - iceberg.y) < 5 then
                    filaActualY = iceberg.y
                    break
                end
            end

            if filaActualY then
                
                local filaDebajoY = filaActualY + level.rowHeight
                for _, iceberg in ipairs(icebergs) do
                    if math.abs(iceberg.y - filaDebajoY) < 5 then
                        if self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width then
                            icebergDestino = iceberg
                            break
                        end
                    end
                end
            elseif math.abs(self.y + self.height - (level.spawnY + 20)) < 5 then
                
                local filaDebajoY = level.sueloY + level.rowHeight
                for _, iceberg in ipairs(icebergs) do
                    if math.abs(iceberg.y - filaDebajoY) < 5 then
                        if self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width then
                            icebergDestino = iceberg
                            break
                        end
                    end
                end
            end

            if icebergDestino then
                
                self:startJump(icebergDestino.y - self.height)
                self.fallingToWater = false
            else
                
                local fondoAgua = love.graphics.getHeight() - self.height
                self:startJump(fondoAgua)
                self.fallingToWater = true
                self.jumpDuration = 0.4 
            end
        end
    else
        self.downPressed = false
    end

    self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))
    self.y = math.max(0, math.min(self.y, love.graphics.getHeight() - self.height))

    
    local debajoSuelo = self.y + self.height > level.sueloY
    local noEnSuelo = math.abs(self.y + self.height - level.sueloY) > 1

    local enAgua = false
    if debajoSuelo and noEnSuelo then
        
        local filaY = nil
        for _, iceberg in ipairs(icebergs) do
            if math.abs(self.y + self.height - iceberg.y) < 5 then
                filaY = iceberg.y
                break
            end
        end

        if filaY then
            
            local sobreIceberg = false
            for _, iceberg in ipairs(icebergs) do
                if iceberg.y == filaY then
                    if self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width then
                        sobreIceberg = true
                        break
                    end
                end
            end
            if not sobreIceberg then
                enAgua = true
            end
        else
            
            enAgua = true
        end
    end

    if enAgua then
        level:load() 
    end
end

function Player:isColliding(iceberg)
    return self.x + self.width > iceberg.x and
           self.x < iceberg.x + iceberg.width and
           self.y + self.height > iceberg.y and
           self.y < iceberg.y + iceberg.height
end

function Player:isOnTopOf(iceberg)
    local isHorizontallyAligned = self.x + self.width > iceberg.x and self.x < iceberg.x + iceberg.width
    local isVerticallyAligned = math.abs(self.y + self.height - iceberg.y) < 5
    return isHorizontallyAligned and isVerticallyAligned
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Player
