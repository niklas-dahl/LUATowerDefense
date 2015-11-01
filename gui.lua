


gui_pos = Vector(1100, 100)


btn_start_wave = {["text"] = "Start wave", ["pos"] = Vector(gui_pos.x, 500), ["size"] = Vector(130, 40) }
btn_cheat = {["text"] = "Cheat", ["pos"] = Vector(gui_pos.x, 550), ["size"] = Vector(130, 40) }
btn_upgrade = {["text"] = "Upgrade Tower", ["pos"] = Vector(900, 750), ["size"] = Vector(130, 40) }


ctrl_towers = Vector(gui_pos.x, gui_pos.y + 200)


function get_tower_ctrl_offs(index)
    return ctrl_towers + Vector(0, index * (field_size.y + 10) )
end


function is_btn_hovered(btn)
    return is_hovered(btn.pos, btn.size)
end


function render_button(btn)
    if is_btn_hovered(btn) then
        love.graphics.setColor(40, 80, 170, 255)
    else
        love.graphics.setColor(20, 60, 150, 255)
    end
    love.graphics.rectangle("fill", btn.pos.x, btn.pos.y, btn.size.x, btn.size.y)
    love.graphics.setColor(200, 200, 200, 255)
    love.graphics.print(btn.text, btn.pos.x + btn.size.x / 2 - string.len(btn.text) * 3.4, btn.pos.y + btn.size.y / 2 - 7)
end




function check_button_actions()

    -- BTN_START_WAVE
    if is_btn_hovered(btn_start_wave) then
        if not simulation_running then
            start_wave()
            return
        end
    end

    -- BTN_CHEAT
    if is_btn_hovered(btn_cheat) then
        player_money = player_money*2 + 1000
    end


    -- BTN_UPGRADE
    if is_btn_hovered(btn_upgrade) then
        if selected_tower ~= nil then
            selected_tower:do_upgrade()
        end
    end

end

function can_place_tower_at(x, y)

    local tile = get_field_at(Vector(x, y))

    if tile ~= nil and get_field_data(tile) == 0 then
        local tower = closest_tower(Vector(x, y))
        if tower == nil or Vector.distance(tower:get_pos(), Vector(x, y)) > 30 then
            return true
        end
    end

    return false

end


function on_gui_click(x, y)

    local tile = get_field_at(Vector(x, y))

    -- Upgraden eines Towers
    -- if player_money >= 50 and tile ~= nil then
    --     local tile_data = get_field_data(tile)

    --     if tile_data ~= nil and tile_data~=0 and tile_data~=1 and tile_data~=2 then
    --         tile_data.radius = tile_data.radius+20
    --         tile_data.shoot_frequency = tile_data.shoot_frequency*0.8
    --         tile_data.upgrade = tile_data.upgrade+2;
    --         player_money = player_money - 50
    --     end
    -- end

    -- Klicken auf das Tower-Build Menü
    for f = 1, #tower_types do
        local offs = get_tower_ctrl_offs(f - 1)
        if is_hovered(offs, field_size) then
            tower_under_cursor = tower_types[f]
            selected_tower = nil
            return
        end
    end

    -- Neuen Tower platzieren
    if tower_under_cursor ~= nil and tower_under_cursor.cost <= player_money then
        if can_place_tower_at(x, y) then
            local rel_pos = Vector(x, y) - field_start
            rel_pos = rel_pos / field_size + 0.5
            local tower = tower_under_cursor.create()
            tower.field_pos = rel_pos

            table.insert(towers, tower)
            player_money = player_money - tower.cost
            return
        end
    end

    if tower_under_cursor == nil then

        local tower = closest_tower(Vector(x, y))
        if tower ~= nil and Vector.distance(tower:get_pos(), Vector(x, y)) < 30 then
            selected_tower = tower
        end
    end


end

function update_gui()


end

function draw_gui()

    -- stats
    love.graphics.setColor(20, 20, 20, 255)
    love.graphics.print("Lifes: " .. player_lifes, gui_pos.x, gui_pos.y + 0)
    love.graphics.print("Money: " .. player_money .. "$", gui_pos.x, gui_pos.y + 20)
    love.graphics.print("Projectiles: " .. #projectiles, gui_pos.x, gui_pos.y + 40)
    love.graphics.print("Running: " .. tostring(simulation_running), gui_pos.x, gui_pos.y + 60)
    love.graphics.print("Entities2spawn: " .. #entity_queue, gui_pos.x, gui_pos.y + 80)
    love.graphics.print("Mouse: " .. mouse.x .. " / " .. mouse.y, gui_pos.x, gui_pos.y + 100)
    love.graphics.print("Wave: " .. wave_id, gui_pos.x, gui_pos.y + 120)
    love.graphics.print("Selected: " .. tostring(tower_under_cursor), gui_pos.x, gui_pos.y + 140)


    -- buttons
    if not simulation_running then
        render_button(btn_start_wave)
    end

    render_button(btn_cheat)


    -- draw tower types
    for f = 1, #tower_types do
        local tower_type = tower_types[f]
        local offs = get_tower_ctrl_offs(f - 1)

        if is_hovered(offs, field_size) then
            love.graphics.setColor(0, 0, 0, 50)
        else
            love.graphics.setColor(0, 0, 0, 100)
        end

        love.graphics.rectangle("fill", offs.x, offs.y, field_size.x, field_size.y)
        tower_type.draw_shape(offs.x + field_size.x / 2, offs.y + field_size.y / 2, -1, 1)
        love.graphics.setColor(20, 20, 20, 255)
        if tower_type.cost > player_money then
            love.graphics.setColor(255, 0, 0, 255)
        end
        love.graphics.print("Price: " .. tower_type.cost .. "$", offs.x + field_size.x + 10, offs.y + 10)
    end

    if tower_under_cursor ~= nil then
        tower_under_cursor.draw_shape(mouse.x, mouse.y, tower_under_cursor.radius, 1, can_place_tower_at(mouse.x, mouse.y))

        if tower_under_cursor.cost > player_money then
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.print("You don't have enough money!", mouse.x - 10, mouse.y + 40)
        end

    end

    -- Draw selected tower


    local upgrade_pos = Vector(field_start.x, field_start.y + (field_height+1) * field_size.y)


    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", upgrade_pos.x, upgrade_pos.y, 1000, 140)

    if selected_tower ~= nil then

        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.print("Selected Tower", upgrade_pos.x + 10, upgrade_pos.y + 10)
        love.graphics.setColor(20, 20, 20, 190)
        love.graphics.print("Upgrade: " .. (selected_tower.upgrade), upgrade_pos.x + 10, upgrade_pos.y + 30)
        love.graphics.print("Radius: " .. (selected_tower.radius), upgrade_pos.x + 10, upgrade_pos.y + 50)
        love.graphics.print("Damage: " .. (selected_tower.damage), upgrade_pos.x + 10, upgrade_pos.y + 70)
        love.graphics.print("Shoot speed: " .. (selected_tower.shoot_frequency), upgrade_pos.x + 10, upgrade_pos.y + 90)

        local cost = selected_tower:get_upgrade_cost()

        if cost <= player_money then
            render_button(btn_upgrade)
        else
            love.graphics.setColor(255, 100, 100, 255)
            love.graphics.print("Can't afford upgrade!", 750, 750)  
        end


    end


end