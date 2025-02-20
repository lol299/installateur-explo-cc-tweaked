local w, h = term.getSize()
local buttons = {}
local input = ""
local result = nil

-- Fonction pour dessiner un bouton
local function drawButton(x, y, text)
    term.setCursorPos(x, y)
    term.write("[" .. text .. "]")
    buttons[#buttons + 1] = {x = x, y = y, text = text}
end

-- Fonction pour afficher la calculatrice
local function drawCalculator()
    term.clear()
    term.setCursorPos(2, 2)
    term.write("Calculatrice")
    
    -- Affichage de l'entrée utilisateur
    term.setCursorPos(2, 4)
    term.write("> " .. input)
    
    -- Affichage du résultat
    if result then
        term.setCursorPos(2, 5)
        term.write("= " .. result)
    end
    
    -- Affichage des boutons
    local startX, startY = 2, 7
    local keys = {"7", "8", "9", "/", "4", "5", "6", "*", "1", "2", "3", "-", "0", ".", "=", "+"}
    
    buttons = {}
    for i, key in ipairs(keys) do
        local x = startX + ((i - 1) % 4) * 4
        local y = startY + math.floor((i - 1) / 4) * 2
        drawButton(x, y, key)
    end
    drawButton(2, startY + 10, "C")
end

-- Fonction pour détecter si un bouton a été cliqué
local function getButtonClicked(x, y)
    for _, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + 2 and y == button.y then
            return button.text
        end
    end
    return nil
end

-- Boucle principale
local function runCalculator()
    drawCalculator()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        local clicked = getButtonClicked(x, y)
        
        if clicked then
            if clicked == "=" then
                local func, err = load("return " .. input)
                if func then
                    result = func()
                else
                    result = "Erreur"
                end
            elseif clicked == "C" then
                input = ""
                result = nil
            else
                input = input .. clicked
            end
            drawCalculator()
        end
    end
end

runCalculator()
