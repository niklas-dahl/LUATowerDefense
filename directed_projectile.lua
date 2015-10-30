


DirectedProjectile = {}
DirectedProjectile.__index = DirectedProjectile

function DirectedProjectile.create()
    local instance = {}
    setmetatable(instance, DirectedProjectile)
    instance.target = nil
    instance.pos_x = 0
    instance.pos_y = 0
    instance.speed = 0.5
    instance.damage = 1
    return instance
end


function DirectedProjectile:update(dt)

    if self.target == nil or self.target.destroyed then
        return false
    end

    local target_pos = self.target:get_pos()

    local v_x = target_pos[1] - self.pos_x
    local v_y = target_pos[2] - self.pos_y
    
    local v_size = math.sqrt(v_x * v_x + v_y * v_y)

    if v_size < 20.0 then
        self.target:on_hit(self.damage)
        return false
    end

    v_x = v_x / v_size * 500.0 * self.speed * dt
    v_y = v_y / v_size * 500.0 * self.speed * dt

    self.pos_x = self.pos_x + v_x
    self.pos_y = self.pos_y + v_y

    return true
end


function DirectedProjectile:draw()
    love.graphics.setColor(0, 255, 255, 150)
    love.graphics.circle("fill", self.pos_x, self.pos_y, 3, 10)
end
