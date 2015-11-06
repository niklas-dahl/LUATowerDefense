
entities = {}
entity_queue = {}



function criteria_closest(pos, entity)
    return -Vector.distance(pos, entity:get_pos())
end

function criteria_first(pos, entity)
    return entity.progress
end

function criteria_last(pos, entity)
    return -entity.progress
end

function criteria_strongest(pos, entity)
    return entity.hp
end



-- Modes:
-- Furthest -> get the entity in range which has progressed most
-- Closest -> get the entity in range which is closest
-- Last -> get the entity which has progressed least
-- Strongest -> get the entity in range which has the most hp
function closest_entity(pos, max_radius, mode)

    mode = mode or "First"
    -- max_radius = max_radius or 10000

    local criteria_fnc = nil

    if mode == "First" then
        criteria_fnc = criteria_first
    elseif mode == "Last" then
        criteria_fnc = criteria_last
    elseif mode == "Closest" then
        criteria_fnc = criteria_closest
    elseif mode == "Strongest" then
        criteria_fnc = criteria_strongest
    else
        print("INVALID MODE: " .. mode)
    end        

    local best_criteria = -100000000.0
    local best = nil

    for i = 1, #entities do
        local entity = entities[i]
        if entity ~= nil then
            local dist = Vector.distance(pos, entity:get_pos())
            if dist < max_radius then
                local crit = criteria_fnc(pos, entity)
                if crit > best_criteria then
                    best = entity
                    best_criteria = crit
                end
            end
        end
    end
    return best
end


function spawn_wave()
    local objs = {}

    for i = 1, 10+wave_id do

        local entity = Entity.create()
        entity.speed = 2.0 + wave_id * 0.13
        entity.max_hp = 15 + wave_id * 9
        entity.money = 15 + wave_id * 0.6
        entity.color = {206, 156, 58}
        entity.size = 10

        -- Blau (Tank)
        if i % 3 == 0 then
            entity.color = {47, 71, 196}
            entity.max_hp = entity.max_hp + 2 * wave_id
            entity.size = 13
            entity.money = entity.money + 1
        end

        -- Schnelle Einheiten
        if i % math.max(1, 10 - wave_id) == 0 then
            entity.speed = entity.speed + 0.3
        end

        -- Boss (Tank)
        if i % 10 == 9 and wave_id > 2 then
            entity.color = {180, 40, 67}
            entity.max_hp = entity.max_hp * 7
            entity.speed = 1.0
            entity.size = 17
            entity.money = entity.money + 2
        end
        
        entity.money = math.floor(entity.money)

        entity.hp = entity.max_hp
        table.insert(objs, entity)
    end

    wave_spawn_rate = 2.0 / (wave_id*0.2 + 2)

    return objs
end


function start_wave()
    -- tower_under_cursor = nil
    simulation_running = true
    -- selected_tower = nil
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
    if fast_forward then
        start_wave()
    end
end
