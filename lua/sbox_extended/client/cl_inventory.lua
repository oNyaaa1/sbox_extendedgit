if SERVER then return end
local frame = nil
local inv_Slot = 1
local inventory = nil
sAndbox.tnkSlots = {}
sAndbox.img = {}
sAndbox.pnl = {}
local BlehsAndbox = false
local howMany = false
local function ClearSlot(inv, slotID)
    if sAndbox.img[slotID] and IsValid(sAndbox.img[slotID]) then
        sAndbox.img[slotID]:Remove()
        sAndbox.img[slotID] = nil
    end
end

local function DropItem(inv, wep, mats)
    if wep == nil or mats == nil then return end
    net.Start("sAndbox_Inventory_Drop")
    net.WriteString(wep)
    net.WriteString(mats)
    net.SendToServer()
end

local function DoDrop(self, panels, bDoDrop, Command, x, y)
    if not bDoDrop or not panels[1] then return end
    -- Dropping outside inventory (to ground)
    if self:GetParent():GetClassName() == "CGModBase" then
        if panels[1].InventoryData then
            DropItem(nil, panels[1].InventoryData.Weapon, panels[1].InventoryData.Mats)
            panels[1]:Remove()
        end
        return
    end

    -- Moving items between slots
    if self:GetParent():GetClassName() ~= "CGModBase" and panels[1].CurrentSlot then
        local oldSlot = panels[1].CurrentSlot
        local newSlot = self.RealSlotID
        if not oldSlot or not newSlot or oldSlot == newSlot then return end
        local itemData = panels[1].InventoryData
        if not itemData then return end
        -- Check if new slot has an item (for swapping)
        local swapImage = sAndbox.img[newSlot]
        local hasSwapItem = IsValid(swapImage) and swapImage.InventoryData
        -- Update weapon references
        if oldSlot >= 1 and oldSlot <= 6 and IsValid(sAndbox.pnl[oldSlot]) then
            if hasSwapItem then
                sAndbox.pnl[oldSlot].Weps = swapImage.InventoryData.Weapon
            else
                sAndbox.pnl[oldSlot].Weps = nil
            end
        end

        if newSlot >= 1 and newSlot <= 6 and IsValid(sAndbox.pnl[newSlot]) then sAndbox.pnl[newSlot].Weps = itemData.Weapon end
        -- Move the dragged item to new parent
        panels[1]:SetParent(self)
        panels[1].CurrentSlot = newSlot
        -- Handle swap if there's an item in the target slot
        if hasSwapItem then
            -- Move swapped item to old slot
            swapImage:SetParent(sAndbox.pnl[oldSlot])
            swapImage.CurrentSlot = oldSlot
            sAndbox.img[oldSlot] = swapImage
        else
            -- Clear old slot reference if no swap
            sAndbox.img[oldSlot] = nil
        end

        -- Update new slot reference
        sAndbox.img[newSlot] = panels[1]
        -- Send to server
        net.Start("sAndbox_Inventory_SaveSlots")
        net.WriteFloat(oldSlot)
        net.WriteFloat(newSlot)
        net.WriteString(itemData.Weapon or "")
        net.WriteString(itemData.Mats or "")
        net.SendToServer()
    end
end

net.Receive("sAndbox_GridSize_Inventory", function()
    local GridSize = net.ReadTable()
    inv_Slot = net.ReadFloat()
    local token = net.ReadBool()
    inventory = GridSize
    -- Update existing slot or create new item
    if sAndbox.pnl[inv_Slot] and IsValid(sAndbox.pnl[inv_Slot]) and token and inventory["Mats"] then
        -- Clear old image if exists
        if IsValid(sAndbox.img[inv_Slot]) then sAndbox.img[inv_Slot]:Remove() end
        -- Create new image
        sAndbox.img[inv_Slot] = vgui.Create("DImageButton", sAndbox.pnl[inv_Slot])
        sAndbox.img[inv_Slot]:SetImage(inventory["Mats"])
        sAndbox.img[inv_Slot]:SetSize(90, 86)
        sAndbox.img[inv_Slot]:Droppable("Inventory_gRust")
        sAndbox.img[inv_Slot].CurrentSlot = inv_Slot
        sAndbox.img[inv_Slot].InventoryData = {
            Weapon = inventory["Weapon"],
            Mats = inventory["Mats"]
        }
    elseif not token then
        -- Remove item if token is false
        ClearSlot(inventory, inv_Slot)
    end

    -- Create hotbar (slots 1-6) if it doesn't exist
    if not BlehsAndbox then
        sAndbox.pnl = {}
        local x, y = ScrW(), ScrH()
        local frame2 = vgui.Create("DFrame")
        if not IsValid(frame2) then return end
        frame2:Dock(BOTTOM)
        frame2:SetSize(0, 200)
        frame2:SetTitle("")
        frame2:ShowCloseButton(false)
        frame2:SetSizable(false)
        frame2:SetDraggable(false)
        frame2:Receiver("Inventory_gRust", DoDrop)
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
            sAndbox.pnl[i].RealSlotID = i
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

            grid2:AddCell(sAndbox.pnl[i])
        end

        BlehsAndbox = true
    end

    if IsValid(sAndbox.pnl[inv_Slot]) and inventory["Weapon"] then sAndbox.pnl[inv_Slot].Weps = inventory["Weapon"] end
end)

function sAndbox.InventoryMain()
    net.Start("sAndbox_Inventory_RequestAll")
    net.SendToServer()
    
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
        -- Store existing image before creating new panel
        local existingImage = sAndbox.img[i]
        local existingData = nil
        if IsValid(existingImage) then existingData = existingImage.InventoryData end
        -- Create or recreate panel
        sAndbox.pnl[i] = vgui.Create("DPanel")
        sAndbox.pnl[i]:SetTall(100)
        sAndbox.pnl[i]:Receiver("Inventory_gRust", DoDrop)
        sAndbox.pnl[i].RealSlotID = i
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
        -- Restore existing item if it was there
        if existingData then
            sAndbox.img[i] = vgui.Create("DImageButton", sAndbox.pnl[i])
            sAndbox.img[i]:SetImage(existingData.Mats)
            sAndbox.img[i]:SetSize(90, 86)
            sAndbox.img[i]:Droppable("Inventory_gRust")
            sAndbox.img[i].CurrentSlot = i
            sAndbox.img[i].InventoryData = existingData
        end
    end

    hook.Call("LoadInventory", nil, sAndbox.pnl, sAndbox.pnl, frame, inventory, inv_Slot)
    return frame
end

hook.Add("PlayerBindPress", "sAndbox_InventoryHotkeys", function(ply, bind, pressed)
    local str_Find = string.find(bind, "slot")
    if not str_Find then return end
    local binds = string.gsub(bind, "slot", "")
    local tonum = tonumber(binds)
    if tonum and sAndbox.pnl[tonum] and IsValid(sAndbox.pnl[tonum]) and sAndbox.pnl[tonum].Weps then
        net.Start("sAndbox_Inventory_SelectWeapon")
        net.WriteString(sAndbox.pnl[tonum].Weps)
        net.SendToServer()
    end
end)