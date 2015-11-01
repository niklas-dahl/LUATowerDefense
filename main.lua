
require "vector"
require "entity"
require "directed_projectile"
require "entities"
require "tower"
require "gui"
require "sound"

game_field = {}





tower_types = {
    Tower,
    -- LaserTower
}


towers = {}
projectiles = {}

field_width = 20
start_pos = Vector(1, 1)
field_height = 11
field_start = Vector(50, 100)
field_size = Vector(50, 50)
wave_id = 0
wave_spawn_rate = 10.0
simulation_running = false
player_lifes = 1
player_money = 1000
last_entity_spawned = 0.0
tower_under_cursor = nil

mouse = Vector(0, 0)

function is_hovered(pos, size)
    if mouse.x >= pos.x and mouse.y >= pos.y then
        if mouse.x < pos.x + size.x and mouse.y < pos.y + size.y then
            return true
        end
    end
    return false
end

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



function love.keypressed(key, unicode)
    if key == "escape" then
        tower_under_cursor = nil
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





function love.mousepressed(x, y, button)

    if button == "l" then

        check_button_actions()
        on_gui_click(x, y)
    end
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

function love.load(arg)
    playMusic("music")

    background = love.graphics.newImage("res/background.png")
    load_field()
end


function love.update(dt)

    if player_lifes < 1 then
        return
    end

    mouse = Vector(love.mouse.getX(), love.mouse.getY())


    if simulation_running then 
        local any_entities_left = false
        local diff = love.timer.getTime() - last_entity_spawned 

        -- Neuen Entity spawnen?
        if diff > wave_spawn_rate then
            entity = table.remove(entity_queue, 1)
            table.insert(entities, entity)
            last_entity_spawned = love.timer.getTime()
        end

        -- Entities updaten
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

        -- Projektile updaten
        for i = 1, #projectiles do
            local proj = projectiles[i]
            if proj ~= nil and proj:update(dt) == false then
                table.remove(projectiles, i)
            end
        end

        -- Tower updaten
        for i = 1, #towers do
            local tower = towers[i]
            tower:update(dt)
        end
        
        -- Evt. wave stoppen
        if any_entities_left == false and #entity_queue == 0 then
            stop_wave()
        end

    end
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
    love.graphics.draw(background, 0, 0)
    love.graphics.setColor(100, 100, 100, 255)
    -- love.graphics.rectangle("fill", 0, 0, 10000, 10000)

    if true then

        for x = 1, field_width do
            for y = 1, field_height do
                local obj = game_field[y][x]
                local offs = Vector(x - 1, y - 1) * field_size + field_start
                local draw_rect = true
                local hovered = is_hovered(offs, field_size) and tower_under_cursor ~= nil
                hovered = false

                if obj == 1 then
                    -- Strecke
                    love.graphics.setColor(0, 0, 0, 100)
                    if hovered then
                        love.graphics.setColor(100, 0, 0, 100)
                    end
                
                elseif obj == 2 then
                    -- Ziel
                    love.graphics.setColor(20, 20, 20, 255)
                    love.graphics.print("GOAL", offs.x + 10, offs.y + 20)

                    love.graphics.setColor(0, 0, 120, 80)
                
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

        -- Draw projectiles
        for i = 1, #projectiles do
            local projectile = projectiles[i]
            projectile:draw()
        end

        -- Draw Towers
        for i = 1, #towers do
            local tower = towers[i]
            tower:draw()
        end

        -- Draw entities
        for i = 1, #entities do
            local entity = entities[i]
            entity:draw()
        end


        draw_gui()

    end

    if player_lifes < 1 then
        love.graphics.setColor(128, 10, 10, 200)
        love.graphics.rectangle("fill", 0, 0, 10000, 10000)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("GAME OVER!", 100, 100)
    end

end
