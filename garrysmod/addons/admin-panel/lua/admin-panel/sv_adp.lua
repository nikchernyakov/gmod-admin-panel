adp = {}

function adp.GetPlayer(id)
    return adp.Players[id]
end

function adp.AddNewPlayer(id, name)
    if adp.Players[id] then
        AdpPrint(ERROR, "This player is already presented in DB")
        return
    end

    adp.Players[id] = AdpPlayer:New(name)
end

function adp.IsPlayerExist(id)
    return adp.Players[id]
end

-- Save and Load players data in file

function adp.SaveAdpState()
    file.Write('data.json', util.TableToJSON(adp.Players, true))
end

function adp.LoadAdpState()
    adp.Players = {}

    local fileContent = file.Read('data.json')
    local dataTable = util.JSONToTable(fileContent)
    if dataTable == nil then
        print("Load nil")
        return
    end

    for k, ply in pairs(dataTable) do
        local adpPly = AdpPlayer:Clone(ply)
        adpPly.online = false
        adp.Players[k] = adpPly
    end
end