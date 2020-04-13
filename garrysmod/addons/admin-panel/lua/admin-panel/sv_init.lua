adp.LoadAdpState()

gameevent.Listen('player_connect')
hook.Add('player_connect', 'admin-panel', function(data)
    adp.print.ServerPrint(data.name.." has connected", INFO)

    -- Create AdpPlayer if it is new player
    if not adp.IsPlayerExist(data.name) then
        adp.print.ServerPrint('Add new player', INFO)
        adp.AddNewPlayer(data.name, data.name)
    end

    -- Set online state
    local adpPly = adp.GetPlayer(data.name)
    adpPly.online = true

    adp.SaveAdpState()

    -- Notify all
    for k, ply in pairs(player.GetAll()) do
        ply:ChatPrint(data.name .. " has connected to the server.")
    end
end)

gameevent.Listen('player_disconnect')
hook.Add('player_disconnect', 'admin-panel', function(data)
    adp.print.ServerPrint(data.name.." has disconnected", INFO)

    -- Set offline state
    local adpPly = adp.GetPlayer(data.name)
    adpPly.online = false

    adp.SaveAdpState()

    -- Notify all
    for k, ply in pairs(player.GetAll()) do
        ply:ChatPrint(data.name .. " has disconnected.")
    end
end)

hook.Add("PlayerInitialSpawn", "admin-panel", function(ply)
    local adpPly = adp.GetPlayer(ply:GetName())
    adp.print.ServerPrint(util.TableToJSON(adpPly, true), INFO)
    if adpPly then
        ply:SetRole(adpPly.role)
    else
        adp.print.ServerPrint('Can not find player', ERROR)
    end
end)

-- Check Player access
hook.Add("CheckPassword", "admin-panel", function(steamID64, _, _, _, name)
    local adpPly = adp.GetPlayer(name)
	if not (adpPly and adpPly:IsBanned()) then
        return true
	end

    if adpPly.ban.isPermanent or adpPly.ban.unbanTime > os.time() then
	    return false, "#GameUI_ServerRejectBanned"
    else
        adpPly.ban = false
    end
end)

-- Check chat commands
hook.Add("PlayerSay", "admin-panel", function(ply, text)
	local args = string.Explode(' ', text)
    local commandType = table.remove(args, 1)
    if Command.CheckCommand(commandType) then
        ply:ChatPrint(text)
        local command = Command:New(ply, false, commandType, args)
        command:Execute()
        return ''
    end
end)

netstream.Hook('client -> server', function(ply, val1, val2, val3)
    print('Client message')
end)

