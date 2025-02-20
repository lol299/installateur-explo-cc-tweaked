-- Configuration
local width, height = term.getSize()
local snake = {{x = math.floor(width/2), y = math.floor(height/2)}}
local direction = "right"
local apple = {x = math.random(2, width-1), y = math.random(2, height-1)}
local running = true
 
-- Dessiner la pomme
local function drawApple()
    term.setCursorPos(apple.x, apple.y)
    term.setTextColor(colors.red)
    term.write("O")
    term.setTextColor(colors.white)
end
 
-- Dessiner le serpent
local function drawSnake()
    for _, segment in ipairs(snake) do
        term.setCursorPos(segment.x, segment.y)
        term.write("#")
    end
end
 
-- Vérifier les collisions
local function checkCollision(x, y)
    if x < 1 or x > width or y < 1 or y > height then
        return true
    end
    for i = 2, #snake do
        if snake[i].x == x and snake[i].y == y then
            return true
        end
    end
    return false
end
 
-- Générer une nouvelle pomme
local function newApple()
    repeat
        apple.x = math.random(2, width-1)
        apple.y = math.random(2, height-1)
    until not checkCollision(apple.x, apple.y)
end
 
-- Mettre à jour le jeu
local function update()
    local head = snake[1]
    local newHead = {x = head.x, y = head.y}
    if direction == "up" then newHead.y = newHead.y - 1
    elseif direction == "down" then newHead.y = newHead.y + 1
    elseif direction == "left" then newHead.x = newHead.x - 1
    elseif direction == "right" then newHead.x = newHead.x + 1
    end
    
    if checkCollision(newHead.x, newHead.y) then
        running = false
        return
    end
    
    table.insert(snake, 1, newHead)
    if newHead.x == apple.x and newHead.y == apple.y then
        newApple()
    else
        table.remove(snake)
    end
end
 
-- Gestion des touches
local function handleInput()
    while running do
        local event, key = os.pullEvent("key")
        if key == keys.up and direction ~= "down" then direction = "up"
        elseif key == keys.down and direction ~= "up" then direction = "down"
        elseif key == keys.left and direction ~= "right" then direction = "left"
        elseif key == keys.right and direction ~= "left" then direction = "right"
        end
    end
end
 
-- Boucle principale
local function main()
    term.clear()
    drawApple()
    parallel.waitForAny(
        function()
            while running do
                term.clear()
                drawApple()
                drawSnake()
                update()
                sleep(0.2)
            end
        end,
        handleInput
    )
    term.clear()
    term.setCursorPos(math.floor(width/2 - 5), math.floor(height/2))
    print("Game Over!")
end
 
main()
 
