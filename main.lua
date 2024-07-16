local Enemy = require('src.enemy')

love.graphics.setDefaultFilter("nearest", "nearest")

local platform = {}
local player = {}
local counter = 0

local font = love.graphics.newFont(50)
function player:hurt()
    counter = 0
end

function love.load()
    love.graphics.setFont(font)
    Anim8 = require('libs/anim8')
    platform.width = WINDOW_WIDTH
    platform.height = WINDOW_HEIGHT

    platform.x = 0
    platform.y = platform.height / 2

    player.x = WINDOW_WIDTH / 2
    player.y = WINDOW_HEIGHT / 2

    player.speed = 200

    player.img = love.graphics.newImage('assets/images/purple.png')

    player.ground = player.y

    player.y_velocity = 0

    player.jump_height = -300
    player.gravity = -500
end

function love.update(dt)
    counter = counter + dt
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    end

    if love.keyboard.isDown('space') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
        end
    end

    if player.y_velocity ~= 0 then
        player.y = player.y + player.y_velocity * dt
        player.y_velocity = player.y_velocity - player.gravity * dt
    end

    if player.y > player.ground then
        player.y_velocity = 0
        player.y = player.ground
    end

    local collided = Enemy.UpdateEnemies(dt, player.x, player.y)
    if collided then
        player:hurt()
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

    love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)
    Enemy.DrawEnemies()

    love.graphics.print("Hours: " .. counter)
end

function love.keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end
end
