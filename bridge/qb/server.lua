if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

function UpdateDatabase(damage, position, plate, vehicle)
    MySQL.update('UPDATE player_vehicles SET fuel = ?, engine = ?, body = ?, location = ?, damages = ? WHERE plate = ?', {vehicle.fuel, vehicle.engine, vehicle.body, position, damage, plate})
end

function GetDatabase()
    return 'player_vehicles'
end

function GetDatabaseKeyPlate()
    return 'plate'
end

function GetDatabaseKeyOwner()
    return 'citizenid'
end

function GetDatabaseStoredField()
    return 'state'
end

function GetDatabasePropsField(entry)
    return json.decode(entry.mods)
end

function GetDatabaseVehicleModel(entry)
    return GetHashKey(entry.vehicle)
end

function GetDatabaseVehicleOwner(entry)
    return entry.citizenid
end

function GetDatabaseVehicleBody(entry)
    return entry.body
end

function GetDatabaseVehicleEngine(entry)
    return entry.engine
end

function GetDatabaseVehicleFuel(entry)
    return entry.fuel
end

function RestoreVehicleKeys(plate, owner)
    TriggerEvent('qb-vehiclekeys:server:RestoreVehicleKeys', plate, owner)
end

function RegisterCallback(name, cb, ...)
    QBCore.Functions.CreateCallback(name, cb, ...)
end

function RegisterUsableItem(...)
    QBCore.Functions.CreateUseableItem(...)
end

function CommandRegister(command, text, args, level, cb)
    QBCore.Commands.Add(command, text, args, false, cb, level)
end

function CommandEventTrigger(event, source, ...)
    TriggerClientEvent(event, source, ...)
end

function CommandGetArgs(esx, qb)
    if qb then
        return qb
    else
        return esx
    end
end

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source)
    local source = tonumber(source)
    local xPlayer = QBCore.Functions.GetPlayer(source).PlayerData
    return xPlayer.citizenid 
end

function PlayersGet()
    return QBCore.Functions.GetPlayers()
end

function SetPlayerMetadata(source, key, data)
    local source = tonumber(source)
    QBCore.Functions.GetPlayer(source).Functions.SetMetaData(key, data)
end

function AddMoney(source, count)
    local source = tonumber(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddMoney('cash',count)
end

function RemoveMoney(source, count)
    local source = tonumber(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    xPlayer.Functions.RemoveMoney('cash',count)
end

function GetMoney(source)
    local source = tonumber(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    return xPlayer.PlayerData.money.cash
end

function AddInventory(source, item, count, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem(item, count, false, metadata)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[item], "add")
end

function RemoveInventory(source, item, count, slot)
    local source = tonumber(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer.Functions.RemoveItem(item, count, slot) then
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[item], "remove")
        return true
    else
        return false
    end
    
end

function CheckInventory(source, item, count)
    return true
end

function GetInventoryMetadata(item)
    return item.info
end

function GetItemsByNameInventory(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	return Player.Functions.GetItemsByName(item)
end

function AddWeapon(source, weapon, ammo)
    -- Nothing to do here
end

function ShowNotification(source, text, type)
    TriggerClientEvent('QBCore:Notify', source, text, type)
end

function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function CreateUseableItem(item, event)
    QBCore.Functions.CreateUseableItem(item, function(source)
        TriggerClientEvent(event, source, false)
    end)
end

