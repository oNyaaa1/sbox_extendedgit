if SERVER then return end
sAndbox.placeW = {
    RIGHT_SCREEN = ScrW() * 0.875,
    LEFT_SCREEN = ScrW() * 0,
}

sAndbox.placeH = {
    TOP_SCREEN = ScrH() * 0,
    BOTTOM_SCREEN = ScrH() * 0.89,
}

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
local DrawHuds = sAndbox.using("DrawHud")
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
        DrawHuds and sAndbox.ScreenHud(DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1, 1, 200, 100, Color(0, 0, 0, 200)),
        DrawHuds and sAndbox.ScreenText("sAndbox", DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1, 1, 200, 100, Color(255, 255, 255)),
        DrawHuds and sAndbox.ScreenText("Health: " .. tostring(LocalPlayer():Health()), DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1,1.02, 1, 1, Color(255, 255, 255)),
    }
    --print(DrawHuds.setplaceLS), 
end, {
    setplaceLS = sAndbox.placeW.LEFT_SCREEN,
    setplaceBS = sAndbox.placeH.BOTTOM_SCREEN
})