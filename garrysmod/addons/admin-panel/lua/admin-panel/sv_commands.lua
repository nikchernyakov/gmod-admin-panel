Command = {}

Command.CURRENT_PLAYERS = 'current-players'
Command.SET_ROLE = 'set-role'
Command.SET_RANG = 'set-rang'
Command.KICK = 'adp-kick'
Command.BAN = 'adp-ban'
Command.UNBAN = 'adp-unban'

function Command:New(ply, console, commandType, args)
    local newObj = {
        ply = ply,
        console = console,
        type = commandType,
        args = args
    }

    if IsValid(ply) then
        newObj.adpPly = adp.GetPlayer(ply:GetName())
    else
        newObj.ply = nil
    end

    self.__index = self
    return setmetatable(newObj, self)
end

function Command:IsServer()
    return not IsValid(self.ply)
end

function Command:IsPlayer()
    return IsValid(self.ply)
end

function Command:Execute()
    Command.executor[self.type](self)
    return 
end

function Command:Print(message, status)
    adp.Print(self.ply, self.console, message, status)
end

function Command.CheckCommand(commandType)
    for currentType, _ in pairs(Command.executor) do
        if commandType == currentType then
            return currentType
        end
    end
    return false
end

-- Executors
Command.executor = {}
Command.executor[Command.CURRENT_PLAYERS] = function (command)
    for k, ply in pairs(player.GetAll()) do
        adp.Print(command.ply, command.console, k.." "..ply:GetName())
    end
end

Command.executor[Command.SET_ROLE] = function (command)
    -- Check permissions
    if not command:IsServer() and not command.ply:IsSuper() then
        command:Print('You are not a superadmin', DENIED)
        return
    end

    -- Get args
    local name = command.args[1]
    local role = command.args[2]
    local rang = tonumber(command.args[3])
    if rang == nil then
        rang = 1
    end

    if name == nil or role == nil then
        command:Print(
            'Wrong command format\n  Correct format: set-role username super/admin/none rang[=1][for admin]',
            ERROR
        )
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        command:Print('User was not found', ERROR)
        return
    end

    if not AdpRole.IsValid(role) then
        command:Print('Incorrect role type. Use super/admin/none', ERROR)
        return
    end

    if targetPlayer.role.type == role then
        command:Print('User already has this role.', INFO)
        return
    end

    if role == ADMIN_TYPE then
        if rang < 1 or rang > 3 then
            command:Print('Rang must be in range [1;3]', ERROR)
            return
        end
    
        if targetPlayer.role.rang == rang then
            command:Print('User already has this rang.', INFO)
            return
        end

        targetPlayer.role.rang = rang
    end

    if targetPlayer.online then
        local targetPly = FindPlayerByName(name)
        if targetPly then
            adp.Print(targetPly, false, "Your role was changed to " .. role)
        else
            command:Print('Can not find online player to send him a message', ERROR)
        end
    end

    targetPlayer:SetRole(role)
    adp.SaveAdpState()
    command:Print("Set " .. role .. " role for " .. name, INFO)
end

Command.executor[Command.SET_RANG] = function (command)
    if not (command:IsServer() or command.ply:IsSuper())  then
        command:Print('You are not a superadmin', DENIED)  
        return
    end

    local name = command.args[1]
    local rang = tonumber(command.args[2])

    if name == nil or rang == nil then
        command:Print('Wrong command format\n  Correct format: set-rang username rang', ERROR)
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        command:Print('User was not found', ERROR)
        return
    end

    if targetPlayer.role.type ~= ADMIN_TYPE then
        command:Print('User is not an admin', ERROR)
        return
    end

    if rang < 1 or rang > 3 then
        command:Print('Rang must be in range [1;3]', ERROR)
        return
    end
    
    if targetPlayer.role.rang == rang then
        command:Print('User already has this rang.', INFO)
        return
    end

    if targetPlayer.online then
        local targetPly = FindPlayerByName(name)
        if targetPly then
            adp.Print(targetPly, false, "Your rang was changed to " .. rang)
        else
            command:Print('Can not find online player to send him a message', ERROR)
        end
    end

    targetPlayer.role.rang = rang
    adp.SaveAdpState()
    command:Print('User rang was changed', INFO)
end

Command.executor[Command.KICK] = function (command)
    if not (command:IsServer() or command.ply:IsSuper() or command.ply:IsAdmin()) then
        command:Print('You do not have permission for this', DENIED)  
        return
    end

    local name = command.args[1]
    local reason = command.args[2]

    if not reason then
        reason = 'You was kicked'
    end

    if name == nil then
        command:Print('Wrong command format\n  Correct format: adp-kick username reason[can be skipped]', ERROR)
        return
    end

    local targetPlayer = FindPlayerByName(name)
    if targetPlayer == nil then
        command:Print('User was not found', ERROR)
        return
    end

    if command:IsPlayer() and targetPlayer:GetRang() > command.ply:GetRang() then
        command:Print('User has rang bigger then you', DENIED)
    end

    targetPlayer:Kick(reason)
    command:Print('User was kicked', INFO)
end

Command.executor[Command.BAN] = function (command)
    if not (command:IsServer() or command.ply.ply:IsSuper() or (command.ply:IsAdmin() and command.ply:GetRang() > 1)) then
        command:Print('You do not have permission for this', DENIED)  
        return
    end

    local name = command.args[1]
    local time = tonumber(command.args[2])

    if not time then
        time = 0
    end

    if name == nil then
        command:Print('Wrong command format\n  Correct format: adp-ban username time[minutes][default=0][0 means permanently]', ERROR)
        return
    end

    local targetAdpPlayer = adp.GetPlayer(name)
    if targetAdpPlayer == nil then
        command:Print('User was not found', ERROR)
        return
    end

    if command:IsPlayer() and targetAdpPlayer.role.rang > command.ply:GetRang() then
        command:Print('User has rang bigger then you', DENIED)
    end
    
    targetAdpPlayer.ban = {}
    local reason = "You are banned "
    if time == 0 then
        targetAdpPlayer.ban.isPermanent = true
        reason = reason.."permanently"
    else
        targetAdpPlayer.ban.unbanTime = os.time() + time * 60
        reason = reason.."for "..time.." minutes"
    end
    
    if targetAdpPlayer.online then
        local targetPlayer = FindPlayerByName(name)
        targetPlayer:Kick(reason)
    end
    command:Print('User was banned', INFO)
    adp.SaveAdpState()
end

Command.executor[Command.UNBAN] = function (command)
    if not (command:IsServer() or command.ply:IsSuper() or (command.ply:IsAdmin() and command.ply:GetRang() > 1)) then
        command:Print('You do not have permission for this', DENIED)
        return
    end

    local name = args[1]
    if name == nil then
        command:Print('Wrong command format\n  Correct format: adp-unban username', ERROR)
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        command:Print('User was not found', ERROR)
        return
    end

    if not targetPlayer.ban then
        command:Print('User was not banned', INFO)
    end
    
    targetPlayer.ban = false
    command:Print('User was unbanned', INFO)
    adp.SaveAdpState()
end

-- DEBUG --

concommand.Add('all-players', function()
    for k, ply in pairs(adp.Players) do
        print(k.." "..util.TableToJSON(ply))
    end
end)

concommand.Add('get-player', function(ply, cmd, args)
    local name = args[1]
    local adpPlayer = adp.GetPlayer(name)
    print(util.TableToJSON(adpPlayer, true))
end)

concommand.Add('suicide', function(ply, cmd, args)
    ply:Kill()
end)

-- CONSOLE COMMANDS --

concommand.Add(Command.CURRENT_PLAYERS, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.CURRENT_PLAYERS)
    command:Execute()
end)

concommand.Add(Command.SET_ROLE, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.SET_ROLE, args)
    command:Execute()
end)

concommand.Add(Command.SET_RANG, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.SET_RANG, args)
    command:Execute()
end)

concommand.Add(Command.KICK, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.KICK, args)
    command:Execute()
end)

concommand.Add(Command.BAN, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.BAN, args)
    command:Execute()
end)

concommand.Add(Command.UNBAN, function(ply, cmd, args)
    local command = Command:New(ply, true, Command.UNBAN, args)
    command:Execute()
end)