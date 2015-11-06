
gui_pos = Vector(1080, 100)

anything_hovered = false

ctrl_towers = Vector(gui_pos.x, gui_pos.y)


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

function render_button(btn, disabled)
        
    local color = {60, 60, 60, 255}
    local hovered = is_btn_hovered(btn)

    if btn.color ~= nil then
        color = btn.color
    end

    -- if btn.img == nil then
    if hovered then
        love.graphics.setColor(color[1]*0.97, color[2]*0.97, color[3]*0.97, 230)
    else
        love.graphics.setColor(color[1], color[2], color[3], 255)
    end
    -- end

    if hovered then
        anything_hovered = true
    end



    if disabled then
        love.graphics.setColor(20, 20, 20, 25)
    end

    if btn.img == nil then
        love.graphics.rectangle("fill", btn.pos.x, btn.pos.y, btn.size.x, btn.size.y)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(btn.text, btn.pos.x + btn.size.x / 2 - string.len(btn.text) * 3.4, btn.pos.y + btn.size.y / 2 - 7)
    else
        local img
        if(btn.use_alt_img ~= nil and btn.use_alt_img) then

            -- Load image only once
            if type(btn.alt_img) == "string" then
                btn.alt_img = love.graphics.newImage(btn.alt_img)
            end
            img = btn.alt_img
        else
            -- Load image only once
            if type(btn.img) == "string" then 
                btn.img = love.graphics.newImage(btn.img)
            end
            img = btn.img
        end

        love.graphics.draw(img, btn.pos.x, btn.pos.y)
    end
end




function check_button_actions()

    -- BTN_START_WAVE
    if is_btn_hovered(btn_start_wave_new) then
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
    if is_btn_hovered(btn_fast_forward_new) then

        if fast_forward then
            fast_forward = false
            time_factor = 1.0
            btn_fast_forward_new.use_alt_img = false

            -- btn_fast_forward.text = "Enable Fast Forward"
        else
            fast_forward = true
            time_factor = 4.0
            btn_fast_forward_new.use_alt_img = true
            if not simulation_running then
                start_wave()
            end
            -- btn_fast_forward.text = "Disable Fast Forward"
        end
    end

    -- BTN_MUTE
    if is_btn_hovered(btn_mute) then
        toggleMute()
        btn_mute.use_alt_img = not mute
        if mute then
            btn_mute.text = "Unmute"
        else
            btn_mute.text = "Mute"
        end
    end


    -- BTN Modes
    for i = 1, #btn_tower_modes do
        local btn = btn_tower_modes[i]

        if is_btn_hovered(btn) and selected_tower ~= nil then
            selected_tower.focus_mode = btn.mode
        end

    end


end

function can_place_tower_at(x, y)

    local tile = get_field_at(Vector(x, y))

    if tile ~= nil and get_field_data(tile) == 0 then
        local tower = closest_tower(Vector(x, y))
        if tower == nil or Vector.distance(tower:get_pos(), Vector(x, y)) > 25 then
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
        if tower ~= nil and Vector.distance(tower:get_pos(), Vector(x, y)) < math.sqrt(10*10 + 10*10) then
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
    love.graphics.print("Money: " .. format_num(player_money,0,"$ "), 600, 40)
    love.graphics.setColor(187, 36, 201, 255)
    love.graphics.print("Wave: " .. wave_id .. " / 50", 840, 40)
    love.graphics.setColor(0, 144, 255, 255)
    love.graphics.print("Lifes: " .. player_lifes, 1080, 40)


    love.graphics.setFont(font)

    if magic then
        local dbg_top = love.graphics.getHeight() - 200
        love.graphics.setColor(20, 20, 20, 255)
        love.graphics.print("DEBUG STATS: ", gui_pos.x, dbg_top + 0)
        love.graphics.print("Projectiles: " .. #projectiles, gui_pos.x, dbg_top + 20)
        love.graphics.print("Running: " .. tostring(simulation_running), gui_pos.x, dbg_top + 40)
        love.graphics.print("Entities2spawn: " .. #entity_queue, gui_pos.x, dbg_top + 60)
        love.graphics.print("Mouse: " .. mouse.x .. " / " .. mouse.y, gui_pos.x, dbg_top + 80)
        love.graphics.print("Selected: " .. tostring(tower_under_cursor), gui_pos.x, dbg_top + 100)
    end

    -- buttons
    render_button(btn_start_wave_new, simulation_running)

    if magic then
        render_button(btn_cheat)
    end

    render_button(btn_mute)
    render_button(btn_fast_forward_new)

    -- Draw fast forward display
    if fast_forward then
        local fade_time = 2.0
        local opacity = love.timer.getTime() % fade_time
        local ff_top = 620
        opacity = math.min(opacity, fade_time - opacity) / fade_time
        love.graphics.setColor(50, 200, 50, 255 * opacity)
        rounded_rect(gui_pos.x, ff_top, 150, 30, 5)
        love.graphics.setColor(0, 0, 0, 255 * opacity)
        love.graphics.print("FAST FORWARD", gui_pos.x + 25, ff_top + 8)

    end

    -- draw tower types
    for f = 1, #tower_types do
        local tower_type = tower_types[f]
        local offs = get_tower_ctrl_offs(f - 1)

        if is_hovered(offs, field_size) then
            love.graphics.setColor(0, 0, 0, 30)
            love.graphics.rectangle("fill", offs.x, offs.y, field_size.x, field_size.y)

            anything_hovered = true

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

        love.graphics.setColor(0, 0, 0, 20)
        love.graphics.rectangle("fill", upgrade_pos.x, upgrade_pos.y, 1000, 140)


        love.graphics.setColor(0, 144, 255, 255)
        love.graphics.setFont(big_font)
        love.graphics.print(selected_tower.name, upgrade_pos.x + 10, upgrade_pos.y + 10)
        love.graphics.setFont(font)
        love.graphics.setColor(20, 20, 20, 190)
        

        local line = 0
        love.graphics.print("Upgrade: " .. (selected_tower.upgrade), upgrade_pos.x + 10, upgrade_pos.y + 50 + 20 * line)
        line = line + 1
        love.graphics.print("Radius: " .. (selected_tower.radius), upgrade_pos.x + 10, upgrade_pos.y + 50 + 20 * line)
        line = line + 1
        
        if selected_tower.damage > 0 then
            love.graphics.print("Damage: " .. (selected_tower.damage), upgrade_pos.x + 10, upgrade_pos.y + 50 + 20 * line)
            line = line + 1
        end

        if selected_tower.freeze_factor ~= nil then
            love.graphics.print("Slow Factor: " .. math.floor(selected_tower.freeze_factor * 100.0) .. "%", upgrade_pos.x + 10, upgrade_pos.y + 50 + 20 * line)
            line = line + 1
        end

        love.graphics.print("Shoot speed: " .. (math.floor(1.0 / selected_tower.shoot_frequency * 10.0) / 10.0), upgrade_pos.x + 10, upgrade_pos.y + 50 + 20 * line)
        line = line + 1



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
            
        love.graphics.setColor(30, 30, 30, 255)
        love.graphics.print("Focus mode: ", 350, 735)

        for k = 1, #btn_tower_modes do
            local btn = btn_tower_modes[k]

            if selected_tower.focus_mode == btn.mode then
                btn["color"] = {0, 144, 255}
            else
                btn["color"] = {50, 50, 50}
            end

            render_button(btn)
        end



    end

    love.graphics.setColor(50, 50, 50, 255)
    love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 80, love.graphics.getHeight() - 35)

end