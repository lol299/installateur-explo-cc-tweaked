local function deleteAll()
    print("Voulez-vous vraiment supprimer tout le systeme ? (oui/non)")
    local confirmation = read()
    
    if confirmation:lower() == "oui" then
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
        
        print("Suppression terminee. Redemarrage dans 2 secondes...")
        sleep(2)
        os.reboot()
    else
        print("Annulation de la suppression.")
    end
end

deleteAll()
