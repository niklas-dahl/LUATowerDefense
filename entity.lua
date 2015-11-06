
Entity = {}
Entity.__index = Entity

function Entity.create()
    local instance = {}
    setmetatable(instance, Entity)
    instance.field_pos = start_pos:clone()
    instance.target = start_pos:clone()
    instance.target_pct = 2.0
    instance.destroyed = false
    instance.hp = 12
    instance.max_hp = instance.hp
    instance.speed = 1.0
    instance.money = 20
    instance.color = {255, 100, 100}
    instance.size = 10
    instance.slow_factor = 0.0
    return instance
end

function Entity:draw()

    local pos = self:get_pos()

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 255)
    love.graphics.circle("fill", pos.x, pos.y, self.size, self.size*2)

    local pct_hp = self.hp / self.max_hp
    local hp_y = pos.y + self.size + 6

    local border = 2
    if pct_hp < 1 then

        love.graphics.setColor(0, 0, 0, 150)
        love.graphics.rectangle("fill", pos.x - 10 - border, hp_y - border, 20 + 2*border, 3 + 2 * border)
        love.graphics.setColor(255 - pct_hp * 255.0, pct_hp * 255.0, 0, 255)
        love.graphics.rectangle("fill", pos.x - 10, hp_y, 20 * pct_hp, 3)
    end

end

function Entity:slow_by(amount)
    self.slow_factor = math.max(amount, self.slow_factor)
end

function Entity:is_finished()
    return game_field[self.field_pos.y][self.field_pos.x] == 2
end

function Entity:get_pos()
    local offs = self.target * self.target_pct + (1.0 - self.target_pct) * self.field_pos
    offs = (offs - 0.5) * field_size + field_start
    return offs
end

function Entity:on_hit(damage)
    self.hp = math.max(0, self.hp - damage)
    if self.hp < 1 and not self.destroyed then
        self.destroyed = true
        player_money = player_money + self.money
        playSound("coin")
    end
end


function Entity:update(dt)

    if true then

        self.target_pct = self.target_pct + dt * self.speed * (1.0 - self.slow_factor)

        self.slow_factor = self.slow_factor * (1.0 - dt)

        if self.target_pct > 1.0 then
            local old_x = self.field_pos.x
            local old_y = self.field_pos.y
            self.field_pos = self.target:clone()

            self.target_pct = 0.0

            -- find next field
            local dirs = {
                {-1, 0},
                {1, 0},
                {0, -1},
                {0, 1}
            }

            for i = 1, 4 do
                local dir = dirs[i]
                local pos_x = self.field_pos.x + dir[1]
                local pos_y = self.field_pos.y + dir[2]

                -- Nicht wieder aufs alte Feld zurücklaufen
                if pos_x == old_x and pos_y == old_y then
                    goto continue
                end

                -- Nur auf der Strecke bleiben
                if pos_x < 1 or pos_y < 1 or pos_x > field_width or pos_y > field_height or (game_field[pos_y][pos_x] ~= 1 and game_field[pos_y][pos_x] ~= 2) then
                    goto continue
                end
                self.target = self.field_pos + Vector(dir[1], dir[2])
                ::continue::
            end
        end

    end
end
