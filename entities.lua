
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

    for i = 1, 10+wave_id*wave_id do
        
        local entity = Entity.create()
        entity.speed = 2.0 + wave_id * 0.3
        entity.max_hp = 10 + wave_id * 2
        entity.money = 20 + wave_id * 1

        -- Blau (Tank)
        if i % math.max(0, 5 - wave_id) == 0 then
            entity.color = {255, 255, 100}
            entity.max_hp = entity.max_hp * 2
        end

        -- Boss (Tank)
        if i==1 and wave_id>0 then
            entity.color = {255, 100, 0}
            entity.max_hp = entity.max_hp * 100
            entity.speed = 2.0
            entity.size = 30
        end
        
        entity.hp = entity.max_hp
        table.insert(objs, entity)
    end

    wave_spawn_rate = 2.0 / (wave_id*0.2 + 2)

    return objs
end

