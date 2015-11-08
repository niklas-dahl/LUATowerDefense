


LineProjectile = {}
LineProjectile.__index = LineProjectile

function LineProjectile.create()
    local instance = {}
    setmetatable(instance, LineProjectile)
    instance.target_pos = nil
    instance.start = nil
    instance.damage = 1
    instance.duration = 0.12
    instance.time_visible = 0.0
    instance.source = nil
    table.insert(projectiles, instance)
    return instance
end

function LineProjectile:update(dt)

    self.time_visible = self.time_visible + dt

    if self.time_visible > self.duration then
        return false
    end

    return true
end


function LineProjectile:draw()
    local opacity = 1.0 - (self.time_visible / self.duration)

    love.graphics.setColor(255, 0, 255, 150 * opacity)
    love.graphics.setLineWidth(3)
    love.graphics.line(self.start_pos.x, self.start_pos.y, self.target_pos.x, self.target_pos.y)
    love.graphics.setLineWidth(1)
end
