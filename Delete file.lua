-- Script pour supprimer les fichiers startup.lua et systeme
local files = {"startup.lua", "systeme"}

for _, file in ipairs(files) do
    if fs.exists(file) then
        fs.delete(file)
        print("Fichier supprimé : " .. file)
    else
        print("Fichier introuvable : " .. file)
    end
end
