Add your own font Clientside: sAndbox.FatFont(fonts, name, sizes, weights)

HudShouldDraw hook made simple: sAndbox.HudHide(tbl) sAndbox.HudHide({"CHudHealth"})

Add your own events
<code>
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
</code>
How to set your self owner access

Make sure you change God to your in game name!

Must be typed in the servers console.

lua_run sAndbox.FindPlayer("God"):SetOwnerAccess()

sAndbox.FindPlayer("God"):SetOwnerAccess()...

Console: set God to Owner</sub>

Console vars:

sAndbox_hud 0 disable - 1 enable

[code]hook.Add("PlayerSpawning", function(ply,stats) end)

--Loads after ply.SurvivalStats[/code]
