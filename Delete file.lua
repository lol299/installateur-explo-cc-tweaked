local function deleteFiles()
    local files = {
        "systeme/jeux/snake",
        "systeme/programme/calculatrice",
        "systeme/programme/lecteur_mp3",
        "systeme/programme/lecteur_video",
        "systeme/delete.lua"
    }
    
    for _, file in ipairs(files) do
        if fs.exists(file) then
            fs.delete(file)
            print("Fichier supprime : " .. file)
        end
    end
    
    print("Tous les fichiers installes ont ete supprimes.")
end

-- Execution du script
deleteFiles()
