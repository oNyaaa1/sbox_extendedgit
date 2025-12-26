sAndbox.Blueprints = {}
function sAndbox.AddBluePrint(name, locked)
    sAndbox.Blueprints[name] = locked
end

if SERVER then
    util.AddNetworkString("sAndbox_BluePrint")
    util.AddNetworkString("sAndbox_BluePrint_unLock")
    sAndbox.KeepBluePrint = false
    hook.Add("PlayerInitialSpawn", "GetBluePrint", function(ply)
        if sAndbox.KeepBluePrint == false then
            ply.GetBluePrint = {}
        else
            ply.GetBluePrint = ply.GetBluePrint or {}
        end
    end)

    local meta = FindMetaTable("Player")
    function meta:HasBluePrint(name)
        for k, v in pairs(self.GetBluePrint) do
            if v == name then return true end
        end
        return false
    end

    function BluePrintUnlock(len, ply)
        local bp = net.ReadString()
        if ply:HasBluePrint(bp) then return end
        ply.GetBluePrint[bp] = true
        net.Start("sAndbox.Blueprints")
        net.WriteString(bp)
        net.Send(ply)
    end

    net.Receive("sAndbox_BluePrint_unLock", BluePrintUnlock)
else
    net.Receive("sAndbox_BluePrint", function()
        local bp = net.ReadString()
        sAndbox.Blueprints[bp] = false
    end)
end