local function deleteAll()
    print("Suppression de tous les fichiers et dossiers installes...")
    
    if fs.exists("systeme") then
        fs.delete("systeme")
        print("Dossier systeme supprime.")
    else
        print("Aucun dossier systeme trouve.")
    end
    
    if fs.exists("startup.lua") then
        fs.delete("startup.lua")
        print("startup.lua supprime.")
    end
    
    print("Suppression terminee.")
end

deleteAll()
