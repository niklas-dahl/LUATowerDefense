

FreezeProjectile = {}
FreezeProjectile.__index = FreezeProjectile


function FreezeProjectile.create()
    local instance = {}
    setmetatable(instance, FreezeProjectile)
    instance.pos = nil
    instance.speed = 0.5
    instance.damage = 0
    instance.pct = 0
    instance.radius = 100
    instance.freeze_factor = 0.75
    table.insert(projectiles, instance)
    return instance
end

function FreezeProjectile:update(dt)
    self.pct = self.pct + dt * 3.0

    if self.pct > 1.0 then
        return false
    end

    -- Find all entities in the radius of the projectile
    for i = 1, #entities do
        local entity = entities[i]
        if entity ~= nil and not entity.destroyed then
            local dist = Vector.distance(entity:get_pos(), self.pos)
            if dist < self.radius * self.pct * self.pct then
                entity:slow_by(self.freeze_factor)
            end
        end
    end


    return true
end

function FreezeProjectile:draw()

    local opacity = 1.0 - math.pow(self.pct, 3)

    love.graphics.setColor(0, 144, 255, 255 * opacity)
    love.graphics.circle("line", self.pos.x, self.pos.y, self.radius * self.pct * self.pct, 50)

    love.graphics.setColor(0, 144, 255, 20 * opacity)
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius * self.pct * self.pct, 50)

end