
LaserTower = Tower.create()
LaserTower.__index = LaserTower
LaserTower.radius = 270
LaserTower.cost = 900
LaserTower.name = "Laser Tower"
LaserTower.shoot_speed = 3.0


function LaserTower.draw_inner_shape(x, y, upgrade)

    love.graphics.setColor(229, 213, 31, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    love.graphics.setColor(30,30,30, 120)
    love.graphics.polygon("fill", x, y - 6,  x - 6, y + 6, x + 6, y + 6)
    love.graphics.polygon("fill", x - 10, y - 10,  x - 5, y - 10, x - 10, y - 5)
    -- love.graphics.polygon("fill", x + 10, y - 10,  x + 5, y - 10, x + 10, y - 5)
    love.graphics.polygon("fill", x + 10, y + 5, x + 10, y + 10, x + 5, y + 10)

    love.graphics.setColor(30,30,30, 255)
    love.graphics.rectangle("line", x - 11, y - 11, 22, 22)


end


function LaserTower.create()
    local instance = {}
    setmetatable(instance, LaserTower)
    return instance

end

function LaserTower:shoot_projectile()
    local proj = Tower.shoot_projectile(self)
    proj.laserProjectile = true
    return proj
end


function LaserTower:get_upgrade_cost()
    return 300 + self.upgrade * 100
end

