local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPlants = 0
local cokePlants = {}

-- Entrar no laboratorio
RegisterNetEvent('mt-coke:client:SairProcesso', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    SetEntityCoords(ped, Config.EntradaLab)
end)

-- Sair do laboratorio
RegisterNetEvent('mt-coke:client:EntrarProcesso', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    SetEntityCoords(ped, Config.SaidaLab)
end)

-- Evento de processo
RegisterNetEvent('mt-coke:client:ComecarProcesso', function()
    local playerPed = PlayerPedId()
    QBCore.Functions.Progressbar("CokeProcess1", "STARTING PROCESS...", 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 16,
    }, {}, {}, function()
        --[[local playerPed = PlayerPedId()
        local success = exports['qb-lock']:StartLockPickCircle(5,20)
   if success then
    QBCore.Functions.Progressbar("CokeProcess1", "PROCESSING COKE...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 16,
    }, {}, {}, function()]]
        StopAnimTask(ped, dict, "machinic_loop_mechandplayer", 1.0)
        TriggerServerEvent("mt-coke:server:ProcessarCoke")
        ClearPedTasks(playerPed)
    end)
   --[[else
        QBCore.Functions.Notify("Falhado!", "error")
        ClearPedTasks(playerPed)
        end
    end)]]
end)

-- Menu de processo
RegisterNetEvent('mt-coke:client:MenuProcessarCoke', function()
    exports['qb-menu']:openMenu({
        {
            id = 1,
            header = "Processing Table",
            txt = ""
        },
        {
            id = 2,
            header = "Process Coke",
            txt = "Needed: <br> 30 - Coke Empty Bags <br> 20 - Coke Leafs",
            params = {
                event = "mt-coke:client:ComecarProcesso",
            }
        },
        {
            id = 6,
            header = "< Close",
            txt = "",
            params = {
                event = "qb-menu:closeMenu",
            }
        },

    })
end)

-- Target para entrar no laboratorio
Citizen.CreateThread(function ()
    exports['qb-target']:AddBoxZone("EntradaLab", vector3(1522.65, 6329.19, 24.61), 1, 1, {
        name = "EntradaLab",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                type = "Client",
                event = "mt-coke:client:EntrarProcesso",
                icon = "fas fa-door-open",
                label = "Get In",
            },
        },
        distance = 2.5
    })
end)

Citizen.CreateThread(function ()
    exports['qb-target']:AddBoxZone("SaidaLab", vector3(1088.77, -3187.66, -38.99), 1, 1, {
        name = "SaidaLab",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                type = "Client",
                event = "mt-coke:client:SairProcesso",
                icon = "fas fa-door-open",
                label = "Get Out",
            },
        },
        distance = 2.5
    })
end)

Citizen.CreateThread(function ()
    exports['qb-target']:AddBoxZone("ProcessoCoke", vector3(1092.84, -3195.72, -39.82), 4.5, 1, {
        name = "ProcessoCoke",
        heading = 270,
        debugPoly = false,
    }, {
        options = {
            {
                type = "Client",
                event = "mt-coke:client:MenuProcessarCoke",
                icon = "fas fa-leaf",
                label = "Process Coke",
            },
        },
        distance = 2.5
    })
end)

-- Apanhar Plantas
RegisterNetEvent('mt-coke:client:ApanharCoke', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local nearbyObject, nearbyID
	for i=1, #cokePlants, 1 do
		if GetDistanceBetweenCoords(coords, GetEntityCoords(cokePlants[i]), false) < 1.2 then
			nearbyObject, nearbyID = cokePlants[i], i
		end
	end
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
			if nearbyObject and IsPedOnFoot(playerPed) then
				isPickingUp = true
				TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)
                QBCore.Functions.Progressbar("HAVERSTCOKE", "HAVERTING PLANT..", 6500, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
				ClearPedTasks(playerPed)
				Wait(1000)
				DeleteObject(nearbyObject) 
				table.remove(cokePlants, nearbyID)
				spawnedPlants = spawnedPlants - 1
				TriggerServerEvent('mt-coke:server:ApanharCoke')
            end)
			else
				QBCore.Functions.Notify('You are too far away..', 'error', 3500)
			end
		else
			QBCore.Functions.Notify('You dont have a trowel!', 'error', 3500)
		end
	end, "trowel")
end)


-- Pegar Coordenadas
CreateThread(function()
	while true do
		Wait(10)
		local coords = GetEntityCoords(PlayerPedId())
		if GetDistanceBetweenCoords(coords, Config.CokeField, true) < 50 then
			SpawncokePlants()
			Wait(500)
		else
			Wait(500)
		end
	end
end)

-- Eliminar Plantas ao Apanhar
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(cokePlants) do
			DeleteObject(v)
		end
	end
end)

-- Spawn Plantas
function SpawnObject(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(1)
	end
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if cb then
        cb(obj)
    end
end

-- Gerar Coordenadas para as Plantas
function SpawncokePlants()
	while spawnedPlants < 15 do
		Wait(1)
		local plantCoords = GeneratePlantsCoords()
		SpawnObject('prop_bush_dead_02', plantCoords, function(obj)
			table.insert(cokePlants, obj)
			spawnedPlants = spawnedPlants + 1
		end)
	end
end 

-- Validar Coordenadas
function ValidatePlantsCoord(plantCoord)
	if spawnedPlants > 0 then
		local validate = true
		for k, v in pairs(cokePlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end
		if GetDistanceBetweenCoords(plantCoord, Config.CokeField, false) > 50 then
			validate = false
		end
		return validate
	else
		return true
	end
end

-- Gerar Box Coords
function GeneratePlantsCoords()
	while true do
		Wait(1)
		local cokeCoordX, cokeCoordY
		math.randomseed(GetGameTimer())
		local modX = math.random(-15, 15)
		Wait(100)
		math.randomseed(GetGameTimer())
		local modY = math.random(-15, 15)
		cokeCoordX = Config.CokeField.x + modX
		cokeCoordY = Config.CokeField.y + modY
		local coordZ = GetCoordZPlants(cokeCoordX, cokeCoordY)
		local coord = vector3(cokeCoordX, cokeCoordY, coordZ)
		if ValidatePlantsCoord(coord) then
			return coord
		end
	end
end

-- Verificar Altura das Coordenadas
function GetCoordZPlants(x, y)
	local groundCheckHeights = { 35, 36.0, 37.0, 38.0, 39.0, 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0 }
	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
		if foundGround then
			return z
		end
	end
	return 53.85
end

--Target para apanha
exports['qb-target']:AddTargetModel(`prop_bush_dead_02`, {
    options = {
        {
            event = "mt-coke:client:ApanharCoke",
            icon = "fas fa-seedling",
            label = "Havert Plant",
        },
    },
    distance = 2.0
})
