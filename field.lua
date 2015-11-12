



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

    --floor tiles
    floor_5 = love.graphics.newImage("res/floorTiles/wall_5.png")
    floor_10 = love.graphics.newImage("res/floorTiles/wall_10.png")
    floor_6 = love.graphics.newImage("res/floorTiles/wall_6.png")
    floor_3 = love.graphics.newImage("res/floorTiles/wall_3.png")
    floor_12 = love.graphics.newImage("res/floorTiles/wall_12.png")
    floor_9 = love.graphics.newImage("res/floorTiles/wall_9.png")


end

function draw_field()

    for x = 1, field_width do
        for y = 1, field_height do
            local obj = game_field[y][x]
            local offs = Vector(x - 1, y - 1) * field_size + field_start
            local draw_rect = true

            if obj == 1 or obj == 2 then
                
                -- Start
                love.graphics.setColor(20, 20, 20, 255)
                if x == start_pos.x and y == start_pos.y then
                    love.graphics.print("START", offs.x + 4, offs.y + 20)
                
                -- Ziel
                elseif obj == 2 then
                    love.graphics.print("END", offs.x + 10, offs.y + 20)
                end
            
                -- Strecke
                love.graphics.setColor(0, 0, 0, 100)

            
            elseif obj == 0 then
                -- Leer
                love.graphics.setColor(0, 0, 0, 20)

            end

            if draw_rect then
                love.graphics.rectangle("fill", offs.x, offs.y, field_size.x, field_size.y)
                
                if((game_field[y][x]==1 or game_field[y][x]==2) and x>0 and y>0 and x<=field_width and y<=field_height) then
                    local bitmask = 0
                    if(x<field_width and game_field[y][x+1] == 1) then bitmask = bitmask + 1 end
                    if(y<field_height and game_field[y+1][x] == 1) then bitmask = bitmask + 2 end
                    if(x>1 and game_field[y][x-1] == 1) then bitmask = bitmask + 4 end
                    if(y>1 and game_field[y-1][x] == 1) then bitmask = bitmask + 8 end

                    love.graphics.setColor(0,0,0)                    
                    if(bitmask == 5) then -- ==
                        love.graphics.line(offs.x, offs.y, offs.x+field_size.x, offs.y)
                        love.graphics.line(offs.x, offs.y+field_size.y, offs.x+field_size.x, offs.y+field_size.y)

                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_5, offs.x, offs.y, 0, 50/64, 50/64)
                    end
                    if(bitmask == 10 or bitmask == 2 or bitmask == 8) then -- ||    --hack for first and last tile
                        love.graphics.line(offs.x, offs.y, offs.x, offs.y+field_size.y)
                        love.graphics.line(offs.x+field_size.x, offs.y, offs.x+field_size.x, offs.y+field_size.y)

                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_10, offs.x, offs.y, 0, 50/64, 50/64)
                    end
                    if(bitmask == 6) then
                        love.graphics.line(offs.x, offs.y, offs.x+field_size.x, offs.y)
                        love.graphics.line(offs.x+field_size.x, offs.y, offs.x+field_size.x, offs.y+field_size.y)

                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_6, offs.x, offs.y, 0, 50/64, 50/64)
                    end
                    if(bitmask == 12) then
                        love.graphics.line(offs.x, offs.y+field_size.y, offs.x+field_size.x, offs.y+field_size.y)
                        love.graphics.line(offs.x+field_size.x, offs.y, offs.x+field_size.x, offs.y+field_size.y)

                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_12, offs.x, offs.y, 0, 50/64, 50/64)
                    end
                    if(bitmask == 3 or bitmask == 1) then --hack for second last tile !
                        love.graphics.line(offs.x, offs.y, offs.x+field_size.x, offs.y)
                        love.graphics.line(offs.x, offs.y, offs.x, offs.y+field_size.y)

                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_3, offs.x, offs.y, 0, 50/64, 50/64)
                    end
                    if(bitmask == 9) then
                        love.graphics.line(offs.x, offs.y+field_size.y, offs.x+field_size.x, offs.y+field_size.y)
                        love.graphics.line(offs.x, offs.y, offs.x, offs.y+field_size.y)
                        
                        love.graphics.setColor(255, 255, 255, 255)
                        love.graphics.draw(floor_9, offs.x, offs.y, 0, 50/64, 50/64)
                    end

                end

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


