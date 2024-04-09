if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports.es_extended:getSharedObject()

function ShowNotification(text, type)
	ESX.ShowNotification(text, type)
end

local CurrentMessage
function ShowHelpNotification(text)
    CurrentMessage = text
end
CreateThread(function() -- Frame thread
    while true do
        local sleep = 1000
        if CurrentMessage then
            sleep = 0
            ESX.ShowHelpNotification(CurrentMessage)
        end
        Wait(sleep)
    end
end)

function ServerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb,  ...)
end

function GetPlayerMoney()
    local accounts = ESX.GetPlayerData().accounts
    for i = 1, #accounts do
        if accounts[i].name == 'money' then
            return accounts[i].money
        end
    end
    return false
end

function SetVehicleProperties(vehicle, properties)
    ESX.Game.SetVehicleProperties(vehicle, properties)
end

function GetVehicleProperties(vehicle)
    return ESX.Game.GetVehicleProperties(vehicle)
end

function GetPlate(vehicle)
    return ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
end

function GetClosestVehicle()
    return ESX.Game.GetClosestVehicle()
end

function GainStress(value)
    --Nothing here
end

function Progressbar(name, text, time, options, anim, ok, cancel)
    local opt = options
    opt.animation = anim
    opt.onFinish = ok
    opt.onCancel = cancel

    ESX.Progressbar(text, time, opt)


    --ESX.Progressbar(TranslateCap("prep_raid"), 15000, {FreezePlayer = true, animation = Config.Raiding.Animation, onFinish = function()
    --    ESX.ShowNotification(TranslateCap("raiding"), "success")
    --    AttemptHouseEntry(PropertyId)
    --  end, onCancel = function()
    --    ESX.ShowNotification(TranslateCap("cancel_raiding"), "error")
    --  end})

end

function PoliceAlert(message)
    TriggerServerEvent('police:server:policeAlert', message)
end

function OpenMenu(name, header, items)
    local Menu = {}
    Menu.id = name or ('convert_'..math.random(1, 10000))
    Menu.title = header

    local options = {}
    for k, v in pairs(items) do
        local event
        local serverEvent
        if v.params.isServer then serverEvent = v.params.event or '' else event = v.params.event or '' end

        options[#options + 1] = {
            title = v.header,
            description = v.txt,
            event = event,
            serverEvent = serverEvent,
            args = v.params.args or nil,

            --onSelect = action or nil,
            --disabled = button.isMenuHeader or false,
            --icon = icon,
            --arrow = button.subMenu or false,
        }    
    end
    Menu.options = options
    lib.registerContext(Menu)
    lib.showContext(Menu.id)
end

function UpdateWeaponAmmo(ammo)
    TriggerServerEvent('ox_inventory:updateWeapon', "ammo", ammo)
end

--Target
function AddTargetModel(models, options, distance)
    exports.ox_target:addModel(models, options)
end

function AddTargetEntity(entity, options)
    local distance = options.distance
    options = options.options

    exports.ox_target:addLocalEntity(entity, options)
end

--Events
RegisterNetEvent('esx:playerLoaded',function(xPlayer, isNew, skin)
    CreateNpc()
    if GetResourceState('ox_inventory'):match("start") then
        exports.ox_inventory:displayMetadata({
            plate = 'Plate',
            model = 'Car'
        })
    end

end)

RegisterNetEvent('esx:onPlayerDeath', function()
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
end)
