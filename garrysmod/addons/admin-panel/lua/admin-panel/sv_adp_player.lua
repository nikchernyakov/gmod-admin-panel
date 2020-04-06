-- Extend Player --

local Player = FindMetaTable("Player")

function Player:SetRole(role)
    self.role = role
end

function Player:GetRang()
    return self.role.rang
end

function Player:IsSuper()
    return self.role.type == SUPER_TYPE
end

function Player:IsAdmin()
    return self.role.type == ADMIN_TYPE
end

-- Classes declaration -- 

-- ADP Player --

AdpPlayer = {}

function AdpPlayer:New(name)
    local newObj = {
        name = name,
        role = NONE_ROLE,
        online = false,
        ban = false
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function AdpPlayer:Clone(adpPlayer)
    local newObj = adpPlayer
    self.__index = self
    return setmetatable(newObj, self)
end

function AdpPlayer:IsSuper()
    return self.role.type == SUPER_TYPE
end

function AdpPlayer:IsAdmin()
    return self.role.type == ADMIN_TYPE
end

function AdpPlayer:IsOnline()
    return self.online == true
end

function AdpPlayer:SetRole(roleType)
    self.role = Roles[roleType]
end

function AdpPlayer:IsBanned()
    return self.ban
end

-- ADP Role --

AdpRole = {

}

function AdpRole.IsValid(roleType)
    return Roles[roleType] ~= nil
end

function AdpRole:New(roleType, rang)
    local newObj = {
        type = roleType,
        rang = rang,
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function AdpRole:Clone(role)
    local newObj = role
    self.__index = self
    return setmetatable(newObj, self)
end

-- Roles --

NONE_TYPE = 'none'
ADMIN_TYPE = 'admin'
SUPER_TYPE = 'super'

NONE_ROLE = AdpRole:New(NONE_TYPE, 0)
ADMIN_ROLE = AdpRole:New(ADMIN_TYPE, 1)
SUPER_ROLE = AdpRole:New(SUPER_TYPE, 10)

Roles = {
    none = NONE_ROLE,
    admin = ADMIN_ROLE,
    super = SUPER_ROLE
}