--
resource.AddWorkshop("3631163197")
local client = FindMetaTable("Player")
function client:SetCustomPermission(rank)
    local ranks = sAndbox.HigherAccess[rank]
    if ranks == nil then
        print(Format("Console: Invalid Rank %s", rank))
        for k, v in pairs(sAndbox.HigherAccess) do
            print(Format("Valid Rank = %s", k))
        end
        return
    end

    self:SetNWFloat("permission", ranks)
    self:SetPData("permission", ranks)
    print(Format("Console: set %s to %s", self:Nick(), rank))
    local log = sAndbox.using("logger-info")()
    log.Logger(os.date() .. " Name: " .. self:Nick() .. " Rank: " .. rank .. " SteamID: " .. self:SteamID64() .. " IP: " .. self:IPAddress(), true)
end

function sAndbox.FindPlayer(name)
    for k, v in pairs(player.GetAll()) do
        local fnd = string.find(v:Nick(), name)
        if fnd then return v end
    end
    return NULL
end

function client:SetOwnerAccess()
    self:SetCustomPermission("Owner")
end

sAndbox.Event_Hook("PlayerInitialSpawn", "NoRankSet", function(ply)
    --
    timer.Simple(2, function()
        -- 
        if IsValid(ply) and ply:IsFullyAuthenticated() and ply:GetPData("permission", nil) == nil then --
            ply:SetCustomPermission("user")
        end
    end)
end)