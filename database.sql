// For ESX
ALTER TABLE `owned_vehicles`
ADD COLUMN `lock` int DEFAULT 4321;

//For QBCore
ALTER TABLE `player_vehicles`
ADD COLUMN `lock` int DEFAULT 4321;

