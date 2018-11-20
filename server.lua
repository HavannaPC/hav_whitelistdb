-- Script made by Havanna maintained by itsJarrett

AddEventHandler( 'playerConnecting', function(name, setReason )
	local identifier = GetPlayerIdentifiers(source)[1]
	local whitelistStatus = getWhitelisted(identifier)
	if whitelistStatus == 0 then
		setReason('You are not whitelisted on this server')
		print('(' .. identifier .. ') ' .. name .. ' has been kicked because they are not Whitelisted')
		CancelEvent()
	elseif whitelistStatus == 2 then
		setReason('You are banned!')
		print('(' .. identifier .. ') ' .. name .. ' has been kicked because they are banned!')
		CancelEvent()
	end
end)

-- Chat Command to add someone in Whitelist
TriggerEvent('es:addGroupCommand', 'wladd', 'admin', function(source, args, user)
	if #args == 2 then
		if isWhitelisted(args[2]) then
			TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, args[2] .. ' is already whitelisted!')
		else
			addWhitelist(args[2])
			TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, args[2] .. ' has been whitelisted!')
		end
	else
		TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, 'Incorrect identifier!')
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, 'Insufficienct permissions!')
end)

-- Chat Command to remove someone in Whitelist
TriggerEvent('es:addGroupCommand', 'wlremove', 'admin', function(source, args, user)
	if #args == 2 then
		if isWhitelisted(args[2]) then
			removeWhitelist(args[2])
			TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, args[2] .. ' is no longer whitelisted!')
		else
			TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, args[2] .. ' is not whitelisted from!')
		end
	else
		TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, 'Incorrect identifier!')
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, 'Insufficienct permissions!')
end)

function addWhitelist(identifier)
	MySQL.Sync.execute('INSERT INTO user_whitelist (`identifier`, `whitelisted`) VALUES (@identifier, @whitelisted)',{['@identifier'] = identifier, ['@whitelisted'] = 1})
end

function removeWhitelist(identifier)
	MySQL.Sync.execute('DELETE FROM user_whitelist WHERE identifier = @identifier', {['@identifier'] = identifier})
end

function isWhitelisted(identifier)
	local result = MySQL.Sync.fetchScalar('SELECT whitelisted FROM user_whitelist WHERE identifier = @username', {['@username'] = identifier})
	if result == 1 then
		return true
	else
		return false
	end
end

function getWhitelisted(identifier)
	local result = MySQL.Sync.fetchScalar('SELECT whitelisted FROM user_whitelist WHERE identifier = @username', {['@username'] = identifier})
	return result
end

-- Rcon command to add/remove someone in Whitelist
AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'wladd' then
		if #args ~= 1 then
			RconPrint('Usage: whitelistadd [identifier]\n')
			CancelEvent()
			return
		end
		if isWhitelisted(args[1]) then
			RconPrint(args[1] .. ' is already whitelisted!\n')
			CancelEvent()
		else
			addWhitelist(args[1])
			RconPrint(args[1] .. ' has been whitelisted!\n')
			CancelEvent()
		end
	elseif commandName == 'wlremove' then
		if #args ~= 1 then
			RconPrint('Usage: whitelistremove [identifier]\n')
			CancelEvent()
			return
		end
		if isWhitelisted(args[1]) then
			removeWhitelist(args[1])
			RconPrint(args[1] .. ' is no longer whitelisted!\n')
			CancelEvent()
		else
			RconPrint(args[1] .. ' is not whitelisted!\n')
			CancelEvent()
		end
	end
end)
