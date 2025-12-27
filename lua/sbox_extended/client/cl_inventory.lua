if SERVER then return end
local frame = nil
local inv_size = 10
net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_size = GridSize[2]
end)

function sAndbox.InventoryMain()
    if IsValid(frame) then frame:Remove() end
    local x, y = ScrW(), ScrH()
    frame = vgui.Create("DFrame")
    frame:SetSize(x, y)
    frame:Center()
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
        local pnl = vgui.Create("DPanel")
        pnl:SetTall(60)
        pnl.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200)) end
        grid:AddCell(pnl)
    end
    return frame
end