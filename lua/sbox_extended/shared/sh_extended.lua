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

function sAndbox.BuildingPrev(ply, tc, radius)
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

sAndbox.AddSounds("blip", "ui/blip.wav")
sAndbox.AddSounds("piemenu_select", "ui/piemenu/piemenu_select.wav")
sAndbox.AddSounds("piemenu_cancel", "ui/piemenu/piemenu_cancel.wav")
sAndbox.AddSounds("piemenu_open", "ui/piemenu/piemenu_open.wav")
function sAndbox.GetSounds(name)
    return sAndbox.TableSounds[name]
end

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