***
Add your own font Clientside: sAndbox.FatFont(fonts, name, sizes, weights) 

HudShouldDraw hook made simple: sAndbox.HudHide(tbl) sAndbox.HudHide({"CHudHealth"})

Add your own events

local DrawHuds = sAndbox.using("DrawHud")

sAndbox.EventHud("DrawHud", function()

&nbsp;   return {

&nbsp;       {

&nbsp;           Name = "Hud for you Example"

&nbsp;       },

&nbsp;       {

&nbsp;           Description = "Hud"

&nbsp;       },

&nbsp;       {

&nbsp;           Author = "God"

&nbsp;       },

&nbsp;       {

&nbsp;           Version = 1.0

&nbsp;       },

&nbsp;       DrawHuds and sAndbox.ScreenHud(DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1, 1, 200, 100, Color(0, 0, 0, 200)),

&nbsp;       DrawHuds and sAndbox.ScreenText("sAndbox", DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1, 1, 200, 100, Color(255, 255, 255)),

&nbsp;       DrawHuds and sAndbox.ScreenText("Health: " .. tostring(LocalPlayer():Health()), DrawHuds.setplaceLS, DrawHuds.setplaceBS, 1,1.02, 1, 1, Color(255, 255, 255)),

&nbsp;   }

&nbsp;   --print(DrawHuds.setplaceLS), 

end, {

&nbsp;   setplaceLS = sAndbox.placeW.LEFT\_SCREEN,

&nbsp;   setplaceBS = sAndbox.placeH.BOTTOM\_SCREEN

})

***
\[code]

How to set your self owner access

Make sure you change God to your in game name!

Must be typed in the servers console.

lua\_run sAndbox.FindPlayer("God"):SetOwnerAccess()

> sAndbox.FindPlayer("God"):SetOwnerAccess()...

Console: set God to Owner\[/code]



\[code]Console vars:

sAndbox\_hud 0 disable - 1 enable

\[/code]



\[code]hook.Add("PlayerSpawning", function(ply,stats) end) 

--Loads after ply.SurvivalStats\[/code]

