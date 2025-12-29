--
resource.AddWorkshop("3631163197")
util.AddNetworkString("sAndbox_Secure_Data")
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

local function SendSecureData(ply, name, data)
    net.Start("sAndbox_Secure_Data")
    net.WriteString(name)
    net.WriteFloat(data)
    net.Send(ply)
end

function client:SetOwnerAccess()
    self:SetCustomPermission("Owner")
end

function client:SetHunger(num)
    if not self.SurvivalStats then self.SurvivalStats = {} end
    self.SurvivalStats["Hunger"] = num
    SendSecureData(self, "Hunger", self.SurvivalStats["Hunger"])
end

function client:SetThirst(num)
    if not self.SurvivalStats then self.SurvivalStats = {} end
    self.SurvivalStats["Thirst"] = num
    SendSecureData(self, "Thirst", self.SurvivalStats["Thirst"])
end

function client:SetTemperature(num)
    if not self.SurvivalStats then self.SurvivalStats = {} end
    self.SurvivalStats["Temperature"] = num
    SendSecureData(self, "Temperature", self.SurvivalStats["Temperature"])
end

function client:SetRadiation(num)
    if not self.SurvivalStats then self.SurvivalStats = {} end
    self.SurvivalStats["Radiation"] = num
    SendSecureData(self, "Radiation", self.SurvivalStats["Radiation"])
end

function client:SetBleeding(num)
    if not self.SurvivalStats then self.SurvivalStats = {} end
    self.SurvivalStats["Bleeding"] = num
    SendSecureData(self, "Bleeding", self.SurvivalStats["Bleeding"])
end

function client:RegisterPlayer(mdl)
    self:SetModel(mdl)
end

//sAndbox.KeepInventory = CreateConVar("sbox_keep_inventory", 0, {FCVAR_ARCHIVE})
sAndbox.Event_Hook("PlayerSpawn", "NoRankSet", function(ply)
    --
    timer.Simple(2, function()
        -- 
        if IsValid(ply) and ply:IsFullyAuthenticated() and ply:GetPData("permission", nil) == nil then --
            ply:SetCustomPermission("user")
        end
    end)

    ply.SurvivalStats = {}
    ply:RegisterPlayer("models/player/breen.mdl")
    hook.Call("PlayerSpawning", nil, ply, ply.SurvivalStats)
end)