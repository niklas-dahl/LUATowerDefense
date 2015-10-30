

Tower = {}
Tower.__index = Tower
Tower.radius = 100
Tower.cost = 200

function Tower.create()
    local instance = {}
    setmetatable(instance, Tower)
    instance.field_x = 2
    instance.field_y = 2
    instance.target = nil
    instance.shoot_frequency = 0.3
    instance.last_shoot_time = 0.0
    instance.shoot_speed = 1.0
    instance.upgrade = 1
    return instance
end


function Tower:draw()

    local pos_x = (self.field_x + 0.5) * field_size
    local pos_y = (self.field_y + 0.5) * field_size

    self.draw_shape(pos_x, pos_y, self.radius, self.upgrade)

    if self.target ~= nil then
        local ent_pos = self.target:get_pos()
        -- love.graphics.line(pos_x, pos_y, ent_pos[1], ent_pos[2])
    end 

end


function Tower.draw_shape(x, y, radius, upgrade)

    love.graphics.setColor(0, 127, 255, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    if radius >= 0 then
        love.graphics.setColor(0, 127, 255, 70)
        love.graphics.circle("line", x, y, radius, 80)  
    end

end



function Tower:update()
    local new_target = closest_entity( { (self.field_x + 0.5) * field_size, (self.field_y + 0.5) * field_size} )
    local pos_x = (self.field_x + 0.5) * field_size
    local pos_y = (self.field_y + 0.5) * field_size
    
    self.target = nil

    local time_diff = love.timer.getTime() - self.last_shoot_time

    if new_target ~= nil then

        local target_pos = new_target:get_pos()
        local dist = distance_between(target_pos, {pos_x, pos_y})

        if dist < self.radius then
            self.target = new_target
            
            if time_diff > self.shoot_frequency then

                local proj = DirectedProjectile.create()
                proj.target = self.target
                proj.speed = self.shoot_speed
                proj.pos_x = pos_x
                proj.pos_y = pos_y
                table.insert(projectiles, proj)

                self.last_shoot_time = love.timer.getTime()
            end
        end
    end


end