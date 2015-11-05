

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
    instance.shoot_speed = 1.0
    instance.last_shoot_time = 0.0
    instance.upgrade = 0
    instance.damage = 5
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
    return proj
end

function Tower.draw_inner_shape(x, y, upgrade)
    big_ugprade = math.floor(upgrade / 7)
    upgrade = upgrade % 7

    local s = 4
    -- love.graphics.rectangle("fill", x - 10 - s, y + 10 - s, 2*s + 20, s)
    -- love.graphics.rectangle("fill", x - 10, y - 10 - s, s, 2*s + 20)
    -- love.graphics.rectangle("fill", x + 10 - s, y - 10 - s, s, 2*s + 20)

    love.graphics.setColor(0 + big_ugprade*30, 144-30*big_ugprade, 255-60*big_ugprade, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    love.graphics.setColor(30, 30, 30, 100)
    love.graphics.circle("fill", x, y, 6, 20)


    love.graphics.setColor(30,30,30, 255)
    love.graphics.rectangle("line", x - 11, y - 11, 22, 22)

end

function Tower.draw_shape(clstype, x, y, radius, upgrade, is_valid, selected)

    clstype.draw_inner_shape(x, y, upgrade)

    big_ugprade = math.floor(upgrade / 7)
    upgrade = upgrade % 7
    local uoffsx = (upgrade) * 2
    for i = 1, upgrade do

        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.rectangle("fill", x - uoffsx - 4 + 4 * i, y + field_size.y*0.4 - 4, 3, 3)

    end


    if big_ugprade > 0 then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(img_star, x - 8, y - 8)
    end

    if radius >= 0 and radius < 5000 then


        if is_valid then
            if selected then
                love.graphics.setColor(0, 160, 0, 150)
                love.graphics.circle("line", x, y, radius, 80)  
                love.graphics.setColor(0, 160, 0, 20)
                love.graphics.circle("fill", x, y, radius, 80) 
            else
                -- love.graphics.setColor(0, 127, 255, 70)
                -- love.graphics.circle("line", x, y, radius, 80)  
                -- love.graphics.setColor(0, 127, 255, 10)
                -- love.graphics.circle("fill", x, y, radius, 80)  
            end
        else
            love.graphics.setColor(255, 50, 0, 150)
            love.graphics.circle("line", x, y, radius, 80)  
            love.graphics.setColor(255, 50, 0, 20)
            love.graphics.circle("fill", x, y, radius, 80)  
        end
    end
end

function Tower:do_upgrade()
    self.upgrade = self.upgrade + 1
    self.damage = self.damage + self.upgrade + 1
    self.radius = self.radius + 5
    self.shoot_frequency = self.shoot_frequency * 0.97

end

function Tower:can_upgrade()
    return self.upgrade < 14
end

function Tower:get_upgrade_cost()
    return 150 + self.upgrade * self.upgrade * 20
end


function Tower:get_pos()
    return (self.field_pos - 0.5) * field_size + field_start
end



function Tower:update()
    local pos = self:get_pos()
    local new_target = closest_entity( pos )
    
    self.target = nil
    local time_diff = (love.timer.getTime() - self.last_shoot_time) * time_factor

    if self.shoot_frequency > 0 then
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
end
