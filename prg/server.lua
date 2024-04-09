local VehicleList = {}

local function ChangeLocks(plate)
	local result = MySQL.single.await('SELECT `lock` FROM '..GetDatabase()..' WHERE '..GetDatabaseKeyPlate()..' = ?', { plate })
	if result then
		local lock = result.lock
		if lock then
			lock = lock + 1
		else
			lock = 4321
		end
		MySQL.update('UPDATE '..GetDatabase()..' SET `lock` = ? WHERE '..GetDatabaseKeyPlate()..' = ?', {lock, plate})
	end
end

local function GiveKey(plate, model, player, src)
	local result = MySQL.single.await('SELECT `lock` FROM '..GetDatabase()..' WHERE '..GetDatabaseKeyPlate()..' = ?', { plate })
	if result then
		local lock = result.lock
		local info = {}
		if lock then
			info.lock = lock
			info.plate = plate
			info.model = model
			if CheckInventory(src, 'vehiclekey', 1) then
				AddInventory(src, 'vehiclekey', 1, info)
			end
			ShowNotification(src, Lang:t("message.key_received"), 'success')
		else
			ShowNotification(src, Lang:t("message.not_initialized"), 'error')
		end
	end
end

RegisterNetEvent('sna-vehiclekeys:server:BuyVehicle', function(plate, model)
	local src = source
	local Player = GetPlayer(src)
	ChangeLocks(plate)
	Wait(100)
	GiveKey(plate, model, Player, src)
end)

RegisterNetEvent('sna-vehiclekeys:server:GiveTempKey', function(plate)
	local src = source
    local citizenid = GetIdentifier(src)

    if not VehicleList[plate] then VehicleList[plate] = {} end
    VehicleList[plate][citizenid] = true
	ShowNotification(src, Lang:t("message.temp_key_received"), 'success')
end)

RegisterNetEvent('sna-vehiclekeys:server:ChangeLocks', function(data)
	local src = source
	local plate = data.plate
	local cashBalance = GetMoney(src)

	if cashBalance >= Config.ResetPrice then
		RemoveMoney(src, Config.ResetPrice)
		ChangeLocks(plate)
		ShowNotification(src, Lang:t("message.locks_reset"), 'success')
	else
		ShowNotification(src, Lang:t("message.not_enough_money"), 'error')
	end
end)

RegisterNetEvent('sna-vehiclekeys:server:GiveKey', function(data)
	local src = source
	local plate = data.plate
	local model = data.model
	local cashBalance = GetMoney(src)

	if cashBalance >= Config.KeyPrice then
		RemoveMoney(src, Config.KeyPrice)
		GiveKey(plate, model, GetPlayer(src), src)
	else
		ShowNotification(src, Lang:t("message.not_enough_money"), 'error')
	end
end)

RegisterNetEvent('sna-vehiclekeys:server:breakLockpick', function(itemName)
	local src = source
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
	RemoveInventory(src, itemName, 1)
end)

RegisterNetEvent('sna-vehiclekeys:server:RemoveKey', function(plate)
	local src = source
	local items = GetItemsByNameInventory(src, 'vehiclekey')
	if items then
		for _, v in pairs(items) do
			if v.info.plate == plate then
				RemoveInventory(src, 'vehiclekey', 1, v.slot)
			end
		end
	end
end)

RegisterCallback('sna-vehiclekeys:server:HasKey', function(source, cb, plate)
	local src = source
    local citizenid = GetIdentifier(source)
	local ok = false
	if VehicleList[plate] and VehicleList[plate][citizenid] then
		cb(true)				
	else
		local items = GetItemsByNameInventory(src, 'vehiclekey')
		if items then
			for _, v in pairs(items) do
				local info = GetInventoryMetadata(v)
				if info.plate == plate then
					local result = MySQL.single.await('SELECT `lock` FROM '..GetDatabase()..' WHERE '..GetDatabaseKeyPlate()..' = ?', { plate })
					if result then
						local lock = result.lock
						if info.lock == lock then
							ok = true
						end
					else
						ok = true
					end
				end
			end
		end
		cb(ok)		
	end
end)

RegisterCallback('sna-vehiclekeys:server:GetPlayerVehicles', function(source, cb)
    local Vehicles = {}

    MySQL.query('SELECT * FROM '..GetDatabase()..' WHERE '..GetDatabaseKeyOwner()..' = ?', {GetIdentifier(source)}, function(result)
        if result[1] then
            for _, v in pairs(result) do
                --local VehicleData = QBCore.Shared.Vehicles[v.vehicle]

                Vehicles[#Vehicles+1] = {
                    model = GetDatabaseVehicleModel(v),
                    plate = v.plate,
                    state = v.state,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

CreateUseableItem("lockpick", "lockpicks:UseLockpick")
