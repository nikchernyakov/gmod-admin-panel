if SERVER then
	include('admin-panel/sv_utils.lua')
	include('admin-panel/sv_adp_player.lua')
	include('admin-panel/sv_adp.lua')
	include('admin-panel/print_utils.lua')

	include('admin-panel/sv_init.lua')
	include('admin-panel/sv_commands.lua')
	
	AddCSLuaFile('admin-panel/cl_init.lua')
	AddCSLuaFile('admin-panel/print_utils.lua')
elseif CLIENT then
	include('admin-panel/print_utils.lua')

	include('admin-panel/cl_init.lua')
end
