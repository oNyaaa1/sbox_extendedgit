if SERVER then return end
sAndbox.placeW = {
    RIGHT_SCREEN = ScrW() * 0.875,
    LEFT_SCREEN = ScrW() * 0,
}

sAndbox.placeH = {
    TOP_SCREEN = ScrH() * 0,
    BOTTOM_SCREEN = ScrH() * 0.89,
}

local oldreq = require
function require(str)
    if string.lower(str) == "bsendpacket" then if bSendPacket then print("caught") end end
    return oldreq(str)
end

local roldrc = render.Capture
function render.Capture(data)
    return roldrc(data)
end

local roldrcp = render.CapturePixels
function render.CapturePixels()
    return roldrcp()
end

sAndbox.FatFont("Arial", "sAndbox", 18, 2300)
hook.Add("OnScreenSizeChanged", "sAndboxWH", function()
    sAndbox.placeW = {
        RIGHT_SCREEN = ScrW() * 0.875,
        LEFT_SCREEN = ScrW() * 0,
    }

    sAndbox.placeH = {
        TOP_SCREEN = ScrH() * 0,
        BOTTOM_SCREEN = ScrH() * 0.89,
    }
end)

sAndbox.ScreenHud = function(itemw, itemh, x, y, w, h, col)
    x = x or 0
    y = y or 0
    col = col or Color(0, 0, 0, 200)
    draw.RoundedBox(12, itemw * x, itemh * y, w, h, col)
end

sAndbox.ScreenText = function(text, itemw, itemh, x, y, w, h, col, align)
    x = x or 0
    y = y or 0
    col = col or Color(255, 255, 255, 255)
    draw.DrawText(text, "sAndbox", itemw * x, itemh * y, col, align)
end

sAndbox.HudHide({"CHudHealth"})
local DrawHuds = nil
local showHud = CreateConVar("sAndbox_hud", 0, {FCVAR_ARCHIVE})
sAndbox.EventHud("DrawHud", function()
    return {
        {
            Name = "Hud for you Example"
        },
        {
            Description = "Hud"
        },
        {
            Author = "God"
        },
        {
            Version = 1.0
        },
        showHud:GetBool() and DrawHuds and sAndbox.ScreenHud(DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1, 1, 200, 100, Color(51, 51, 51, 226)),
        showHud:GetBool() and DrawHuds and sAndbox.ScreenText("sAndbox", DrawHuds.setplaceLS + 5, DrawHuds.setplaceBS + 2, 1, 1, 200, 100, Color(88, 176, 1)),
        showHud:GetBool() and DrawHuds and sAndbox.ScreenText("Health: " .. tostring(LocalPlayer():Health()), DrawHuds.setplaceLS + 5, DrawHuds.setplaceBS + 2, 1, 1.02, 1, 1, Color(88, 176, 1)),
        showHud:GetBool() and DrawHuds and surface.SetDrawColor(255, 255, 255, 255),
        showHud:GetBool() and DrawHuds and surface.DrawOutlinedRect(DrawHuds.setplaceLS, DrawHuds.setplaceBS, 200, 100, 3),
    }
end, {
    setplaceLS = sAndbox.placeW.LEFT_SCREEN,
    setplaceBS = sAndbox.placeH.BOTTOM_SCREEN
})

DrawHuds = sAndbox.using("DrawHud")
local Legs_CV = CreateConVar("sAndbox_legs", 1, {FCVAR_ARCHIVE})
hook.Add("CalcView", "EasyLookDown", function(ply, pos, angles, fov, znear, zfar)
    if Legs_CV:GetFloat() ~= 1 then return end
    if angles.p <= 82 then
        local view = {
            origin = pos,
            angles = angles,
            fov = fov,
            drawviewer = false
        }
        return view
    else
        local eyeBone = ply:LookupBone("ValveBiped.Bip01_Head1") -- or try "eyes" if that doesn't work
        local eyePos = pos
        if eyeBone then
            local bonePos, boneAng = ply:GetBonePosition(eyeBone)
            if bonePos then eyePos = bonePos end
        end

        local bodyAngles = ply:GetAngles()
        local view = {
            origin = eyePos + (bodyAngles:Forward() * 2) + (bodyAngles:Up() * 2),
            angles = angles,
            fov = fov,
            drawviewer = true,
        }
        return view
    end
end)