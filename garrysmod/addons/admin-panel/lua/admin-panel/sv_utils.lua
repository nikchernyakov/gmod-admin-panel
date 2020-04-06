function FindPlayerByName(name)
    for k, ply in pairs(player.GetAll()) do
        if ply:GetName() == name then
            return ply
        end
    end
end