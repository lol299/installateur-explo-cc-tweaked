local termX, termY = term.getSize()
local currentPath = "/"
local files = {}
local clickCount = 0
local shortcuts = {}  -- Table des raccourcis ajoutés
local taskbarPositions = {}  -- Pour stocker les positions x de chaque bouton dans la barre

-- Fonction pour s'assurer que le menu reste dans l'écran
local function adjustMenuPosition(menuX, menuY, menuWidth, menuHeight)
    if menuX + menuWidth > termX then
        menuX = termX - menuWidth
    end
    if menuY + menuHeight > termY then
        menuY = termY - menuHeight
    end
    if menuX < 1 then menuX = 1 end
    if menuY < 1 then menuY = 1 end
    return menuX, menuY
end

-- Affiche la liste des fichiers/dossiers du répertoire courant et redessine la barre des tâches
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
    drawTaskbar()
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
    local menuX, menuY = adjustMenuPosition(mX + 2, mY, 10, #menuOptions)
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i - 1)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end

-- Dessine le menu contextuel général (clic droit en dehors de la zone des fichiers)
local function drawGeneralMenu(mX, mY)
    local menuOptions = {}
    table.insert(menuOptions, {text = "Nouveau", color = colors.white})
    table.insert(menuOptions, {text = "Shell", color = colors.blue})
    if currentPath ~= "/" then
        table.insert(menuOptions, {text = "Retour", color = colors.red})
    end
    local menuX, menuY = adjustMenuPosition(mX + 2, mY, 10, #menuOptions)
    for i, option in ipairs(menuOptions) do
        term.setTextColor(option.color)
        term.setCursorPos(menuX, menuY + i - 1)
        print(". " .. option.text)
    end
    term.setTextColor(colors.white)
    return menuOptions, menuX, menuY
end
