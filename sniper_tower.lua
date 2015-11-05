

SniperTower = Tower.create()
SniperTower.__index = SniperTower
SniperTower.radius = 10000
SniperTower.cost = 700
SniperTower.name = "Sniper Tower"
SniperTower.shoot_speed = 6.0
SniperTower.shoot_frequency = 1.5
SniperTower.damage = 12

function SniperTower.create()
    local instance = {}
    setmetatable(instance, SniperTower)
    return instance
end



function SniperTower:shoot_projectile()
    local proj = LineProjectile.create()
    proj.target_pos = self.target:get_pos()
    proj.start_pos = self:get_pos()
    proj.damage = self.damage

    self.target:on_hit(self.damage)
    return proj
end

function SniperTower.draw_inner_shape(x, y, upgrade)
    love.graphics.setColor(213, 31, 229, 255)
    love.graphics.rectangle("fill", x - 10, y - 10, 20, 20)

    love.graphics.setColor(30,30,30, 255)

    love.graphics.circle("line", x, y, 6, 20)

    love.graphics.line(x - 5, y, x - 3, y)
    love.graphics.line(x + 3, y, x + 5, y)

    love.graphics.line(x, y - 5, x, y - 3)
    love.graphics.line(x, y + 3, x, y + 5)


    love.graphics.setColor(30,30,30, 255)
    love.graphics.rectangle("line", x - 11, y - 11, 22, 22)

end