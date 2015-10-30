
Entity = {}
Entity.__index = Entity

function Entity.create()
    local instance = {}
    setmetatable(instance, Entity)
    instance.field_x = 2
    instance.field_y = 1
    instance.target_x = 2
    instance.target_y = 2
    instance.target_pct = 0.0
    instance.destroyed = false
    instance.hp = 12
    instance.max_hp = instance.hp
    instance.speed = 1.0
    instance.money = 20
    instance.color = {255, 100, 100}
    return instance
end

function Entity:draw()

    local pos = self:get_pos()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 255)
    love.graphics.circle("fill", pos[1], pos[2], 10, 20)

    local pct_hp = self.hp / self.max_hp

    love.graphics.setColor(255 - pct_hp * 255.0, pct_hp * 255.0, 0, 255)
    love.graphics.rectangle("line", pos[1] - 10, pos[2] + 12, 20, 4)
    love.graphics.rectangle("fill", pos[1] - 10, pos[2] + 12, 20 * pct_hp, 4)

end

function Entity:is_finished()
    return game_field[self.field_y][self.field_x] == 2
end

function Entity:get_pos()
    local offs_x = self.target_x * self.target_pct + (1.0 - self.target_pct) * self.field_x
    local offs_y = self.target_y * self.target_pct + (1.0 - self.target_pct) * self.field_y
    offs_x = (offs_x + 0.5) * field_size
    offs_y = (offs_y + 0.5) * field_size
    return {offs_x, offs_y}
end


function Entity:on_hit(damage)
    self.hp = self.hp - damage
    if self.hp < 1 and not self.destroyed then
        self.destroyed = true
        player_money = player_money + self.money
    end
end


function Entity:update(dt)
    self.target_pct = self.target_pct + dt * self.speed
    if self.target_pct > 1.0 then
        local old_x = self.field_x
        local old_y = self.field_y 
        self.field_x = self.target_x
        self.field_y = self.target_y

        self.target_x = 0
        self.target_y = 0
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
            local pos_x = self.field_x + dir[1]
            local pos_y = self.field_y + dir[2]
            if pos_x == old_x and pos_y == old_y then
                goto continue
            end
            if game_field[pos_y][pos_x] ~= 1 then
                goto continue
            end
            self.target_x = pos_x
            self.target_y = pos_y
            ::continue::
        end
    end
end
