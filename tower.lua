

Tower = {}
Tower.__index = Tower
Tower.radius = 100
Tower.cost = 200

-- require "laser_tower"

function Tower.create()
    local instance = {}
    setmetatable(instance, Tower)
    instance.field_pos = Vector(2, 2)
    instance.target = nil
    instance.shoot_frequency = 0.3
    instance.last_shoot_time = 0.0
    instance.shoot_speed = 1.0
    instance.upgrade = 1
    return instance
end


function Tower:draw()
    local pos = self:get_pos()
    self.draw_shape(pos.x, pos.y, self.radius, self.upgrade, true)
end


function Tower.draw_shape(x, y, radius, upgrade, is_valid)

    love.graphics.setColor(upgrade*10, 127-10*upgrade, 255-20*upgrade, 255)

    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    if radius >= 0 then

        if is_valid then
            love.graphics.setColor(0, 127, 255, 150)
            love.graphics.circle("line", x, y, radius, 80)  
            love.graphics.setColor(0, 127, 255, 20)
            love.graphics.circle("fill", x, y, radius, 80)  
        else
            love.graphics.setColor(255, 50, 0, 150)
            love.graphics.circle("line", x, y, radius, 80)  
            love.graphics.setColor(255, 50, 0, 50)
            love.graphics.circle("fill", x, y, radius, 80)  
        end
    end
end


function Tower:get_pos()
    return (self.field_pos - 0.5) * field_size + field_start
end



function Tower:update()
    local pos = self:get_pos()
    local new_target = closest_entity( pos )
    
    self.target = nil
    local time_diff = love.timer.getTime() - self.last_shoot_time

    if new_target ~= nil then
        local target_pos = new_target:get_pos()
        local dist = Vector.distance(target_pos, pos)
        if dist < self.radius then
            self.target = new_target
            
            if time_diff > self.shoot_frequency then

                local proj = DirectedProjectile.create()
                proj.target = self.target
                proj.speed = self.shoot_speed
                proj.pos = pos
                table.insert(projectiles, proj)

                self.last_shoot_time = love.timer.getTime()
            end
        end
    end
end
