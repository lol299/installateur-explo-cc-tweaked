local termX, termY = term.getSize()
local currentPath = "/"
local files = {}
local clickCount = 0

-- Affiche la liste des fichiers/dossiers du répertoire courant
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

-- Ouvre un fichier ou navigue dans un dossier
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

-- Retourne au dossier parent
local function goBack()
    if currentPath ~= "/" then
        currentPath = fs.getDir(currentPath)
        if currentPath == "" then currentPath = "/" end
        listFiles()
    end
end

-- Dessine le menu contextuel pour un fichier à partir de la position du clic (mX, mY)
local function drawMenu(file, mX, mY)
    local fullPath = fs.combine(currentPath, file)
    local isLua = fullPath:match("%.lua$")
    local menuOptions = {}
    if isLua then table.insert(menuOptions, {text = "Executer", color = colors.green}) end
    table.insert(menuOptions, {text = "Renommer", color = colors.white})
    table.insert(menuOptions, {text = "Nouveau", color = colors.white})
    table.insert(menuOptions, {text = "Supprimer", color = colors.red})
    table.insert(menuOptions, {text = "Shell", color = colors.blue})
    table.insert(menuOptions, {text = "Modifier", color = colors.white})
    if currentPath ~= "/" then
        table.insert(menuOptions, {text = "Retour", color = colors.red})
    end
    local menuX, menuY = mX + 2, mY  -- Positionné à droite du clic
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i - 1)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end

-- Dessine le menu contextuel général (pour clic droit en dehors de la zone des fichiers)
local function drawGeneralMenu(mX, mY)
    local menuOptions = {}
    table.insert(menuOptions, {text = "Nouveau", color = colors.white})
    table.insert(menuOptions, {text = "Shell", color = colors.blue})
    if currentPath ~= "/" then
        table.insert(menuOptions, {text = "Retour", color = colors.red})
    end
    local menuX, menuY = mX + 2, mY
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i - 1)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end

-- Dessine le sous-menu "Nouveau" à partir de la position (nX, nY)
local function drawNouveauMenu(nX, nY)
    local submenuOptions = {}
    table.insert(submenuOptions, {text = "Creer fichier", color = colors.white})
    table.insert(submenuOptions, {text = "Creer dossier", color = colors.white})
    for i, option in ipairs(submenuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(nX, nY + i - 1)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return submenuOptions, nX, nY
end

-- Affiche le sous-menu "Nouveau" et gère le clic sur ses options
local function showNouveauMenu(nX, nY)
    local submenuOptions, menuX, menuY = drawNouveauMenu(nX, nY)
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i, option in ipairs(submenuOptions) do
                if y == menuY + i - 1 and x >= menuX and x <= menuX + #option.text + 2 then
                    if option.text == "Creer fichier" then
                        term.setCursorPos(1, termY)
                        term.write("Nom du fichier: ")
                        local fileName = read()
                        local handle = fs.open(fs.combine(currentPath, fileName), "w")
                        if handle then handle.close() end
                    elseif option.text == "Creer dossier" then
                        term.setCursorPos(1, termY)
                        term.write("Nom du dossier: ")
                        local dirName = read()
                        fs.makeDir(fs.combine(currentPath, dirName))
                    end
                    listFiles()
                    return
                end
            end
        end
    end
end

-- Gère le menu contextuel pour un fichier
local function showMenu(file, mX, mY)
    local menuOptions, menuX, menuY = drawMenu(file, mX, mY)
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i, option in ipairs(menuOptions) do
                if y == menuY + i - 1 and x >= menuX and x <= menuX + #option.text + 2 then
                    local fullPath = fs.combine(currentPath, file)
                    local isLua = fullPath:match("%.lua%$")
                    if option.text == "Nouveau" then
                        -- Affiche le sous-menu "Nouveau" à droite du menu principal
                        showNouveauMenu(menuX + 15, menuY + i - 1)
                    elseif option.text == "Shell" then
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

-- Gère le menu contextuel général (clic droit en dehors de la zone des fichiers)
local function showGeneralMenu(mX, mY)
    local menuOptions, menuX, menuY = drawGeneralMenu(mX, mY)
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i, option in ipairs(menuOptions) do
                if y == menuY + i - 1 and x >= menuX and x <= menuX + #option.text + 2 then
                    if option.text == "Nouveau" then
                        showNouveauMenu(menuX + 15, menuY + i - 1)
                    elseif option.text == "Shell" then
                        shell.run("shell")
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

-- Affiche la version et le createur quand on clique 5 fois sur la ligne du titre
local function showVersionInfo()
    term.clear()
    term.setCursorPos(1, 1)
    print("Explorateur de fichiers")
    print("Version De l'explorateur: 1.3")
    print("Version De l'installer: 1.4)
    print("Createur: lol499")
    sleep(5)
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
                showMenu(files[index], x, y)
            end
        else
            if button == 2 then  -- Clic droit en dehors de la zone des fichiers
                showGeneralMenu(x, y)
            end
        end
    end
end

main()
