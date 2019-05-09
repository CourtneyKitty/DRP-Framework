local handCuffed = false
local drag = false
local officerDrag = -1

RegisterCommand("911", function(source, args, raw)
    local src = source
    local callTarget = args[1]
    local callInformation = table.concat(args, ' ', 2, #args)
    local coords = GetEntityCoords(GetPlayerPed(PlayerId()))
    if callInformation ~= nil then
        if callTarget == "police" then
            TriggerServerEvent("DRP_Police:CallHandler", {x = coords.x, y = coords.y , z = coords.z}, callInformation)
        elseif callTarget == "sheriff" then

        elseif callTarget == "state" then

        elseif callTarget == "cops" then

        end
    end
end)

local callActive = false
local haveTarget = false
local target = {}
Citizen.CreateThread(function()
    while true do 
    Citizen.Wait(1)
        if IsControlJustPressed(1, 73) and callActive then
            target.blip = AddBlipForCoord(target.pos.x, target.pos.y, target.pos.z)
            SetBlipRoute(target.blip, true)
            haveTarget = true
            callActive = false
            SendNotification("Call Accepted")
        elseif IsControlJustPressed(1, 249) and callActive then
            SendNotification("Refused Call")
            callActive = false
        end
        if haveTarget then 
            DrawMarker(1, target.pos.x, target.pos.y, target.pos.z, 0, 0, 0, 0, 0, 0, 2.001, 2.0001, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0)
            local playerPos = GetEntityCoords(GetPlayerPed(-1), true)
            if Vdist(target.pos.x, target.pos.y, target.pos.z, playerPos.x, playerPos.y, playerPos.z) < 2.0 then
                RemoveBlip(target.blip)
                haveTarget = false
            end
        end
    end
end)

RegisterNetEvent("DRP_Police:AwaitingCall")
AddEventHandler("DRP_Police:AwaitingCall", function(coords)
    callActive = true
    target.pos = coords
    SendNotification("Press ~g~X~s~ to accept call or press ~g~N~s~ to refuse call")
    PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS")
end)

Citizen.CreateThread(function()
    while true do 
        if IsControlJustPressed(1, 289) then
            TriggerServerEvent("DRP_Police:CheckIfMenuIsAllowed")
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("DRP_Police:HandCuffToggle")
AddEventHandler("DRP_Police:HandCuffToggle", function()
		handCuffed = not handCuffed
		if(handCuffed) then
			handsup = false
		else
		drag = false
	end
end)

RegisterNetEvent("DRP_Police:EscortToggle")
AddEventHandler("DRP_Police:EscortToggle", function(target)
	if IsPedSittingInAnyVehicle(target) then
		print("person is in a vehicle")
	else
		print("person is not in a vehicle")
		drag = not drag
		officerDrag = target
	end
end)

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(10)

	if handCuffed then
		RequestAnimDict('mp_arresting')
		DisableControlAction(1, 323, true)
		while not HasAnimDictLoaded('mp_arresting') do
			Citizen.Wait(0)
		end

		local myPed = PlayerPedId(-1)
		local animation = 'idle'
		local flags = 16
		handsup = false
		
			while(IsPedBeingStunned(myPed, 0)) do
				ClearPedTasksImmediately(myPed)
			end
			TaskPlayAnim(myPed, 'mp_arresting', animation, 8.0, -8, -1, flags, 0, 0, 0, 0)
		end

		if drag then
			local ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
			local myped = GetPlayerPed(PlayerId())
			AttachEntityToEntity(myped, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		else
			DetachEntity(GetPlayerPed(-1), true, false) 
		end
	end
end)
---------------------------------------------------------------------------
-- LEO CALLBACKS
---------------------------------------------------------------------------
local badgeObject = nil
RegisterNUICallback("showbadge", function(data, cb)
    SetNuiFocus(false, false)
    if badgeObject then
        DeleteEntity(badgeObject)
        badgeObject = nil
    else
        local boneIndex = GetPedBoneIndex(GetPlayerPed(PlayerId()), 4186)
        --local bonePosition = GetPedBoneCoords(GetPlayerPed(PlayerId()), boneIndex, 0.0, 0.0, 0.0) For meh testing cuz I'm cool
        local badgeObjectHash = GetHashKey('prop_fib_badge')
        RequestModel(badgeObjectHash)
        while not HasModelLoaded(badgeObjectHash) do
            Citizen.Wait(150)
        end
        badgeObject = CreateObject(badgeObjectHash, 0.0, 0.0, 0.0, true, false)
        if DoesEntityExist(badgeObject) then
            AttachEntityToEntity(badgeObject, GetPlayerPed(PlayerId()), boneIndex, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 2, 1)
        end
    end
    cb("ok")
end)

RegisterNUICallback("handcuff", function(data, cb)
    SetNuiFocus(false, false)
    local target, distance = GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("DRP_Police:CheckHandCuff", GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
    end
    cb("ok")
end)

RegisterCommand("cuff", function()
    local target, distance = GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("DRP_Police:CheckHandCuff", GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
    end
end) 

-- RegisterNUICallback("search", function(data, cb)

--     local target, distance = GetClosestPlayer()
--     if distance ~= -1 and distance < 3 then
--         TriggerServerEvent("ISRP_Interactions:CheckLEOSearch", GetPlayerServerId(target))
--         cb("ok")
--     end
-- end)

-- RegisterCommand("search", function()
--     local target, distance = GetClosestPlayer()
--     if distance ~= -1 and distance < 3 then
--         TriggerServerEvent("ISRP_Interactions:CheckLEOSearch", GetPlayerServerId(target))
--     end
-- end)

-- RegisterNUICallback("putinvehicle", function(data, cb)
--     local t, distance = GetClosestPlayer()
-- 	if(distance ~= -1 and distance < 3) then
-- 		local v = GetVehiclePedIsIn(GetPlayerPed(-1), true)
-- 		TriggerServerEvent("ISRP_Cops:RequestPutInVehicle", GetPlayerServerId(t), v)
-- 	else
--         TriggerEvent("ISRP_Notification:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
--     end
--     cb("ok")
-- end)

-- RegisterCommand("putinveh", function()
--     local t, distance = GetClosestPlayer()
-- 	if(distance ~= -1 and distance < 3) then
-- 		local v = GetVehiclePedIsIn(GetPlayerPed(-1), true)
-- 		TriggerServerEvent("ISRP_Cops:RequestPutInVehicle", GetPlayerServerId(t), v)
-- 	else
--         TriggerEvent("ISRP_Notification:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
--     end
-- end)

-- RegisterNUICallback("unseatfromvehicle", function(data, cb)
--     local t, distance = GetClosestPlayer()
--     if distance ~= -1 and distance < 3 then
--         TriggerServerEvent("ISRP_Cops:RequestUnseat", GetPlayerServerId(t))
--     else 
--         TriggerEvent("ISRP_Notification:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
--     end
--     cb("ok")
-- end)

-- RegisterCommand("unseatfromveh", function()
--     local t, distance = GetClosestPlayer()
--     if distance ~= -1 and distance < 3 then
--         TriggerServerEvent("ISRP_Cops:RequestUnseat", GetPlayerServerId(t))
--     else 
--         TriggerEvent("ISRP_Notification:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
--     end
-- end)

-- RegisterNUICallback("fine", function(data, cb)
--     local t, distance = GetClosestPlayer()
--     local amount = 0
--     if distance ~= -1 and distance < 3 then
--         DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8S", "", "", "", "", "", 20)
-- 			while (UpdateOnscreenKeyboard() == 0) do
-- 				DisableAllControlActions(0);
-- 				Wait(0);
-- 			end
-- 			if (GetOnscreenKeyboardResult()) then
-- 				local res = tonumber(GetOnscreenKeyboardResult())
-- 				if(res ~= nil and res ~= 0) then
-- 					amount = tonumber(res)
--                 end
--             end
--         TriggerServerEvent("ISRP_Cops:FinePlayer", GetPlayerServerId(t), tonumber(amount))
--     else 
--         TriggerEvent("ISRP_Notification:Info", "Cops", tostring("No Players Near You"), 7000, false, "leftCenter")
--     end
--     cb("ok")
-- end)
---------------------------------------------------------------------------
-- REGULAR CALLBACKS
---------------------------------------------------------------------------
RegisterNUICallback("ziptie", function(data, cb)
    cb("ok")
end)

RegisterNUICallback("drag", function(data, cb)
    SetNuiFocus(false, false)
    local target, distance = GetClosestPlayer()
        if distance ~= -1 and distance < 3 then
            TriggerServerEvent("DRP_Police:CheckLEOEscort", GetPlayerServerId(target))
        else
            TriggerEvent("DRP_Core:Info", "Drag", tostring("No Players Near You"), 7000, false, "leftCenter")
    end
    cb("ok")
end)

RegisterCommand("escort", function()
    local target, distance = GetClosestPlayer()
        if distance ~= -1 and distance < 3 then
            TriggerServerEvent("DRP_Police:CheckLEOEscort", GetPlayerServerId(target))
        else
            TriggerEvent("DRP_Core:Info", "Drag", tostring("No Players Near You"), 7000, false, "leftCenter")
    end
end)

RegisterNUICallback("blindfold", function(data, cb)
    cb("ok")
end)

---------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------
function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(-1)
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

function GetPlayer(ped)
    local players = GetPlayers()
    print(json.encode(players))
    for a = 1, #players do
        if GetPlayerPed(players[a]) == ped then
            return players[a]
        end
    end
end

function GetPlayers()
    local players = {}
    for a = 0, 40 do
        if NetworkIsPlayerActive(a) then
            table.insert(players, a)
        end
    end
    return players
end

function SendNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end