local firstSpawn = true
---------------------------------------------------------------------------
-- Spawning player into server.. Setup char menu etc..
---------------------------------------------------------------------------
AddEventHandler('playerSpawned', function()
    if firstSpawn then
    Citizen.Wait(555)
        -- TriggerServerEvent("ISRP_Characters:RequestOpenMenu")
        print("yeet")
        firstSpawn = false
    end
end)