require "sound"

gui_pos = Vector(1100, 100)


btn_start_wave = {["text"] = "Start wave", ["pos"] = Vector(gui_pos.x, 560), ["size"] = Vector(150, 40), ["color"] = {80, 200, 80} }
btn_fast_forward = {["text"] = "Enable Fast Forward", ["pos"] = Vector(gui_pos.x, 610), ["size"] = Vector(150, 40) }
btn_cheat = {["text"] = "Cheat", ["pos"] = Vector(gui_pos.x, 830), ["size"] = Vector(150, 40) }
btn_upgrade = {["text"] = "Upgrade Tower", ["pos"] = Vector(850, 750), ["size"] = Vector(130, 40) }
btn_mute = {["text"] = "Mute", ["pos"] = Vector(gui_pos.x, 775), ["size"] = Vector(150, 40) }

ctrl_towers = Vector(gui_pos.x, gui_pos.y + 130)


function is_hovered(pos, size)
    if mouse.x >= pos.x and mouse.y >= pos.y then
        if mouse.x < pos.x + size.x and mouse.y < pos.y + size.y then
            return true
        end
    end
    return false
end


function get_tower_ctrl_offs(index)
    return ctrl_towers + Vector(0, index * (field_size.y + 10) )
end


function is_btn_hovered(btn)
    return is_hovered(btn.pos, btn.size)
end



function render_button(btn)
        
    local color = {60, 60, 60, 255}

    if btn.color ~= nil then
        color = btn.color
    end

    if is_btn_hovered(btn) then
        love.graphics.setColor(color[1]*0.8, color[2]*0.8, color[3]*0.8, 255)
    else
        love.graphics.setColor(color[1], color[2], color[3], 255)
    end


    love.graphics.rectangle("fill", btn.pos.x, btn.pos.y, btn.size.x, btn.size.y)
    love.graphics.setColor(255, 255, 255, 255)
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
    if magic and is_btn_hovered(btn_cheat) then
        player_money = player_money*2 + 100000000
    end


    -- BTN_UPGRADE
    if is_btn_hovered(btn_upgrade) then
        if selected_tower ~= nil then
            if selected_tower:get_upgrade_cost() <= player_money then
                if selected_tower:can_upgrade() then
                    player_money = player_money - selected_tower:get_upgrade_cost()
                    selected_tower:do_upgrade()
                    playSound("upgrade")
                end
            end
        end
    end

    -- BTN_FAST_FORWARD
    if is_btn_hovered(btn_fast_forward) then

        if fast_forward then
            fast_forward = false
            time_factor = 1.0
            btn_fast_forward.text = "Enable Fast Forward"
        else
            fast_forward = true
            time_factor = 4.0
            btn_fast_forward.text = "Disable Fast Forward"
        end
    end

    -- BTN_MUTE
    if is_btn_hovered(btn_mute) then
        toggleMute()
        if mute then
            btn_mute.text = "Unmute"
        else
            btn_mute.text = "Mute"
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

            playSound("tower_placed")
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

    love.graphics.setFont(big_font)
    love.graphics.setColor(52, 201, 36, 255)
    love.graphics.print("Money: " .. player_money .. "$", 600, 40)
    love.graphics.setColor(187, 36, 201, 255)
    love.graphics.print("Wave: " .. wave_id .. " / 50", 850, 40)
    love.graphics.setColor(0, 144, 255, 255)
    love.graphics.print("Lifes: " .. player_lifes, 1100, 40)


    love.graphics.setFont(font)

    love.graphics.setColor(20, 20, 20, 255)
    love.graphics.print("DEBUG STATS: ", gui_pos.x, gui_pos.y + 0)
    love.graphics.print("Projectiles: " .. #projectiles, gui_pos.x, gui_pos.y + 20)
    love.graphics.print("Running: " .. tostring(simulation_running), gui_pos.x, gui_pos.y + 40)
    love.graphics.print("Entities2spawn: " .. #entity_queue, gui_pos.x, gui_pos.y + 60)
    love.graphics.print("Mouse: " .. mouse.x .. " / " .. mouse.y, gui_pos.x, gui_pos.y + 80)
    love.graphics.print("Selected: " .. tostring(tower_under_cursor), gui_pos.x, gui_pos.y + 100)


    -- buttons
    if not simulation_running then
        render_button(btn_start_wave)
    end

    if magic then
        render_button(btn_cheat)
    end

    render_button(btn_fast_forward)
    render_button(btn_mute)

    -- draw tower types
    for f = 1, #tower_types do
        local tower_type = tower_types[f]
        local offs = get_tower_ctrl_offs(f - 1)

        if is_hovered(offs, field_size) then
            love.graphics.setColor(0, 0, 0, 30)
            love.graphics.rectangle("fill", offs.x, offs.y, field_size.x, field_size.y)

        end
        love.graphics.setColor(0, 0, 0, 50)
        love.graphics.rectangle("line", offs.x, offs.y, field_size.x, field_size.y)

        love.graphics.rectangle("line", offs.x, offs.y, field_size.x, field_size.y)
        tower_type.draw_shape(tower_type, offs.x + field_size.x / 2, offs.y + field_size.y / 2, -1, 0)
        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.print(tower_type.name, offs.x + field_size.x + 10, offs.y + 5)
        love.graphics.setColor(0, 150, 0, 255)
        if tower_type.cost > player_money then
            love.graphics.setColor(255, 0, 0, 255)
        end
        love.graphics.print("Price: " .. tower_type.cost .. "$", offs.x + field_size.x + 10, offs.y + 25)
    end

    if tower_under_cursor ~= nil then
        local could_place = can_place_tower_at(mouse.x, mouse.y) and tower_under_cursor.cost <= player_money
        tower_under_cursor.draw_shape(tower_under_cursor, mouse.x, mouse.y, tower_under_cursor.radius, 0, could_place, true)

        if tower_under_cursor.cost > player_money then
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.print("You don't have enough money!", mouse.x - 10, mouse.y + 40)
        end

    end

    -- Draw selected tower
    local upgrade_pos = Vector(field_start.x, field_start.y + (field_height+0.5) * field_size.y)


    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("line", upgrade_pos.x, upgrade_pos.y, 1000, 140)


    if selected_tower ~= nil then

        love.graphics.setColor(0, 144, 255, 255)
        love.graphics.setFont(big_font)
        love.graphics.print(selected_tower.name, upgrade_pos.x + 10, upgrade_pos.y + 10)
        love.graphics.setFont(font)
        love.graphics.setColor(20, 20, 20, 190)
        love.graphics.print("Upgrade: " .. (selected_tower.upgrade), upgrade_pos.x + 10, upgrade_pos.y + 50)
        love.graphics.print("Radius: " .. (selected_tower.radius), upgrade_pos.x + 10, upgrade_pos.y + 70)
        love.graphics.print("Damage: " .. (selected_tower.damage), upgrade_pos.x + 10, upgrade_pos.y + 90)
        love.graphics.print("Shoot speed: " .. (math.floor(1.0 / selected_tower.shoot_frequency * 10.0) / 10.0), upgrade_pos.x + 10, upgrade_pos.y + 110)

        local cost = selected_tower:get_upgrade_cost()

        if cost <= player_money then
                love.graphics.setColor(0, 100, 0, 255)
                love.graphics.print("Cost: " .. cost .. "$", 850, 730)
            if not selected_tower:can_upgrade() then
                
                love.graphics.setColor(0, 0, 100, 255)
                love.graphics.print("No further upgrades!", 850, 750)
            else
                render_button(btn_upgrade)
            end
        else
            love.graphics.setColor(255, 20, 20, 255)
            love.graphics.print("Cost: " .. cost .. "$", 850, 730)  
            love.graphics.print("Can't afford upgrade!", 850, 750)  

        end


    end


end