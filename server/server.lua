ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



ESX.RegisterServerCallback('cl-keys:isHaveKey', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchScalar("SELECT id FROM user_keys WHERE plate = @plate AND owner = @owner", {
        ['@plate'] = plate,
        ['@owner'] = xPlayer.identifier,
     }, function(have)

        if have ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)


ESX.RegisterServerCallback('cl-keys:getMyKeys', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local myKeys = {}

	MySQL.Async.fetchAll('SELECT * FROM user_keys WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(data)
		for _,v in pairs(data) do
			table.insert(myKeys, v.plate)
		end
		cb(myKeys)
	end)
end)

RegisterNetEvent('cl-keys:deleteKey')
AddEventHandler('cl-keys:deleteKey', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('DELETE FROM user_keys WHERE plate = @plate AND owner = @owner', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate,
    })


end)

RegisterNetEvent('cl-keys:sendKey')
AddEventHandler('cl-keys:sendKey', function(ID,plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(ID)

    MySQL.Async.execute('DELETE FROM user_keys WHERE plate = @plate AND owner = @owner', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate,
    })

	MySQL.Async.execute('INSERT INTO user_keys (owner, plate) VALUES (@owner, @plate)', {
		['@owner'] = xTarget.identifier,
		['@plate'] = plate,
	})
	
	TriggerClientEvent('notification', ID, 'You got a vehicle key from ' .. GetPlayerName(source) .. '', 1)
	TriggerClientEvent('notification', source, 'You have brought a key to ' .. GetPlayerName(ID) .. '', 1)

end)

function DeleteCharacter(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("DELETE FROM `"..itable.table.."` WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."'")
    end
end

RegisterNetEvent('cl-keys:giveKeyID')
AddEventHandler('cl-keys:giveKeyID', function(ID,plate)
	local xPlayer = ESX.GetPlayerFromId(ID)

	MySQL.Async.execute('INSERT INTO user_keys (owner, plate) VALUES (@owner, @plate)', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate,
	})
	
	TriggerClientEvent('notification', ID, 'You got a vehicle key from ' .. GetPlayerName(source) .. '', 1)
	TriggerClientEvent('notification', source, 'You have brought a key to ' .. GetPlayerName(ID) .. '', 1)  
end)

RegisterNetEvent('cl-keys:giveKey')
AddEventHandler('cl-keys:giveKey', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('INSERT INTO user_keys (owner, plate) VALUES (@owner, @plate)', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate,
	})
                
end)

ESX.RegisterServerCallback('cl-keys:getOwnedCars', function(source, cb)
	local ownedCars = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(data)
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {plate = v.plate})
		end
		cb(ownedCars)
	end)
end)