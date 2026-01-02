if SERVER then return end
local frame = nil
local inv_Slot = 1
local inventory = inventory or nil
sAndbox.tnkSlots = {}
sAndbox.img = {}
sAndbox.pnl = {}
local function ClearSlot(inv, slotID)
    if sAndbox.img and IsValid(sAndbox.img[slotID]) then sAndbox.img[slotID]:Remove() end
end

local function DropItem(inv, wep, mats)
    if wep == nil and mats == nil then return end
    net.Start("sAndbox_Inventory_Drop")
    net.WriteString(wep)
    net.WriteString(mats)
    net.SendToServer()
end

local function DoDrop(self, panels, bDoDrop, Command, x, y)
    if bDoDrop and self:GetParent():GetClassName() == "CGModBase" then --
        DropItem(inventory, inventory["Weapon"], inventory["Mats"])
        panels[1]:Remove()
    end

    if bDoDrop and inventory ~= nil and self:GetParent():GetClassName() ~= "CGModBase" then
        local oldSlot = self.Slot
        local newSlot = self.RealSlotID
        if newSlot >= 6 and newSlot <= 36 then
            --sAndbox.pnl[oldSlot].Slot = newSlot
            sAndbox.pnl[oldSlot].Weps = nil
        end

        if newSlot >= 1 and newSlot <= 6 then
            --sAndbox.pnl[oldSlot].Slot = newSlot
            sAndbox.pnl[newSlot].Weps = inventory["Weapon"]
        end

        panels[1]:SetParent(self)
        ClearSlot(inventory, oldSlot)
        net.Start("sAndbox_Inventory_SaveSlots")
        net.WriteFloat(oldSlot)
        net.WriteFloat(newSlot)
        net.WriteString(inventory and inventory["Weapon"] or "")
        net.WriteString(inventory and inventory["Mats"] or "")
        net.SendToServer()
    end
end

net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_Slot = net.ReadFloat()
    local token = net.ReadBool()
    inventory = GridSize
    if sAndbox.pnl[inv_Slot] and token then
        sAndbox.img = vgui.Create("DImageButton", sAndbox.pnl[inv_Slot])
        sAndbox.img:SetImage(inventory["Mats"])
        sAndbox.img:SetSize(90, 86)
        sAndbox.img:Droppable("Inventory_gRust")
        sAndbox.img.LastSlot = inv_Slot
    end

    if not BlehsAndbox then
        sAndbox.pnl = {}
        local x, y = ScrW(), ScrH()
        local frame2 = vgui.Create("DFrame")
        if not IsValid(frame2) then return end
        frame2:Dock(BOTTOM)
        frame2:SetSize(0, 200)
        frame2:SetTitle("")
        frame2:Receiver("Inventory_gRust", DoDrop)
        if IsValid(frame2.btnClose) then frame2.btnClose:Hide() end
        if IsValid(frame2.btnMaxim) then frame2.btnMaxim:Hide() end
        if IsValid(frame2.btnMinim) then frame2.btnMinim:Hide() end
        if IsValid(frame2) then frame2:SetSizable(false) end
        if IsValid(frame2) then frame2:SetDraggable(false) end
        frame2.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
        sAndbox.pnl3 = vgui.Create("DPanel", frame2)
        sAndbox.pnl3:SetPos(x * 0.3, y * 0.1)
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
            sAndbox.pnl[i] = vgui.Create("DPanel")
            sAndbox.pnl[i]:SetTall(100)
            sAndbox.pnl[i]:Receiver("Inventory_gRust", DoDrop)
            local selected = false
            sAndbox.pnl[i].Paint = function(s, w, h)
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

            sAndbox.pnl[i].RealSlotID = i
            sAndbox.pnl[i].Slot = inv_Slot
            grid2:AddCell(sAndbox.pnl[i])
        end

        if inventory and not howMany then
            sAndbox.img = vgui.Create("DImageButton", sAndbox.pnl[inv_Slot])
            sAndbox.img:SetImage(inventory["Mats"])
            sAndbox.img:SetSize(90, 86)
            sAndbox.img:Droppable("Inventory_gRust")
            sAndbox.img.LastSlot = inv_Slot
            howMany = true
        end

        BlehsAndbox = true
    end

    if sAndbox.pnl and sAndbox.pnl[inv_Slot] then sAndbox.pnl[inv_Slot].Weps = inventory["Weapon"] end
end)

function sAndbox.InventoryMain()
    if IsValid(frame) then frame:Remove() end
    local x, y = ScrW(), ScrH()
    frame = vgui.Create("DFrame")
    if not IsValid(frame) then return end
    frame:SetSize(x, y - 10)
    frame:Dock(FILL)
    frame:DockMargin(0, 0, 0, 0)
    frame:SetTitle("")
    frame:MakePopup()
    frame:Receiver("Inventory_gRust", DoDrop)
    frame.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    sAndbox.pnlz = vgui.Create("DPanel", frame)
    sAndbox.pnlz:SetPos(x * 0.3, y * 0.3)
    sAndbox.pnlz:SetSize(602, 420)
    sAndbox.pnlz.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 0)) end
    local grid = vgui.Create("ThreeGrid", sAndbox.pnlz)
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

    if inventory and sAndbox.pnl and sAndbox.img.LastSlot ~= inv_Slot and inventory["Mats"] ~= nil then
        sAndbox.img = vgui.Create("DImageButton", sAndbox.pnl[inv_Slot])
        sAndbox.img:SetImage(inventory["Mats"])
        sAndbox.img:SetSize(90, 86)
        sAndbox.img:Droppable("Inventory_gRust")
        sAndbox.img.LastSlot = inv_Slot
    end

    hook.Call("LoadInventory", nil, pnl, sAndbox.pnl, frame, inventory, inv_Slot)
    return frame
end

hook.Add("PlayerBindPress", "abcdeficounttothree", function(ply, bind, pressed)
    local str_Find = string.find(bind, "slot")
    local binds = string.gsub(bind, "slot", "")
    local tonum = tonumber(binds)
    if str_Find and sAndbox.pnl[tonum] ~= nil and sAndbox.pnl[tonum].Weps ~= nil then
        net.Start("sAndbox_Inventory_SelectWeapon")
        net.WriteString(sAndbox.pnl[tonum].Weps)
        net.SendToServer()
    end
end)