



function get_field_at(pos)
    if pos.x >= field_start.x and pos.y >= field_start.y then
        if pos.x < field_start.x + field_width * field_size.x then
            if pos.y < field_start.y + field_height * field_size.y then
                local tile_x = math.floor( (pos.x - field_start.x) / field_size.x ) + 1
                local tile_y = math.floor( (pos.y - field_start.y) / field_size.y ) + 1
                return Vector(tile_x, tile_y)
            end
        end
    end

    return nil
end

function get_field_data(pos)
    return game_field[pos.y][pos.x]
end

function load_field()
    local data = love.image.newImageData("res/field.png")
    for y = 0, field_height - 1 do
        game_field[y+1] = {}
        for x = 0, field_width - 1 do
            r, g, b, a = data:getPixel(x, y)
            local field = 0

            if r > 127 then
                field = 1
                start_pos = Vector(x+1, y+1)
            elseif g > 127 then
                field = 1
            elseif b > 127 then
                field = 2
            end

            game_field[y+1][x+1] = field
        end
    end
end

function draw_field()

    for x = 1, field_width do
        for y = 1, field_height do
            local obj = game_field[y][x]
            local offs = Vector(x - 1, y - 1) * field_size + field_start
            local draw_rect = true
            local hovered = is_hovered(offs, field_size) and tower_under_cursor ~= nil
            hovered = false

            if obj == 1 then
                
                -- Start
                if x == start_pos.x and y == start_pos.y then
                    love.graphics.setColor(20, 20, 20, 255)
                    love.graphics.print("START", offs.x + 4, offs.y + 20)
                
                end
            
                -- Strecke
                love.graphics.setColor(0, 0, 0, 100)
                if hovered then
                    love.graphics.setColor(100, 0, 0, 100)
                end

            elseif obj == 2 then
                -- Ziel
                love.graphics.setColor(20, 20, 20, 255)
                love.graphics.print("GOAL", offs.x + 8, offs.y + 20)
                love.graphics.setColor(0, 0, 0, 100)
            
            elseif obj == 0 then
                -- Leer
                love.graphics.setColor(0, 0, 0, 20)
                
                if hovered then
                    love.graphics.setColor(0, 100, 0, 120)
                end
            end

            if draw_rect then
                love.graphics.rectangle("fill", offs.x, offs.y, field_size.x, field_size.y)
            end
        end
    end 
end



function closest_tower(pos)

    local closest_dist = 100000.0
    local closest = nil

    for i = 1, #towers do
        local tower = towers[i]
        if tower ~= nil then
            local dist = Vector.distance(pos, tower:get_pos())
            if dist < closest_dist then
                closest_dist = dist
                closest = tower
            end
        end
    end
    return closest
end


