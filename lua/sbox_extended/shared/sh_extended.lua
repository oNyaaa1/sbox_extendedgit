sAndbox.Config = {}
sAndbox.Log = {}
sAndbox.IsServer = SERVER
sAndbox.AddonLogger = {}
local client = FindMetaTable("Player")
sAndbox.HigherAccess = {
    ["Owner"] = 5,
    ["Superadmin"] = 4,
    ["Admin"] = 3,
    ["VIP"] = 2,
    ["user"] = 1,
}

function client:HasCustomPermission(rank)
    if not IsValid(self) then return false end
    local permissions = self:GetNWFloat("permission", 1)
    if permissions >= sAndbox.HigherAccess[rank] then return true end
    return permissions == sAndbox.HigherAccess[rank]
end

function sAndbox.Log.Warning(msg)
    ErrorNoHalt(msg)
end

function sAndbox.Log.Error(msg)
    Error(msg)
end

function sAndbox.Log.Print(msg)
    print(msg)
end

sAndbox.Hooks = {}
function HookExists(hooks_str)
    return sAndbox.Hooks[hooks_str]
end

function sAndbox.Event(hooks_str, hooks_func)
    if HookExists(hooks_str) then return end
    hook.Add("InitPostEntity", tostring(hooks_str), hooks_func)
    sAndbox.AddonLogger[hooks_str] = hooks_func
    sAndbox.Log.Print("Loaded: " .. hooks_str)
end

function sAndbox.Event_Hook(hax, hooks_str, hooks_func)
    if HookExists(hooks_str) then return end
    hook.Add(hax, tostring(hooks_str), hooks_func)
    sAndbox.AddonLogger[hooks_str] = hooks_func
    sAndbox.Log.Print("Loaded: " .. hooks_str)
end

function sAndbox.Timer(funcs)
    timer.Simple(3, funcs)
end

function sAndbox.using(id)
    return sAndbox.AddonLogger[id]
end

function sAndbox.EventHud(hooks_str, hooks_func, ex)
    if SERVER then return end
    --if HookExists(hooks_str) then return end
    hook.Add("HUDPaint", tostring(hooks_str), hooks_func)
    sAndbox.AddonLogger[hooks_str] = ex
    sAndbox.Log.Print("Loaded: " .. hooks_str)
end

function sAndbox.HudHide(tbl)
    local newtbl = {}
    for k, v in pairs(tbl) do
        newtbl[v] = true
    end

    hook.Add("HUDShouldDraw", "HideHUD", function(name) if newtbl[name] then return false end end)
end

function sAndbox.BuildingPrev(ply, tc)
    if not IsValid(ply) or not IsValid(tc) then return false end
    local TC_RADIUS = 30 -- meters
    local TC_RADIUS_SQR = TC_RADIUS * TC_RADIUS -- 900
    if tc:GetPos():Distance2DSqr(ply:GetPos()) <= TC_RADIUS_SQR and tc.Owner == ply then return true end
    return false
end

function sAndbox.FatFont(fonts, name, sizes, weights)
    surface.CreateFont(name, {
        font = fonts,
        extended = false,
        size = sizes,
        weight = weights,
        underline = true,
    })
end

sAndbox.TableSounds = {}
function sAndbox.AddSounds(name, sound2)
    sAndbox.TableSounds[name] = sound2
end

function sAndbox.GetSounds(name)
    return sAndbox.TableSounds[name]
end

sAndbox.AddSounds("blip", "ui/blip.wav")
sAndbox.AddSounds("piemenu_select", "ui/piemenu/piemenu_select.wav")
sAndbox.AddSounds("piemenu_cancel", "ui/piemenu/piemenu_cancel.wav")
sAndbox.AddSounds("piemenu_open", "ui/piemenu/piemenu_open.wav")
sAndbox.AddSounds("ore_flare_hit", "farming/flare_hit.wav")
sAndbox.AddSounds("hit_head", "combat/headshot.wav")
sAndbox.AddSounds("tree_hit_1", "farming/tree_x_hit1.wav")
sAndbox.AddSounds("tree_hit_2", "farming/tree_x_hit2.wav")
sAndbox.AddSounds("tree_hit_3", "farming/tree_x_hit3.wav")
sAndbox.AddSounds("tree_hit_4", "farming/tree_x_hit4.wav")
sAndbox.Event("logger-info", function()
    return {
        {
            Name = "Logger"
        },
        {
            Description = "Logging utility"
        },
        {
            Author = "God"
        },
        {
            Version = 1.0
        },
        Logger = function(msg, log)
            log = log or false
            if not file.Exists("sAndbox_logs.txt", "DATA") then file.Write("sAndbox_logs.txt", "") end
            local fr = file.Read("sAndbox_logs.txt") .. msg .. ";\n"
            file.Write("sAndbox_logs.txt", fr)
            if log then print(Format("Writing %s to sAndbox_logs.txt", msg)) end
            return msg
        end
    }
end)

local tblData = {}
net.Receive("sAndbox_Secure_Data", function()
    local str = net.ReadString()
    local data = net.ReadFloat()
    tblData[str] = data
end)

function client:GetHunger()
    return tblData and tblData["Hunger"] or 0
end

function client:GetThirst()
    return tblData and tblData["Thirst"] or 0
end

function client:GetTempature()
    return tblData and tblData["Temperature"] or 0
end

function client:GetRadiation()
    return tblData and tblData["Radiation"] or 0
end

function client:GetBleeding()
    return tblData and tblData["Bleeding"] or 0
end

local function ENUM_LOOK_AT(side)
    if side >= 225 and side <= 315 then
        -- SW - W - NW
        return 1
    elseif side >= 315 and side <= 45 then
        -- NW - NE
        return 2
    elseif side >= 60 and side <= 120 then
        --NE - SE
        return 3
    elseif side >= 135 and side <= 225 then
        -- SE - SW
        return 4
    end
    return 2
end

local positions = {
    ["sent_foundation"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 125, 0) end
        if num == 2 then return Vector(125, 0, 0) end
        if num == 3 then return Vector(0, -125, 0) end
        if num == 4 then return Vector(-125, 0, 0) end
    end,
    ["sent_wall"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 62, 0), 0 end
        if num == 2 then return Vector(62, 0, 0), 90 end
        if num == 3 then return Vector(0, -62, 0), 0 end
        if num == 4 then return Vector(-62, 0, 0), 90 end
    end,
    ["sent_way_door"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 62, 0), 0 end
        if num == 2 then return Vector(62, 0, 0), 90 end
        if num == 3 then return Vector(0, -62, 0), 0 end
        if num == 4 then return Vector(-62, 0, 0), 90 end
    end,
    ["sent_ceiling"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 0, 125), 0 end
        if num == 2 then return Vector(0, 0, 125), 0 end
        if num == 3 then return Vector(0, 0, 125), 0 end
        if num == 4 then return Vector(0, 0, 125), 0 end
    end,
    ["sent_door"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(-25, 62, 8), 0 end
        if num == 2 then return Vector(62, -25, 8), 90 end
        if num == 3 then return Vector(-25, -62, 8), 0 end
        if num == 4 then return Vector(-62, -25, 8), 90 end
    end,
    ["sent_door_metal"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(-25, 62, 8), 0 end
        if num == 2 then return Vector(62, -25, 8), 90 end
        if num == 3 then return Vector(-25, -62, 8), 0 end
        if num == 4 then return Vector(-62, -25, 8), 90 end
    end,
    ["sent_door_metal_armoured"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(-25, 62, 8), 0 end
        if num == 2 then return Vector(62, -25, 8), 90 end
        if num == 3 then return Vector(-25, -62, 8), 0 end
        if num == 4 then return Vector(-62, -25, 8), 90 end
    end,
    ["sent_way_door_spanner"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(-0, 62, 8), 0 end
        if num == 2 then return Vector(62, -0, 8), 90 end
        if num == 3 then return Vector(-0, -62, 8), 0 end
        if num == 4 then return Vector(-62, -0, 8), 90 end
    end,
    ["sent_door_dd_metal"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 62, 8), 0 end
        if num == 2 then return Vector(62, 0, 8), 90 end
        if num == 3 then return Vector(0, -62, 8), 0 end
        if num == 4 then return Vector(-62, 0, 8), 90 end
    end,
    ["sent_door_dd_wood"] = function(ply)
        local text = math.Round(360 - ((ply:GetAngles().y - 360) % 360))
        local num = ENUM_LOOK_AT(text)
        if num == 1 then return Vector(0, 62, 8), 0 end
        if num == 2 then return Vector(62, 0, 8), 90 end
        if num == 3 then return Vector(0, -62, 8), 0 end
        if num == 4 then return Vector(-62, 0, 8), 90 end
    end
}

local ENTITY = FindMetaTable("Entity")
function ENTITY:FindSocketAdvanced(ply, need)
    print(ply,need)
    local pos, ang = positions[need](ply)
    return pos, ang
end