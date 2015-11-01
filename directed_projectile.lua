


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
        local direction = target_pos - self.pos
        direction = direction / direction:len() * 15

        love.graphics.setColor(255, 0, 0, 150)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x + direction.x, self.pos.y + direction.y)
    else
        love.graphics.setColor(0, 0, 0, 150)
        love.graphics.circle("fill", self.pos.x, self.pos.y, 3, 10)
    end
end
