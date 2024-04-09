if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function ServerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb,  ...)
end

function ShowNotification(text, type)
	QBCore.Functions.Notify(text, type)
end

function ShowHelpNotification(text)
    local DrawTextLocation
    if text then
        exports['qb-core']:DrawText(text, DrawTextLocation)
    else
        exports['qb-core']:HideText()        
    end
end

function GetPlayerMoney()
    return QBCore.Functions.GetPlayerData().money['cash']
end

function SetVehicleProperties(vehicle, properties)
    QBCore.Functions.SetVehicleProperties(vehicle, properties)
end

function GetVehicleProperties(vehicle)
    return QBCore.Functions.GetVehicleProperties(vehicle)
end

function GetPlate(vehicle)
    return QBCore.Functions.GetPlate(vehicle)
end

function GetClosestVehicle()
    return QBCore.Functions.GetClosestVehicle()
end

function GainStress(value)
    TriggerServerEvent('hud:server:GainStress', value)
end

function Progressbar(name, text, time, options, anim, ok, cancel)
    QBCore.Functions.Progressbar(name, text, time, false, true, options, anim, {}, {}, ok, cancel)
end

function PoliceAlert(message)
    TriggerServerEvent('police:server:policeAlert', message)
end

function OpenMenu(name, header, items)
    local Menu = {
        [1] = {
            header = header,
            isMenuHeader = true,
        }
    }
    for k, v in pairs(items) do
        Menu[#Menu + 1] = v
    end
    exports['qb-menu']:openMenu(Menu)
end

local CurrentWeaponData
function UpdateWeaponAmmo(ammo)
    TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, ammo)
end
AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if bool ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
end)

--Target
function AddTargetModel(models, options, distance)
    exports['qb-target']:AddTargetModel(models, {options = options, distance = distance})
end
function AddTargetEntity(entity, options)
    exports['qb-target']:AddTargetEntity(entity, options)
end

--Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    CreateNpc()
    if GetResourceState('ox_inventory'):match("start") then
        exports.ox_inventory:displayMetadata({
            plate = 'Plate',
            model = 'Car'
        })
    end
end)
