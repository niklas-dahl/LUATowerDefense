
entities = {}
entity_queue = {}

function closest_entity(pos)

    local closest_dist = 100000.0
    local closest = nil

    for i = 1, #entities do
        local entity = entities[i]
        if entity ~= nil then
            local dist = Vector.distance(pos, entity:get_pos())
            if dist < closest_dist then
                closest_dist = dist
                closest = entity
            end
        end
    end
    return closest
end


function spawn_wave()
    local objs = {}

    for i = 1, 10+wave_id do

        local entity = Entity.create()
        entity.speed = 2.0 + wave_id * 0.2
        entity.max_hp = 10 + wave_id * 1
        entity.money = 20 + wave_id * 1
        entity.color = {151, 188, 38}
        entity.size = 10

        -- Blau (Tank)
        if i % 3 == 0 then
            entity.color = {47, 71, 196}
            entity.max_hp = entity.max_hp + 5
            entity.size = 13
            entity.money = entity.money + 5
        end

        -- Schnelle Einheiten
        if i % math.max(1, 10 - wave_id) == 0 then
            entity.speed = entity.speed + 0.5
            entity.money = entity.money + 5
        end

        -- Boss (Tank)
        if i % 10 == 9 and wave_id > 2 then
            entity.color = {180, 40, 67}
            entity.max_hp = entity.max_hp * 10
            entity.speed = 1.0
            entity.size = 17
            entity.money = entity.money + 15
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
    selected_tower = nil
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
