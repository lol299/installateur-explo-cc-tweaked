local termX, termY = term.getSize()
local currentPath = "/"
local files = {}
local clickCount = 0

local function listFiles()
    files = {}
    term.clear()
    term.setCursorPos(1, 1)
    print("Explorateur - " .. currentPath)

    for _, item in ipairs(fs.list(currentPath)) do
        local fullPath = fs.combine(currentPath, item)
        if fs.isDir(fullPath) then
            term.setTextColor(colors.yellow)
            print("[D] " .. item)
        else
            term.setTextColor(colors.white)
            print("    " .. item)
        end
        table.insert(files, item)
    end
    term.setTextColor(colors.white)
end

local function openFile(file)
    local fullPath = fs.combine(currentPath, file)
    if fs.isDir(fullPath) then
        currentPath = fullPath
        listFiles()
    elseif fullPath:match("%.lua$") then
        shell.run(fullPath)
    else
        print("Ce fichier ne peut pas etre execute.")
    end
end

local function goBack()
    if currentPath ~= "/" then
        currentPath = fs.getDir(currentPath)
        if currentPath == "" then currentPath = "/" end
        listFiles()
    end
end

local function drawMenu(file)
    local fullPath = fs.combine(currentPath, file)
    local isLua = fullPath:match("%.lua$")
    local menuOptions = {}

    if isLua then table.insert(menuOptions, {text = "Executer", color = colors.green}) end
    table.insert(menuOptions, {text = "Renommer", color = colors.white})
    table.insert(menuOptions, {text = "Creer dossier", color = colors.white})
    table.insert(menuOptions, {text = "Creer fichier", color = colors.white})
    table.insert(menuOptions, {text = "Supprimer", color = colors.red})
    table.insert(menuOptions, {text = "Shell", color = colors.blue})
    table.insert(menuOptions, {text = "Modifier", color = colors.white})
    
    if currentPath ~= "/" then
        table.insert(menuOptions, {text = "Retour", color = colors.red})
    end

    local menuX, menuY = termX - 20, 2  
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end

local function showMenu(file)
    local menuOptions, menuX, menuY = drawMenu(file)
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i, option in ipairs(menuOptions) do
                if y == menuY + i and x >= menuX and x <= menuX + #option.text + 2 then
                    local fullPath = fs.combine(currentPath, file)
                    local isLua = fullPath:match("%.lua$")
                    
                    if option.text == "Shell" then
                        shell.run("shell")
                    elseif option.text == "Executer" and isLua then
                        shell.run(fullPath)
                    elseif option.text == "Renommer" then
                        term.setCursorPos(1, termY)
                        term.write("Nouveau nom: ")
                        local newName = read()
                        if newName ~= "" then
                            fs.move(fullPath, fs.combine(currentPath, newName))
                        end
                    elseif option.text == "Creer dossier" then
                        term.setCursorPos(1, termY)
                        term.write("Nom du dossier: ")
                        local dirName = read()
                        fs.makeDir(fs.combine(currentPath, dirName))
                    elseif option.text == "Creer fichier" then
                        term.setCursorPos(1, termY)
                        term.write("Nom du fichier: ")
                        local fileName = read()
                        local handle = fs.open(fs.combine(currentPath, fileName), "w")
                        if handle then handle.close() end
                    elseif option.text == "Supprimer" then
                        fs.delete(fullPath)
                    elseif option.text == "Modifier" then
                        shell.run("edit " .. fullPath)
                    elseif option.text == "Retour" then
                        goBack()
                    end

                    listFiles()
                    return
                end
            end
        end
    end
end

local function drawGeneralMenu()
    local menuOptions = {}
    table.insert(menuOptions, {text = "Creer fichier", color = colors.white})
    table.insert(menuOptions, {text = "Shell", color = colors.blue})
    if currentPath ~= "/" then
        table.insert(menuOptions, {text = "Retour", color = colors.red})
    end

    local menuX, menuY = termX - 20, 2
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end

local function showGeneralMenu()
    local menuOptions, menuX, menuY = drawGeneralMenu()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i, option in ipairs(menuOptions) do
                if y == menuY + i and x >= menuX and x <= menuX + #option.text + 2 then
                    if option.text == "Shell" then
                        shell.run("shell")
                    elseif option.text == "Creer fichier" then
                        term.setCursorPos(1, termY)
                        term.write("Nom du fichier: ")
                        local fileName = read()
                        local handle = fs.open(fs.combine(currentPath, fileName), "w")
                        if handle then handle.close() end
                    elseif option.text == "Retour" then
                        goBack()
                    end
                    listFiles()
                    return
                end
            end
        end
    end
end

local function showVersionInfo()
    term.clear()
    term.setCursorPos(1, 1)
    print("Explorateur de fichiers")
    print("Version de l'explorateur: 1.2")
    print("Version de l'installer: 1.4")
    print("Createur: lol499")
    sleep(2)
    listFiles()
end

local function main()
    listFiles()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        
        -- Clic sur la ligne du titre "Explorateur - [chemin]"
        if y == 1 and x >= 1 and x <= #("Explorateur - " .. currentPath) then
            clickCount = clickCount + 1
            if clickCount >= 5 then
                showVersionInfo()
                clickCount = 0
            end
        else
            clickCount = 0
        end

        local index = y - 1
        if index > 0 and index <= #files then
            if button == 1 then  -- Clic gauche sur un fichier
                openFile(files[index])
            elseif button == 2 then  -- Clic droit sur un fichier
                showMenu(files[index])
            end
        else
            -- Clic droit en dehors de la zone des fichiers
            if button == 2 then
                showGeneralMenu()
            end
        end
    end
end

main()
