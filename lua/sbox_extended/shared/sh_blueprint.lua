sAndbox.Blueprints = {}
function sAndbox.AddBluePrint(name, locked)
    sAndbox.Blueprints[name] = locked
end

if SERVER then
    util.AddNetworkString("sAndbox_BluePrint")
    util.AddNetworkString("sAndbox_BluePrint_unLock")
else
    net.Receive("sAndbox_BluePrint", function() end)
end