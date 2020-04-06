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

-- COMMANDS --

concommand.Add('current-players', function()
    for k, ply in pairs(player.GetAll()) do
        print(k.." "..ply:GetName())
    end
end)

concommand.Add('set-role', function(ply, cmd, args)
    -- Check permissions
    if IsValid(ply) and not ply:IsSuper()  then
        print(ply:GetName())
        AdpPrint(DENIED, 'You are not a superadmin')  
        return
    end

    -- Get args
    local name = args[1]
    local role = args[2]
    local rang = tonumber(args[3])
    if rang == nil then
        rang = 1
    end

    if name == nil or role == nil then
        AdpPrint(ERROR, 'Wrong command format\n  Correct format: set-role username super/admin/none rang[=1][for admin]')
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        AdpPrint(ERROR, 'User was not found')
        return
    end

    if not AdpRole.IsValid(role) then
        AdpPrint(ERROR, 'Incorrect role type. Use super/admin/none')
        return
    end

    if targetPlayer.role.type == role then
        AdpPrint(INFO, 'User already has this role.')
        return
    end

    AdpPrint(INFO, "Set " .. role .. " role for " .. name)
    targetPlayer:SetRole(role)

    if role == ADMIN_TYPE then
        targetPlayer.role.rang = rang
    end

    adp.SaveAdpState()
    AdpPrint(INFO, 'User role was changed')
end)

concommand.Add('set-rang', function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuper()  then
        AdpPrint(DENIED, 'You are not a superadmin')  
        return
    end

    local name = args[1]
    local rang = tonumber(args[2])

    if name == nil or rang == nil then
        AdpPrint(ERROR, 'Wrong command format\n  Correct format: set-rang username rang')
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        AdpPrint(ERROR, 'User was not found')
        return
    end

    if targetPlayer.role.type ~= ADMIN_TYPE then
        AdpPrint(ERROR, 'User is not an admin')
        return
    end

    if rang < 1 or rang > 3 then
        AdpPrint(ERROR, 'Rang must be in range [1;3]')
        return
    end
    
    if targetPlayer.role.rang == rang then
        AdpPrint(INFO, 'User already has this rang.')
        return
    end

    targetPlayer.role.rang = rang
    adp.SaveAdpState()
    AdpPrint(INFO, 'User rang was changed')
end)

concommand.Add('adp-kick', function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuper() and not (ply:IsAdmin() and ply:GetRang() > 1) then
        AdpPrint(DENIED, 'You do not have permission for this')  
        return
    end

    local name = args[1]
    local reason = args[2]

    if not reason then
        reason = 'You was kicked'
    end

    if name == nil then
        AdpPrint(ERROR, 'Wrong command format\n  Correct format: adp-kick username reason[can be skipped]')
        return
    end

    local targetPlayer = FindPlayerByName(name)
    if targetPlayer == nil then
        AdpPrint(ERROR, 'User was not found')
        return
    end

    if IsValid(ply) and targetPlayer:GetRang() > ply:GetRang() then
        AdpPrint(DENIED, 'User has rang bigger then you')
    end

    targetPlayer:Kick(reason)
    AdpPrint(INFO, 'User was kicked')
end)

concommand.Add('adp-ban', function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuper() and not (ply:IsAdmin() and ply:GetRang() > 2) then
        AdpPrint(DENIED, 'You do not have permission for this')  
        return
    end

    local name = args[1]
    local time = tonumber(args[2])

    if not time then
        time = 0
    end

    if name == nil then
        AdpPrint(ERROR, 'Wrong command format\n  Correct format: adp-ban username time[minutes][default=0][0 means permanently]')
        return
    end

    local targetAdpPlayer = adp.GetPlayer(name)
    if targetAdpPlayer == nil then
        AdpPrint(ERROR, 'User was not found')
        return
    end

    if IsValid(ply) and targetAdpPlayer.role.rang > ply:GetRang() then
        AdpPrint(DENIED, 'User has rang bigger then you')
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
    AdpPrint(INFO, 'User was banned')
    adp.SaveAdpState()
end)

concommand.Add('adp-unban', function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuper() and not (ply:IsAdmin() and ply:GetRang() > 2) then
        AdpPrint(DENIED, 'You do not have permission for this')  
        return
    end

    local name = args[1]
    if name == nil then
        AdpPrint(ERROR, 'Wrong command format\n  Correct format: adp-unban username')
        return
    end

    local targetPlayer = adp.GetPlayer(name)
    if targetPlayer == nil then
        AdpPrint(ERROR, 'User was not found')
        return
    end

    if not targetPlayer.ban then
        AdpPrint(INFO, 'User was not banned')
    end
    
    targetPlayer.ban = false
    AdpPrint(INFO, 'User was unbanned')
    adp.SaveAdpState()
end)