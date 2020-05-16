ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer 
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	
	Citizen.Wait(10)
end)


RegisterNetEvent('cl-keys:menu')
AddEventHandler('cl-keys:menu', function()
	KeysMenu()
end)


function GiveKeyToPlayer(plate)
	TriggerServerEvent('cl-keys:giveKey', plate)
end

function IsHaveKey(plate,cb)
	ESX.TriggerServerCallback('cl-keys:isHaveKey', function(have)
		cb(have)
	end, plate)
end

function KeysMenu()


	ESX.TriggerServerCallback('cl-keys:getMyKeys', function(keys)
		ESX.TriggerServerCallback('cl-keys:getOwnedCars', function(ownedCars)

		local elements = {}
		if #keys == 0 and #ownedCars == 0 then
			TriggerEvent('notification',  'You dont have any keys.', 2)
		else
			for k,v in pairs(keys) do
			table.insert(elements, {type = 'key',label = 'Key | Plate: ' .. v, value = v})
			end

			for k,v in pairs(ownedCars) do
				table.insert(elements, {type = 'owned',label = 'Owned | Plate: ' .. v.plate, value = v.plate})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keys_menu', {
				title = 'Your Keys',
				elements = elements
			}, function(data, menu)
				local playerPed = PlayerPedId()
				local action = data.current.type
				local plate = data.current.value
				local elements2 = {}
				local players      = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

				for i=1, #players, 1 do
					if players[i] ~= PlayerId() then

						table.insert(elements2, {
							label = GetPlayerName(players[i]),
							player = players[i]
						})
					end
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keys_menu2', {
					title = 'Nearby Players',
					elements = elements2
				}, function(data2, menu2)
					local player =	GetPlayerServerId(data2.current.player)
					if player ~= 'none' then
					if action == 'key' then
						menu2.close()
						menu.close()
						TriggerServerEvent('cl-keys:sendKey', player, plate)
						Wait(50)
						KeysMenu()
					elseif action == 'owned' then
						menu2.close()
						menu.close()
						TriggerServerEvent('cl-keys:giveKeyID', player, plate)
						Wait(50)
						KeysMenu()
					end
				end
				end, function(data2, menu2)
					menu2.close()
				end)


			end, function(data, menu)
				menu.close()
			end)

		end

		end)
	end)
end

CreateThread(function()
	while true do
		Wait(1)
		local ped = PlayerPedId()
		if GetVehiclePedIsTryingToEnter(ped) ~= 0 then
			local veh = GetVehiclePedIsTryingToEnter(ped)
			local ent = GetPedInVehicleSeat(veh, -1)
			if not IsVehicleSeatFree(veh, -1) and not IsPedAPlayer(ent) and not IsEntityDead(ent) and not IsPedDeadOrDying(ent, 1) then
				SetVehicleDoorsLocked(veh, 2)
			end
			if IsEntityDead(ent) or IsPedDeadOrDying(ent, 1) then
				SetVehicleDoorsLocked(veh, 1)
			end
		end
	end
end)


