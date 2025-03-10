local QBCore = exports['qb-core']:GetCoreObject()

if not Config.PrinterLocation or not Config.PrinterRadius then
    print("Error: Config.PrinterLocation or Config.PrinterRadius is not set!")
    return
end

local item
local ammount
local printerLocation = Config.PrinterLocation
local printerRadius = Config.PrinterRadius
local orderon = "a"
local orderOwner = nil 
local shipmentReceived = false 
local vehicleBlip = nil 
local deliveryVehicle = nil 
exports['qb-target']:AddCircleZone("printer", printerLocation, printerRadius, {
    name = "printer",
    debugPoly = false,
    useZ = true
}, {
    options = {
        {
            event = "printer:openMenu",
            icon = "fas fa-print",
            label = "رئيس العصابات"
        }
    },
    distance = 2.0
})

RegisterNetEvent('printer:openMenu', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if not PlayerData.job or PlayerData.job.name ~= Config.RequiredRank then
        TriggerEvent('QBCore:Notify', "ليس لديك الصلاحية لفتح القائمة", "error")
        return
    end

    if orderon == "b" then
        TriggerEvent('QBCore:Notify', "لايمكن طلب مره اخرى انتظر", "error")
        return
    end

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "openMenu",
        orders = {
            { name = "سلاح خفيف", type = "weapon_pistol" },
            { name = "رصاص خفيف", type = "pistiol_ammo" },
            { name = "سلاح ثقيل", type = "AK_Raifl" },
            { name = "رصاص سلاح ثقيل", type = "Ak_ammo" }
        }
    })
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('placeOrder', function(data, cb)
    local orderType = data.orderType
    local additionalInfo = data.amma
    item = orderType
    ammount = additionalInfo
    orderOwner = GetPlayerServerId(PlayerId()) 

    orderon = "b"

    local deliveryLocation = Config.PortLocation

    TriggerEvent('printer:spawnDeliveryNPC', deliveryLocation, Config.DeliveryDestination, data.orderType)

    TriggerEvent('QBCore:Notify', "سيتم التوصيل في أقرب وقت", "success")
    cb('ok')
end)

RegisterNetEvent('printer:spawnDeliveryNPC', function(spawnLocation, deliveryLocation, orderType)
    local driverHash = GetHashKey("a_m_m_soucent_02")
    local vehicleHash = GetHashKey("burrito3")
    RequestModel(driverHash)
    RequestModel(vehicleHash)

    while not HasModelLoaded(driverHash) or not HasModelLoaded(vehicleHash) do
        Wait(500)
    end

    deliveryVehicle = CreateVehicle(vehicleHash, spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, true, true)
    local driver = CreatePedInsideVehicle(deliveryVehicle, 4, driverHash, -1, true, false)

    while not DoesEntityExist(deliveryVehicle) do
        Wait(100)
    end

    if GetPlayerServerId(PlayerId()) == orderOwner then
        vehicleBlip = AddBlipForEntity(deliveryVehicle)
        SetBlipSprite(vehicleBlip, 477)
        SetBlipColour(vehicleBlip, 1)
        SetBlipScale(vehicleBlip, 0.8)
        SetBlipAsShortRange(vehicleBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("شحنة العصابة")
        EndTextCommandSetBlipName(vehicleBlip)
    end

    TaskVehicleDriveToCoord(driver, deliveryVehicle, deliveryLocation.x, deliveryLocation.y, deliveryLocation.z, 10.0, 0, vehicleHash, 786603, 1.0, true)

    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            local driverCoords = GetEntityCoords(driver)
            local distance = #(driverCoords - deliveryLocation)

            if distance < 5.0 then
                TriggerEvent('QBCore:Notify', "السائق وصل إلى الموقع", "success")

                TaskLeaveVehicle(driver, deliveryVehicle, 0)
                Wait(2000)

                exports['qb-target']:AddTargetEntity(deliveryVehicle, {
                    options = {
                        {
                            event = "printer:openTrunk",
                            icon = "fas fa-box-open",
                            label = "فتح صندوق السيارة",
                            canInteract = function(entity)
                                return entity == deliveryVehicle and GetPlayerServerId(PlayerId()) == orderOwner
                            end
                        }
                    },
                    distance = 2.0
                })

                break
            end
        end
    end)
end)

RegisterNetEvent('printer:openTrunk', function()
    if shipmentReceived then
        return
    end

    local playerId = GetPlayerServerId(PlayerId())
    
    if playerId ~= orderOwner then
        TriggerEvent('QBCore:Notify', "هذه الشحنة ليست لك!", "error")
        return
    end

    QBCore.Functions.Progressbar("receiving_shipment", "جاري استلام الشحنة...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        local playerPed = PlayerPedId()
        local animDict = "amb@world_human_stand_mobile@male@text@base"
        local animName = "base"
    
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(500)
        end
    
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

        if vehicleBlip then
            RemoveBlip(vehicleBlip)
            vehicleBlip = nil
        end

        orderOwner = nil
        shipmentReceived = true
        TriggerServerEvent('addItemToInventoryServer', item, ammount)

        Wait(5000)

        if deliveryVehicle then
            local driver = CreatePedInsideVehicle(deliveryVehicle, 4, GetHashKey("a_m_m_soucent_02"), -1, true, false)
            
            TaskVehicleDriveToCoord(driver, deliveryVehicle, Config.LeaveLocation.x, Config.LeaveLocation.y, Config.LeaveLocation.z, 10.0, 0, GetHashKey("burrito3"), 786603, 1.0, true)

            Citizen.CreateThread(function()
                Wait(20000)
                DeleteEntity(driver)
                DeleteVehicle(deliveryVehicle)
                deliveryVehicle = nil
            end)
        end
    end)
end)
