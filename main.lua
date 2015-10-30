
require "entity"
require "tower"
require "directed_projectile"

game_field = {
    {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
    {0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
    {0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
}

entities = {}
towers = {}
projectiles = {}
entity_queue = {}

tower_types = {
    Tower
}

field_width = 15
field_height = 11
field_size = 40

wave_id = 0
wave_spawn_rate = 1.0

simulation_running = false

player_lifes = 1
player_money = 250

last_entity_spawned = 0.0


tower_under_cursor = nil

btn_start_wave = {"Start wave", 660, 440, 100, 40}


mousex = 0
mousey = 0


function love.conf(t)
    t.title = "Game 1"
    t.version = "1.0.1"
    t.window.width = 480
    t.window.height = 800
end


function is_hovered(btn_start_x, btn_start_y, btn_width, btn_height)

    if mousex >= btn_start_x and mousey >= btn_start_y then

        if mousex < btn_start_x + btn_width and mousey < btn_start_y + btn_height then
            return true
        end
    end

    return false
end

function is_btn_hovered(btn)
    return is_hovered(btn[2], btn[3], btn[4], btn[5])
end

function distance_between(a, b) 
    local dx = a[1] - b[1]
    local dy = a[2] - b[2]
    return math.sqrt(dx*dx + dy*dy)
end


function render_button(btn)

    if is_hovered(btn[2], btn[3], btn[4], btn[5]) then
        love.graphics.setColor(40, 80, 170, 255)
    else
        love.graphics.setColor(20, 60, 150, 255)
    end
    love.graphics.rectangle("fill", btn[2], btn[3], btn[4], btn[5])

        love.graphics.setColor(200, 200, 200, 255)
        love.graphics.print(btn[1], btn[2] + btn[4] / 2 - 35, btn[3] + btn[5] / 2 - 7)

end

function love.keypressed(key, unicode)
    if key == "escape" then
        tower_under_cursor = nil
    end

end

function love.mousepressed(x, y, button)

    if button == "l" then

        if is_btn_hovered(btn_start_wave) then
            if not simulation_running then
                start_wave()
                return
            end
        end

        for f = 1, #tower_types do

            if is_hovered(660, 200 + (f-1) * 40, 40, 40) then
                tower_under_cursor = tower_types[f]
                return
            end
        end

        if tower_under_cursor ~= nil and tower_under_cursor.cost <= player_money then
            if x >= 40 and y >= 40 then
                if x < 40 + field_width * field_size then
                    if y < 40 + field_height * field_size then

                        local field_x = math.floor( x / field_size )
                        local field_y = math.floor( y / field_size )
                        local field_data = game_field[field_y][field_x]

                        if field_data == 0 then

                            local tower = tower_under_cursor.create()
                            tower.field_x = field_x
                            tower.field_y = field_y
                            game_field[field_y][field_x] = tower
                            table.insert(towers, tower)
                            player_money = player_money - tower.cost
                            tower_under_cursor = nil
                            return
                        end
                    end
                end
            end
        end
    end
end

function love.load(arg)

    if false then
        for i = 1, 12 do
            local entity = Entity.create()    
            table.insert(entities, entity)   
            entity.speed = (i+19) / 5.0
        end
    end

    start_towers = {
        {3, 3},
        {1, 4},
        {3, 5},
        {1, 6},
    }

    for i = 1, #start_towers do
        local x = start_towers[i][1]
        local y = start_towers[i][2]
        local tower = Tower.create()
        tower.field_x = x
        tower.field_y = y
        game_field[y][x] = tower
        table.insert(towers, tower)

    end

    -- start_wave()

end


function closest_entity(pos)

    local closest_dist = 100000.0
    local closest_entity = nil

    for i = 1, #entities do
        local entity = entities[i]
        if entity ~= nil then
            local dist = distance_between(pos, entity:get_pos())
            if dist < closest_dist then
                closest_dist = dist
                closest_entity = entity
            end
        end
    end

    return closest_entity
end




function love.update(dt)

    if player_lifes < 1 then
        return
    end


    mousex = love.mouse.getX()
    mousey = love.mouse.getY()

    if simulation_running then 
        local any_entities_left = false
        

        local diff = love.timer.getTime() - last_entity_spawned 

        if diff > wave_spawn_rate then
            entity = table.remove(entity_queue, 1)

            table.insert(entities, entity)

            last_entity_spawned = love.timer.getTime()
        end

        for i = 1, #entities do
            local entity = entities[i]
            if entity ~= nil then
                entity:update(dt)

                any_entities_left = true
                if entity.destroyed then
                    table.remove(entities, i)

                elseif entity:is_finished() then
                    entity.destroyed = true
                    table.remove(entities, i)
                    player_lifes = player_lifes - 1
                end 
            end
        end
        for i = 1, #projectiles do
            local proj = projectiles[i]
            if proj ~= nil and proj:update(dt) == false then
                table.remove(projectiles, i)
            end
        end
        for i = 1, #towers do
            local tower = towers[i]
            tower:update(dt)
        end
        
        if any_entities_left == false and #entity_queue == 0 then
            stop_wave()
        end

    end



end

function spawn_wave()
    local objs = {}

    for i = 1, 10 do

        local entity = Entity.create()
        entity.speed = 2.0 + wave_id * 0.3
        entity.max_hp = 10 + wave_id * 2
        entity.money = 20 + wave_id * 1

        -- blau
        if i % math.max(0, 5 - wave_id) == 0 then
            entity.color = {255, 255, 100}
            entity.max_hp = entity.max_hp * 2

        end

        entity.hp = entity.max_hp

        table.insert(objs, entity)
    end

    wave_spawn_rate = 2.0 / (wave_id*0.2 + 2)

    return objs
end

function start_wave()

    tower_under_cursor = nil
    simulation_running = true
    entity_queue = spawn_wave()
    entities = {}
    projectiles = {}
    wave_id = wave_id + 1

end


function stop_wave()

    -- Cleanup first
    entities = {}
    projectiles = {}
    entity_queue = {}
    simulation_running = false

end

function love.draw()

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setColor(100, 100, 100, 255)
    love.graphics.rectangle("fill", 0, 0, 10000, 10000)

    if true then

        for x = 1, field_width do
            for y = 1, field_height do
                local k = game_field[y][x]
                local draw_rect = true
                local hovered = is_hovered(x * field_size, y * field_size, field_size, field_size) and tower_under_cursor ~= nil


                if k == 1 then
                    -- Strecke
                    love.graphics.setColor(0, 0, 0, 80)
                    if hovered then
                        love.graphics.setColor(100, 0, 0, 80)
                    end
                
                elseif k == 2 then
                    -- Ziel
                    love.graphics.setColor(0, 0, 0, 80)
                
                    if hovered then
                        love.graphics.setColor(100, 0, 0, 80)
                    end

                elseif k == 0 then
                    -- Leer
                    love.graphics.setColor(0, 0, 0, 20)
                    
                    if hovered then
                        love.graphics.setColor(0, 100, 0, 120)
                    end

                else
                    -- Tower
                    k:draw()
                    draw_rect = false

                end
                if draw_rect then


                    love.graphics.rectangle("fill", x * field_size + 2, y * field_size + 2, field_size - 4, field_size - 4)


                end
            
            end
        end 

        for i = 1, #projectiles do
            local projectile = projectiles[i]
            projectile:draw()
        end

        for i = 1, #entities do
            local entity = entities[i]
            entity:draw()
        end


        -- stats
        love.graphics.setColor(200, 200, 200, 255)
        love.graphics.print("Lifes: " .. player_lifes, 660, 40)
        love.graphics.print("Money: " .. player_money .. "$", 660, 60)
        love.graphics.print("Projectiles: " .. #projectiles, 660, 80)
        love.graphics.print("Running: " .. tostring(simulation_running), 660, 100)
        love.graphics.print("Entities2spawn: " .. #entity_queue, 660, 120)
        love.graphics.print("Mouse: " .. mousex .. " / " .. mousey, 660, 140)
        love.graphics.print("Wave: " .. wave_id, 660, 160)
        love.graphics.print("Selected: " .. tostring(tower_under_cursor), 660, 180)

        -- buttons
        if not simulation_running then

            render_button(btn_start_wave)

        end

        for f = 1, #tower_types do
            local tower_type = tower_types[f]

            if is_hovered(660, 200 + (f-1) * field_size, field_size, field_size) then
                love.graphics.setColor(0, 0, 0, 50)
            else
                love.graphics.setColor(0, 0, 0, 100)
            end
            love.graphics.rectangle("fill", 660, 200, field_size, field_size)
            tower_type.draw_shape(660 + 20, 220 + (f-1) * field_size, -1, 1)

            love.graphics.setColor(200, 200, 200, 150)
            if tower_type.cost >= player_money then
                love.graphics.setColor(255, 100, 100, 150)
            end
            love.graphics.print("Price: " .. tower_type.cost .. "$", 710, 210 + (f-1) * field_size)
        end



        if tower_under_cursor ~= nil then
            tower_under_cursor.draw_shape(mousex, mousey, tower_under_cursor.radius, 1)
        end




    end

    if player_lifes < 1 then

        love.graphics.setColor(128, 10, 10, 200)
        love.graphics.rectangle("fill", 0, 0, 10000, 10000)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("GAME OVER!", 100, 100)

    end


end
