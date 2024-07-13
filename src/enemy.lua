local spritesheet = require('src.spritesheet')
local object = require('libs.classic')

ENEMY_SPEED = 300
ENEMY_SCALE = 2

local flipDelay = 2
local walkDelay = 2
local enemies = {}

local Enemy = {} -- module
local enemy = object:extend()


function Enemy.New(entity)
    local e = enemy(entity)
    table.insert(enemies, e)
    return e
end

function enemy:new(entity)
    self.image = love.graphics.newImage('assets/images/snek-anims.png')
    self.animGrid = spritesheet.NewAnim8Grid(self.image, TILE_SIZE, TILE_SIZE)
    self.animations = {}
    self.animations.idle = Anim8.newAnimation(self.animGrid('1-6', 1), 0.2)
    self.animations.walk = Anim8.newAnimation(self.animGrid('1-4', 2), 0.1)
    self.animations.attac = Anim8.newAnimation(self.animGrid('1-5', 3), 0.1, function() self:resetAnim() end)
    self.animations.frozen = Anim8.newAnimation(self.animGrid('1-1', 4), 0.5, 'pauseAtEnd')
    self.animations.ded = Anim8.newAnimation(self.animGrid('2-3', 4), 0.3, 'pauseAtEnd')
    self.currentAnim8 = self.animations.walk

    self.x = entity.x
    self.y = entity.y
    self.scaleX, self.scaleY = ENEMY_SCALE, ENEMY_SCALE
    self.width = TILE_SIZE * ENEMY_SCALE
    self.height = TILE_SIZE * ENEMY_SCALE

    self.flipTimer = flipDelay
    self.walkTimer = walkDelay
    self.resting = false
end

function enemy:attak(player)
    if self.frozen then return false end

    if player.x > self.x then
        self.facing = RIGHT
    else
        self.facing = LEFT
    end

    self.currentAnim8 = self.animations.attac
    return true
end

function enemy:resetAnim()
    self.currentAnim8 = self.animations.idle
end

function enemy:freeze()
    if self.dead then return end

    self.currentAnim8 = self.animations.frozen
end

function enemy:hit(isBullet)
    if self.frozen then
        -- player or bullet kills
        self.currentAnim8 = self.animations.ded
        self.dead = true
    else
        if isBullet then
            self.frozen = true
        end
    end
end

function enemy:draw()
    love.graphics.setColor(1, 1, 1)
    self.currentAnim8:draw(
        self.image,
        self.x,
        self.y - self.height,
        0,
        self.scaleX,
        self.scaleY)
end

function enemy:checkCollision(playerX, playerY)
    local x1 = self.x
    local y1 = self.y
    local w1 = self.width * ENEMY_SCALE
    local h1 = self.height * ENEMY_SCALE

    local x2 = playerX
    local y2 = playerY
    local w2 = TILE_SIZE
    local h2 = TILE_SIZE

    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function enemy:update(dt, playerX, playerY)
    local collided = false
    if self:checkCollision(playerX, playerY) then
        collided = true
    end
    self.currentAnim8:update(dt)

    if self.dead then return end

    self.x = self.x - dt * ENEMY_SPEED

    return collided
end

function Enemy.DrawEnemies()
    for _, e in ipairs(enemies) do
        e:draw()
    end
end

function Enemy.UpdateEnemies(dt, playerX, playerY)
    local collided = false
    for _, e in ipairs(enemies) do
        collided = e:update(dt, playerX, playerY)
    end
    return collided
end

return Enemy
