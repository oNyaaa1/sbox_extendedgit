if SERVER then return end
local frame = nil
local inv_size = 1
net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_size = GridSize[2]
end)

function sAndbox.InventoryMain()
    sAndbox.pnl = {}
    sAndbox.pnl2 = {}
    if IsValid(frame) then frame:Remove() end
    local x, y = ScrW(), ScrH()
    frame = vgui.Create("DFrame")
    frame:SetSize(x, y)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    local pnl = vgui.Create("DPanel", frame)
    pnl:SetPos(x * 0.3, y * 0.3)
    pnl:SetSize(602, 380)
    pnl.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    local grid = vgui.Create("ThreeGrid", pnl)
    grid:Dock(FILL)
    grid:DockMargin(4, 4, 4, 4)
    grid:InvalidateParent(true)
    grid:SetColumns(6)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    for i = 1, inv_size do
        sAndbox.pnl[i] = vgui.Create("DPanel")
        sAndbox.pnl[i]:SetTall(60)
        sAndbox.pnl[i].Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200)) end
        grid:AddCell(sAndbox.pnl[i])
    end

    local pnl2 = vgui.Create("DPanel", frame)
    pnl2:SetPos(x * 0.3, y * 0.88)
    pnl2:SetSize(602, 100)
    pnl2.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    local grid2 = vgui.Create("ThreeGrid", pnl2)
    grid2:Dock(FILL)
    grid2:DockMargin(4, 4, 4, 4)
    grid2:InvalidateParent(true)
    grid2:SetColumns(6)
    grid2:SetHorizontalMargin(2)
    grid2:SetVerticalMargin(2)
    for i = 1, 6 do
        sAndbox.pnl2[i] = vgui.Create("DPanel")
        sAndbox.pnl2[i]:SetTall(60)
        sAndbox.pnl2[i].Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200)) end
        grid2:AddCell(sAndbox.pnl2[i])
    end

    hook.Call("LoadInventory", nil, pnl, sAndbox.pnl, sAndbox.pnl2)
    return frame
end