

Tower = {}
Tower.__index = Tower
Tower.radius = 100
Tower.cost = 350
Tower.name = "Default Tower"
Tower.single_target = true
Tower.direction = 0

function Tower.create()
    local instance = {}
    setmetatable(instance, Tower)
    instance.field_pos = Vector(2, 2)
    instance.target = nil
    instance.shoot_frequency = 0.3
    instance.shoot_speed = 1.7
    instance.last_shoot_time = 0.0
    instance.upgrade = 0
    instance.damage = 5
    instance.focus_mode = "First"
    instance.money_spent_on = 0
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
    big_upgrade = math.floor(upgrade / 7)
    upgrade = upgrade % 7

    local s = 4
    -- love.graphics.rectangle("fill", x - 10 - s, y + 10 - s, 2*s + 20, s)
    -- love.graphics.rectangle("fill", x - 10, y - 10 - s, s, 2*s + 20)
    -- love.graphics.rectangle("fill", x + 10 - s, y - 10 - s, s, 2*s + 20)

    love.graphics.setColor(255, 0, 144, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    love.graphics.setColor(30, 30, 30, 100)
    love.graphics.circle("fill", x, y, 6, 20)

    love.graphics.setColor(30, 30, 30, 255)
    love.graphics.rectangle("line", x - 11, y - 11, 22, 22)

end

function Tower.draw_shape(clstype, x, y, radius, upgrade, is_valid, selected)

    if clstype.single_target and clstype.direction ~= nil then
        local pipe_w = 3
        local pipe_h = 20

        love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(clstype.direction)
        love.graphics.setColor(60, 60, 60, 255)
        love.graphics.rectangle("fill", -pipe_w, -pipe_h, 2 * pipe_w, pipe_h)
        love.graphics.pop()
    end

    clstype.draw_inner_shape(x, y, upgrade)

    big_upgrade = math.floor(upgrade / 7)
    upgrade = upgrade % 7
    local uoffsx = (upgrade) * 2

    for i = 1, big_upgrade do
        for k = 1, 7 do
            love.graphics.setColor(20, 80, 20, 255)
            love.graphics.rectangle("fill", x - 18 + 4 * k, y + field_size.y*0.4 - 4 + (i-1) * 6, 3, 3)
        end
    end

    local uoffsy = big_upgrade * 6

    for i = 1, upgrade do
        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.rectangle("fill", x - uoffsx - 4 + 4 * i, y + field_size.y*0.4 - 4 + uoffsy, 3, 3)
    end

    if big_upgrade > 0 then
        -- love.graphics.setColor(255, 255, 255, 255)
        -- love.graphics.draw(img_star, x - 8, y - 8)
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
    self.money_spent_on = self.money_spent_on + self:get_upgrade_cost()
    self.upgrade = self.upgrade + 1
    self:do_internal_upgrade()
end

function Tower:do_internal_upgrade()
    self.damage = self.damage + self.upgrade + 3
    self.radius = self.radius + 5
    self.shoot_frequency = self.shoot_frequency * 0.976
end

function Tower:can_upgrade()
    return self.upgrade < 21
end

function Tower:get_upgrade_cost()
    return 150 + self.upgrade * self.upgrade * 20
end


function Tower:get_pos()
    return (self.field_pos - 0.5) * field_size + field_start
end



function Tower:update(dt)
    local pos = self:get_pos()
    local new_target = closest_entity( pos, self.radius, self.focus_mode )

    self.target = nil
    local time_diff = (love.timer.getTime() - self.last_shoot_time) * time_factor

    if self.shoot_frequency > 0 then
        if new_target ~= nil then
            local target_pos = new_target:get_pos()
            local vec = pos - target_pos

            local wanted_direction = math.atan2(vec.y, vec.x) - 0.5 * math.pi
            local mix_factor = math.min(1.0, dt * 12.0)
            mix_factor = 1.0
            self.direction = self.direction * (1.0 - mix_factor) + wanted_direction * mix_factor
            self.target = new_target
            
            if time_diff > self.shoot_frequency then
                self:shoot_projectile()
                self.last_shoot_time = love.timer.getTime()
            end

        else
            self:update_idle(dt)
        end
    end
end

function Tower:update_idle(dt)
    self.direction = self.direction + dt * 0.2
end
