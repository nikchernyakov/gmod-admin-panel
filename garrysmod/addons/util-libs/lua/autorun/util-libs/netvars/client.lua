if (netvars) then return end

netvars = netvars or {}

local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

local stored = {}
local globals = {}

netstream.Hook("nVar", function(index, key, value)
	stored[index] = stored[index] or {}
	stored[index][key] = value
end)

netstream.Hook("nDel", function(index)
	stored[index] = nil
end)

netstream.Hook("nLcl", function(key, value)
	stored[LocalPlayer():EntIndex()] = stored[LocalPlayer():EntIndex()] or {}
	stored[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("gVar", function(key, value)
	globals[key] = value
end)

netstream.Hook("netvars_full", function(_stored, _globals)

	for index, data in pairs(_stored) do
		for key, value in pairs(data) do
			stored[index] = stored[index] or {}
			stored[index][key] = value
		end
	end

	for key, value in pairs(_globals) do
		globals[key] = value
	end

end)

function netvars.GetNetVar(key, default)
	local value = globals[key]

	if value ~= nil then
		return value
	end
	
	return default
end

function entityMeta:GetNetVar(key, default)
	local index = self:EntIndex()
	local value = stored[index]

	if value and value[key] ~= nil then
		return value[key]
	end

	return default
end

function entityMeta:SetNetVar(key, default)
	-- wut? some addons use it for some reason
end

playerMeta.GetNetVar = entityMeta.GetNetVar
playerMeta.GetLocalVar = entityMeta.GetNetVar
