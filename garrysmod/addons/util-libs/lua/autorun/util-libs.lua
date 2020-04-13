if SERVER then
	include('util-libs/pon.lua')
	include('util-libs/netstream.lua')
	include('util-libs/netvars/server.lua')

	AddCSLuaFile('util-libs/pon.lua')
	AddCSLuaFile('util-libs/netstream.lua')
	AddCSLuaFile('util-libs/netvars/client.lua')
elseif CLIENT then
	include('util-libs/pon.lua')
	include('util-libs/netstream.lua')
	include('util-libs/netvars/client.lua')
end
