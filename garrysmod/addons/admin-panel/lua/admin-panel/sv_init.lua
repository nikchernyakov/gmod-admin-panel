adp.LoadAdpState()

gameevent.Listen('player_connect')
hook.Add('player_connect', 'admin-panel', function(data)
    print(data.name.." has connected")

    -- Create AdpPlayer if it is new player
    if not adp.IsPlayerExist(data.name) then
        AdpPrint(INFO, 'Add new player')
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
    print(data.name.." has disconnected")

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
    print(util.TableToJSON(adpPly, true))
    if adpPly then
        ply:SetRole(adpPly.role)
    else
        print('Can not find player')
    end
end)

-- Check Player access
hook.Add("CheckPassword", "admin-panel", function(steamID64, _, _, _, name)
    local adpPly = adp.GetPlayer(name)
	if not adpPly:IsBanned() then
        return true
	end

    if adpPly.ban.isPermanent or adpPly.ban.unbanTime > os.time() then
	    return false, "#GameUI_ServerRejectBanned"
    else
        adpPly.ban = false
    end
end)