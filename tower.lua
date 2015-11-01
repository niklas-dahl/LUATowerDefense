

Tower = {}
Tower.__index = Tower
Tower.radius = 100
Tower.cost = 200
Tower.name = "Default Tower"

function Tower.create()
    local instance = {}
    setmetatable(instance, Tower)
    instance.field_pos = Vector(2, 2)
    instance.target = nil
    instance.shoot_frequency = 0.3
    instance.last_shoot_time = 0.0
    instance.shoot_speed = 1.0
    instance.upgrade = 1
    instance.damage = 3
    return instance
end


function Tower:draw()
    local pos = self:get_pos()
    self.draw_shape(self, pos.x, pos.y, self.radius, self.upgrade, true, self == selected_tower)
end


function Tower:shoot_projectile()
    local proj = DirectedProjectile.create()
    proj.target = self.target
    proj.speed = self.shoot_speed
    proj.damage = self.damage
    proj.pos = self:get_pos()
    table.insert(projectiles, proj)
    return proj
end

function Tower.draw_inner_shape(x, y, upgrade)
    love.graphics.setColor(upgrade*10, 127-10*upgrade, 255-20*upgrade, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)
end

function Tower.draw_shape(clstype, x, y, radius, upgrade, is_valid, selected)

    clstype.draw_inner_shape(x, y, upgrade)

    local uoffsx = (upgrade-1) * 2

    for i = 1, upgrade - 1 do

        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.rectangle("fill", x - uoffsx - 4 + 4 * i, y + field_size.y*0.4 - 4, 3, 3)

    end

    if radius >= 0 then

        if is_valid then
            if selected then
                love.graphics.setColor(127, 255, 127, 150)
                love.graphics.circle("line", x, y, radius, 80)  
                love.graphics.setColor(127, 255, 127, 20)
                love.graphics.circle("fill", x, y, radius, 80) 
            else
                love.graphics.setColor(0, 127, 255, 150)
                love.graphics.circle("line", x, y, radius, 80)  
                love.graphics.setColor(0, 127, 255, 20)
                love.graphics.circle("fill", x, y, radius, 80)  
            end
        else
            love.graphics.setColor(255, 50, 0, 150)
            love.graphics.circle("line", x, y, radius, 80)  
            love.graphics.setColor(255, 50, 0, 50)
            love.graphics.circle("fill", x, y, radius, 80)  
        end
    end
end

function Tower:do_upgrade()

    self.upgrade = self.upgrade + 1
    self.damage = self.damage + 1
    self.radius = self.radius + 20
    self.shoot_frequency = self.shoot_frequency * 0.9

end

function Tower:get_upgrade_cost()
    return 100 + self.upgrade * 50
end


function Tower:get_pos()
    return (self.field_pos - 0.5) * field_size + field_start
end



function Tower:update()
    local pos = self:get_pos()
    local new_target = closest_entity( pos )
    
    self.target = nil
    local time_diff = (love.timer.getTime() - self.last_shoot_time) * time_factor

    if new_target ~= nil then
        local target_pos = new_target:get_pos()
        local dist = Vector.distance(target_pos, pos)
        if dist < self.radius then
            self.target = new_target
            
            if time_diff > self.shoot_frequency then

                self:shoot_projectile()
                self.last_shoot_time = love.timer.getTime()
            end
        end
    end
end
