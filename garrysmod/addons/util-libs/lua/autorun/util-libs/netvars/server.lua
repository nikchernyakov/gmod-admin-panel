-- This code is taken from NutScript.
-- NutScript and code license are found here:
-- https://github.com/Chessnut/NutScript

netvars = netvars or {}

local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

local stored = netvars.stored or {}
netvars.stored = stored

local globals = netvars.globals or {}
netvars.globals = globals

-- Check if there is an attempt to send a function. Can't send those.
local function checkBadType(name, object)
	local objectType = type(object)

	if (objectType == "function") then
		ErrorNoHalt("Net var '"..name.."' contains a bad object type!\n")

		return true
	end
end

function netvars.SetNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end
	if (globals[key] == value) then return end

	globals[key] = value
	netstream.Start(receiver, "gVar", key, value)
end

function playerMeta:SyncVars()
	netstream.Heavy(self, "netvars_full", stored, globals)
end

function entityMeta:SendNetVar(key, receiver)
	local index = self:EntIndex()
	netstream.Start(receiver, "nVar", index, key, stored[index] and stored[index][key])
end

function entityMeta:ClearNetVars(receiver)
	local index = self:EntIndex()
	stored[index] = nil
	netstream.Start(receiver, "nDel", index)
end

function entityMeta:SetNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end
	if (not istable(value) and value == self:GetNetVar(key)) then return end

	local index = self:EntIndex()
	stored[index] = stored[index] or {}
	stored[index][key] = value

	self:SendNetVar(key, receiver)
end

function entityMeta:GetNetVar(key, default)
	local value = stored[self:EntIndex()]

	if value and value[key] ~= nil then
		return value[key]
	end

	return default
end

function playerMeta:SetLocalVar(key, value)
	if (checkBadType(key, value)) then return end
	if (not istable(value) and value == self:GetNetVar(key)) then return end

	local index = self:EntIndex()
	stored[index] = stored[index] or {}
	stored[index][key] = value

	netstream.Start(self, "nLcl", key, value)
end

playerMeta.GetLocalVar = entityMeta.GetNetVar

function netvars.GetNetVar(key, default)
	local value = globals[key]

	if value ~= nil then
		return value
	end

	return default
end

hook.Add("EntityRemoved", "nCleanUp", function(entity)
	entity:ClearNetVars()
end)

hook.Add("PlayerFinishedLoading", "nSync", function(client)
	client:SyncVars()
end)
