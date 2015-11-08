


DirectedProjectile = {}
DirectedProjectile.__index = DirectedProjectile

function DirectedProjectile.create()
    local instance = {}
    setmetatable(instance, DirectedProjectile)
    instance.target = nil
    instance.pos = nil
    instance.speed = 0.5
    instance.damage = 1
    instance.laserProjectile = false
    instance.lineProjectile = false
    instance.source = nil
    table.insert(projectiles, instance)
    return instance
end

function DirectedProjectile:update(dt)

    if self.target == nil or self.target.destroyed then
        return false
    end

    local target_pos = self.target:get_pos()

    local direction = target_pos - self.pos
    local dist = direction:len()

    if dist < 20.0 then
        self.target:on_hit(self.damage)
        if self.source ~= nil and self.target.destroyed == true then
            self.source.kill_count = self.source.kill_count + 1
        end
        return false
    end

    local velocity = direction / dist * 500.0 * self.speed * dt

    if velocity:len() > dist then
        velocity = velocity * (dist / velocity:len()) 
    end

    self.pos = self.pos + velocity
    return true
end


function DirectedProjectile:draw()
    if(self.laserProjectile) then
        local target_pos = self.target:get_pos()
        

        if not self.lineProjectile then
            local direction = target_pos - self.pos

            if direction:len() > 1 then
                direction = direction / (1 - direction:len())
            end

            direction = direction * 25

            love.graphics.setColor(255, 0, 0, 150)
            love.graphics.setLineWidth(3)
            love.graphics.line(self.pos.x, self.pos.y, self.pos.x + direction.x, self.pos.y + direction.y)
            love.graphics.setLineWidth(1)
        else

        end
    else
        love.graphics.setColor(0, 0, 0, 150)
        love.graphics.circle("fill", self.pos.x, self.pos.y, 3, 10)
    end
end
