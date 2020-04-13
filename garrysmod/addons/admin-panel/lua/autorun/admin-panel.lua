if SERVER then
	include('util-libs/pon.lua')
	include('util-libs/netstream.lua')
	include('util-libs/netvars/server.lua')

	AddCSLuaFile('util-libs/pon.lua')
	AddCSLuaFile('util-libs/netstream.lua')
	AddCSLuaFile('util-libs/netvars/client.lua')

	include('admin-panel/sv_utils.lua')
	include('admin-panel/sv_adp_player.lua')
	include('admin-panel/sv_adp.lua')
	include('admin-panel/sv_adp_print.lua')

	include('admin-panel/sv_init.lua')
	include('admin-panel/sv_commands.lua')

	AddCSLuaFile('admin-panel/cl_init.lua')
elseif CLIENT then
	include('util-libs/pon.lua')
	include('util-libs/netstream.lua')
	include('util-libs/netvars/client.lua')

	include('admin-panel/cl_init.lua')
end
