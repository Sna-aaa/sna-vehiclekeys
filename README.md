# sna-vehiclekeys
Vehicle keys as items

## Support
Please join my discord : https://discord.gg/kvSwVzD8Rd

## Features
- The key is created with the vehicle plate and model in item description
- Keys are given at car buy (events available)
- The locksmith is used to buy additional keys and change locks of a car
- When a player tries to enter the car, it check the lock value of the car
- Npc cars are accessible the gta way (carjacking or window breaking)
- If car is locked the player can lockpick it, else the player can enter
- Once the player is in the car a check is made for the key item in inventory to start the engine
- If the player have no key he can try to hotwire the car
- For admin cars (/car) the car is now yours temporarly, so you have an "old style invisible key"
- When a job spawn a free car, the player receives the same old style key, so no hotwire
- When a car is sold, the key can be removed
- Keys are never deleted or removed, and not given by the garage anymore, you need to keep the keys in your inventory or storage

## Requirements
- [es_extended] or [qb-core]
- [ox_inventory] or [qb-inventory]
- [ox_target] or [qb-target]
- [qb-lockpick](https://github.com/Sna-aaa/qb-lockpick)

## Installation for QBCore
- Delete qb-vehiclekeys from qbcore

- Install the new resource with a name THAT IS NOT qb-vehiclekeys

- Copy the vehiclekeys image in img folder into qb-inventory\html\images

- Import QBCore part of database.sql into your database

- Add in qb-core/shared/items.lua
```lua
    vehiclekey                   = { name = 'vehiclekey', label = 'Vehicle key', weight = 10, type = 'item', image = 'vehiclekey.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = "This is a car key, take good care of it, if you lose it you probably won't be able to use your car" },
```
- Add item info to qb-inventory\html\js\app.js around line 395 in function generateDescription
```js
        case "labkey":
            return `<p>Lab: ${itemData.info.lab}</p>`;
        case "vehiclekey":                                                                      //Change Add
                return `<p><strong>Car: </strong><span>${itemData.info.model}</span></p>
                <p><strong>Plate: </strong><span>${itemData.info.plate}</span></p>`;            //Change Add
        default:
            return itemData.description;
```

## Installation for ESX
- Copy the vehiclekeys image in img folder into ox_inventory\web\images

- Import ESX part of database.sql into your database

- Add in ox_inventory\data\items.lua
```lua
	['vehiclekey'] = {
		label = 'Vehicle Key',
		stack = false,
		weight = 1,
		client = {
			image = 'vehiclekey.png'
		}
	},
```

## Integration into your framework
Basically this script needs some event to be triggered at some points, 2 client events are available
```lua
TriggerEvent("vehiclekeys:client:SetOwner", plate)
TriggerEvent('sna-vehiclekeys:server:BuyVehicle', plate, model)
```
SetOwner event is used for temporary vehicles (all unowned vehicles like job spawned vehicles or admin cars) it makes you owner of the vehicle without having a physical key
This event is present everywhere in QBCore and must remain excepted in the garage script and the vehicle shop script where it must be commented/deleted
This event is not present in ESX as there is no native support for keys, you must then add it for the temporary vehicles spawns

BuyVehicle event is used to give a physical key for a vehicle, this event must be added in the vehicle shop script after the vehicle spawn when you have a plate

For QBCore, you can also search for qb-vehiclekeys:server:AcquireVehicleKeys, this must be replaced with the event sna-vehiclekeys:server:BuyVehicle or sna-vehiclekeys:server:GiveTempKey depending of the type of key you want to grant (temporary or physical) 

Here are the examples of the events correctly placed, to be adapted to your scripts
```lua
RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    tempShop = insideShop -- temp hacky way of setting the shop because it changes after the callback has returned since you are outside the zone
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.Shops[tempShop]["VehicleSpawn"].w)
        --TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))                                                       --Change comment
        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
        TriggerServerEvent('qb-vehiclekeys:server:BuyVehicle', plate, GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh))))   --Change Add
    end, vehicle, Config.Shops[tempShop]["VehicleSpawn"], true)
end)

RegisterNetEvent('qb-garages:client:takeOutGarage', function(data)
    local type = data.type
    local vehicle = data.vehicle
    local garage = data.garage
    local index = data.index
    QBCore.Functions.TriggerCallback('qb-garage:server:IsSpawnOk', function(spawn)
        if spawn then
            local location
            if type == "house" then
                location = garage.takeVehicle
            else
                location = garage.spawnPoint
            end
            QBCore.Functions.TriggerCallback('qb-garage:server:spawnvehicle', function(netId, properties)
                local veh = NetToVeh(netId)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, index)
                closeMenuFull()
                --TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))                   --Change comment
                SetVehicleEngineOn(veh, true, true)
                if type == "house" then
                    exports['qb-core']:DrawText(Lang:t("info.park_e"), 'left')
                    InputOut = false
                    InputIn = true
                end
            end, vehicle, location, true)
        else
            QBCore.Functions.Notify(Lang:t("error.not_impound"), "error", 5000)
        end
    end, vehicle.plate, type)
end)

ESX.RegisterServerCallback('esx_vehicleshop:buyVehicle', function(source, cb, model, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local modelPrice = getVehicleFromModel(model).price

	if modelPrice and xPlayer.getMoney() >= modelPrice then
		xPlayer.removeMoney(modelPrice, "Vehicle Purchase")

		MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {xPlayer.identifier, plate, json.encode({model = joaat(model), plate = plate})
		}, function(rowsChanged)
			xPlayer.showNotification(TranslateCap('vehicle_belongs', plate))
			ESX.OneSync.SpawnVehicle(joaat(model), Config.Zones.ShopOutside.Pos, Config.Zones.ShopOutside.Heading,{plate = plate}, function(vehicle)
				Wait(100)
				local vehicle = NetworkGetEntityFromNetworkId(vehicle)
				Wait(300)
				TriggerClientEvent('qb-vehiclekeys:client:BuyVehicle', source, plate)			--Change
				TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
			end)
			cb(true)
		end)
	else
		cb(false)
	end
end)
```


This event can be used to automatically remove a key from player's inventory (for exceptionnal use like rent end)
```lua
    TriggerServerEvent('qb-vehiclekeys:server:RemoveKey', plate)
```