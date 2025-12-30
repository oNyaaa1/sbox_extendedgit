if SERVER then return end
local frame = nil
local inv_Slot = 1
local inventory = nil
local inventory2 = nil
sAndbox.tnkSlots = {}
sAndbox.pnl2 = sAndbox.pnl2 or {}
local function ClearSlot(slotID)
    if slotID and sAndbox.img[slotID] then
        sAndbox.img[slotID]:Remove()
        sAndbox.img[slotID] = nil
    end
end

local function DoDrop(self, panels, bDoDrop, Command, x, y)
    if bDoDrop then
        local oldSlot = self.Slot
        local newSlot = self.RealSlotID
        ClearSlot(oldSlot)
        panels[1]:SetParent(self)
        net.Start("sAndbox_Inventory_SaveSlots")
        net.WriteFloat(oldSlot)
        net.WriteFloat(newSlot)
        net.SendToServer()
    end
end

net.Receive("sAndbox_GridSize_Inventory2", function()
    local GridSize2 = net.ReadTable()
    inventory2 = GridSize2
end)

net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_Slot = net.ReadFloat()
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
            sAndbox.pnl2[i]:Receiver("Inventory_gRust", DoDrop)
            local selected = false
            sAndbox.pnl2[i].Paint = function(s, w, h)
                if s:IsHovered() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 172, 195, 100))
                    if not selected then
                        LocalPlayer():EmitSound(sAndbox.GetSounds("piemenu_select"))
                        selected = true
                    end
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 100))
                    selected = false
                end
            end

            sAndbox.pnl2[i].RealSlotID = i
            sAndbox.pnl2[i].Slot = inv_Slot
            grid2:AddCell(sAndbox.pnl2[i])
        end

        sAndbox.img = vgui.Create("DImageButton", sAndbox.pnl2[inv_Slot])
        sAndbox.img:SetImage(inventory[inv_Slot]["Mats"])
        sAndbox.img:SetSize(90, 86)
        sAndbox.img:Droppable("Inventory_gRust")
        local selected = false
        sAndbox.img.Paint = function(s, w, h)
            if s:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 172, 195, 100))
                if not selected then
                    LocalPlayer():EmitSound(sAndbox.GetSounds("piemenu_select"))
                    selected = true
                end
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 0))
                selected = false
            end
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
    for i = 7, 30 do
        sAndbox.pnl[i] = vgui.Create("DPanel")
        sAndbox.pnl[i]:SetTall(100)
        sAndbox.pnl[i]:Receiver("Inventory_gRust", DoDrop)
        sAndbox.pnl[i].RealSlotID = i
        sAndbox.pnl[i].Slot = inv_Slot
        local selected = false
        sAndbox.pnl[i].Paint = function(s, w, h)
            if s:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 172, 195, 100))
                if not selected then
                    LocalPlayer():EmitSound(sAndbox.GetSounds("piemenu_select"))
                    selected = true
                end
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(64, 64, 64, 200))
                selected = false
            end
        end

        grid:AddCell(sAndbox.pnl[i])
    end

    hook.Call("LoadInventory", nil, pnl, sAndbox.pnl, sAndbox.pnl2, frame, inventory, inventory2, inv_Slot)
    return frame
end