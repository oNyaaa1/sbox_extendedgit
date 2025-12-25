--
local client = FindMetaTable("Player")
function client:SetCustomPermission(rank)
    local ranks = sAndbox.HigherAccess[rank]
    self:SetNWFloat("permission", ranks)
    self:SetPData("permission", ranks)
    print(Format("Console: set %s to %s", self:Nick(), rank))
    using("logger-info")().Logger(os.date() .. " Name: " .. self:Nick() .. " Rank: " .. rank .. " SteamID: " .. self:SteamID64() .. " IP: " .. self:IPAddress(),true)
end

hook.Add("PlayerInitialSpawn", "NoRankSet", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) and ply:IsFullyAuthenticated() then
            if ply:IsSuperAdmin() then
                ply:SetCustomPermission("Owner")
            elseif ply:IsAdmin() then
                ply:SetCustomPermission("Admin")
            else
                ply:SetCustomPermission("user")
            end
        end
    end)
end)