if SERVER then return end
local frame = nil
local inv_size = 24
local inventory = nil
sAndbox.tnkSlots = {}
sAndbox.pnl2 = sAndbox.pnl2 or {}
net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_size = net.ReadFloat()
    inventory = GridSize
    if not BlehsAndbox then
        local x, y = ScrW(), ScrH()
        sAndbox.pnl3 = vgui.Create("DPanel")
        sAndbox.pnl3:SetPos(x * 0.3, y * 0.88)
        sAndbox.pnl3:SetSize(602, 110)
        sAndbox.pnl3.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
        local grid2 = vgui.Create("ThreeGrid", sAndbox.pnl3)
        grid2:Dock(FILL)
        grid2:DockMargin(4, 4, 4, 4)
        grid2:InvalidateParent(true)
        grid2:SetColumns(6)
        grid2:SetHorizontalMargin(2)
        grid2:SetVerticalMargin(2)
        for i = 1, 6 do
            sAndbox.pnl2[i] = vgui.Create("DPanel")
            sAndbox.pnl2[i]:SetTall(100)
            sAndbox.pnl2[i].Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200)) end
            grid2:AddCell(sAndbox.pnl2[i])
        end

        for k, v in pairs(inventory) do
            if v.Mats == nil then continue end
            local img = vgui.Create("DImageButton", sAndbox.pnl2[v.Slot])
            img:SetImage(v.Mats)
            img:SetSize(90, 86)
        end

        BlehsAndbox = true
    end
end)

function sAndbox.InventoryMain()
    sAndbox.pnl = {}
    if IsValid(frame) then frame:Remove() end
    local x, y = ScrW(), ScrH()
    frame = vgui.Create("DFrame")
    if not IsValid(frame) then return end
    frame:SetSize(x, y - 150)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 50)) end
    local pnl = vgui.Create("DPanel", frame)
    pnl:SetPos(x * 0.3, y * 0.3)
    pnl:SetSize(602, 420)
    pnl.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    local grid = vgui.Create("ThreeGrid", pnl)
    grid:Dock(FILL)
    grid:DockMargin(4, 4, 4, 4)
    grid:InvalidateParent(true)
    grid:SetColumns(6)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    for i = 1, inv_size or 24 do
        sAndbox.pnl[i] = vgui.Create("DPanel")
        sAndbox.pnl[i]:SetTall(100)
        sAndbox.pnl[i].Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200)) end
        grid:AddCell(sAndbox.pnl[i])
    end

    hook.Call("LoadInventory", nil, pnl, sAndbox.pnl, sAndbox.pnl2, frame, inventory)
    return frame
end