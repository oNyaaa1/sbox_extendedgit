local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
util.AddNetworkString("sAndbox_GridSize_Inventory2")
util.AddNetworkString("sAndbox_Inventory_SaveSlots")
util.AddNetworkString("sAndbox_Inventory_Drop")
util.AddNetworkString("sAndbox_Inventory_SelectWeapon")
util.AddNetworkString("sAndbox_Inventory_RequestAll")
util.AddNetworkString("DataSendGrust")
net.Receive("sAndbox_Inventory_RequestAll", function(len, pl)
    if not IsValid(pl) or not pl.Inventory then return end
    -- Send all inventory items to client
    for i = 1, 30 do
        if pl.Inventory[i] and pl.Inventory[i].Weapon then
            net.Start("sAndbox_GridSize_Inventory")
            net.WriteTable(pl.Inventory)
            net.WriteFloat(i)
            net.WriteBool(true)
            net.Send(pl)
        end
    end
end)

net.Receive("sAndbox_Inventory_SelectWeapon", function(len, pl)
    local str_Wep = net.ReadString()
    if IsValid(pl) and pl:HasWeapon(str_Wep) then pl:SelectWeapon(str_Wep) end
end)

net.Receive("sAndbox_Inventory_SaveSlots", function(len, pl)
    if not IsValid(pl) then return end
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local wep = net.ReadString()
    local mats = net.ReadString()
    if wep == "" or mats == "" then return end
    if not pl.Inventory then pl.Inventory = {} end
    -- Check if new slot has an item (need to swap)
    local swapItem = nil
    if pl.Inventory[newslot] and pl.Inventory[newslot].Weapon then
        swapItem = {
            Weapon = pl.Inventory[newslot].Weapon,
            Mats = pl.Inventory[newslot].Mats,
            amount = pl.Inventory[newslot].amount or 0,
        }
    end

    -- Move item from old slot to new slot
    pl.Inventory[newslot] = {
        Weapon = wep,
        Mats = mats,
        Slot = newslot,
        amount = pl.Inventory[oldslot] and pl.Inventory[oldslot].amount or 0,
    }

    -- If there was an item in new slot, move it to old slot (swap)
    if swapItem then
        pl.Inventory[oldslot] = {
            Weapon = swapItem.Weapon,
            Mats = swapItem.Mats,
            Slot = oldslot,
            amount = swapItem.amount,
        }
    else
        -- Clear old slot if no swap
        pl.Inventory[oldslot] = nil
    end

    -- Handle weapon selection based on slot
    if newslot >= 7 and newslot <= 30 then
        if pl:HasWeapon("rust_e_hands") then pl:SelectWeapon("rust_e_hands") end
    elseif newslot >= 1 and newslot <= 6 then
        if pl:HasWeapon(wep) then pl:SelectWeapon(wep) end
    end

    -- Send new slot update to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(pl.Inventory)
    net.WriteFloat(newslot)
    net.WriteBool(true)
    net.Send(pl)
    -- Send old slot update (either swapped item or clear)
    net.Start("sAndbox_GridSize_Inventory")
    if swapItem then
        net.WriteTable(pl.Inventory)
        net.WriteFloat(oldslot)
        net.WriteBool(true)
    else
        net.WriteTable({})
        net.WriteFloat(oldslot)
        net.WriteBool(false)
    end

    net.Send(pl)
end)

function PLAYER:FindSlot()
    if not self.Inventory then
        self.Inventory = {}
        return 7
    end

    -- Find first empty slot
    for i = 7, 30 do
        if not self.Inventory[i] or not self.Inventory[i].Weapon then return i end
    end

    for i = 1, 6 do
        if not self.Inventory[i] or not self.Inventory[i].Weapon then return i end
    end
    -- If no empty slots, return -1
    return -1
end

function PLAYER:AddInventoryItem(item, bool, amount, slot)
    if not self.Inventory then self.Inventory = {} end
    --if amount or 0 <= 0 then return end
    slot = slot or self:FindSlot()
    if slot == -1 then
        -- Inventory full
        return false
    end

    local itemz = ITEMS:GetItem(item.Weapon or item)
    if not itemz then return false end
    -- Use entity-specific storage instead of global NWFloat
    self.Inventory[slot] = {
        Weapon = item.Weapon or item,
        Mats = itemz.model,
        Slot = slot,
        amount = amount,
    }

    -- Give weapon to player
    if weapons.Get(item.Weapon) then self:Give(item.Weapon or item) end
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory)
    net.WriteFloat(slot)
    net.WriteBool(bool ~= false) -- Default to true
    net.Send(self)
    net.Start("DataSendGrust")
    net.Send(self)
    return true
end

function PLAYER:FindItemSlot(item)
    if not self.Inventory then return -1 end
    local itemz = ITEMS:GetItem(item)
    if not itemz then return -1 end
    for i = 1, 30 do
        if self.Inventory[i] and self.Inventory[i].Weapon == item then
            local currentAmount = self.Inventory[i].amount or 0
            if currentAmount < itemz.StackSize then return i end
        end
    end
    return -1
end

function PLAYER:ExistingInventoryItem(item, amount)
    if not self or not IsValid(self) then return false end
    -- Check if reached max stack
    if not self.Inventory then self.Inventory = {} end
    local itemslot = self:FindItemSlot(item.Weapon or item)
    if itemslot == -1 then return false end
    local itemz = ITEMS:GetItem(item.Weapon or item)
    if not itemz then return false end
    -- Update entity-specific storage
    if self.Inventory[itemslot].amount >= 1000 then
        self.Inventory[itemslot].amount = 0
        return false
    end

    self.Inventory[itemslot].amount = self.Inventory[itemslot].amount + amount
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory)
    net.WriteFloat(itemslot)
    net.WriteBool(true)
    net.Send(self)
    net.Start("DataSendGrust")
    net.Send(self)
    return true
end

function PLAYER:CountRemoveInventoryItem(item, amountz)
    if not self.Inventory then return end
    local slot = -1
    for k, v in pairs(self.Inventory) do
        if item == v.Weapon and v.Slot == k and v.amount >= amountz then
            slot = k
            break
        end
    end

    if slot == -1 then return end
    -- Clear inventory slot
    self.Inventory[slot].amount = self.Inventory[slot].amount - amountz
    self.StoredAmount = self.StoredAmount - amountz
    -- Remove weapon from player
    if self:HasWeapon(item) then self:StripWeapon(item) end
    -- Send update to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory)
    net.WriteFloat(slot)
    net.WriteBool(false)
    net.Send(self)
    net.Start("DataSendGrust")
    net.Send(self)
end

function PLAYER:RemoveInventoryItem(item)
    if not self.Inventory then return end
    local slot = -1
    for i = 1, 30 do
        if self.Inventory[i] and self.Inventory[i].Weapon == item then
            slot = i
            break
        end
    end

    if slot == -1 then return end
    -- Clear inventory slot
    self.Inventory[slot] = nil
    -- Remove weapon from player
    if self:HasWeapon(item) then self:StripWeapon(item) end
    -- Send update to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory)
    net.WriteFloat(slot)
    net.WriteBool(false)
    net.Send(self)
    net.Start("DataSendGrust")
    net.Send(self)
end

function PLAYER:LoadInventoryItem(item, bool, slot)
    if not self.Inventory then self.Inventory = {} end
    slot = slot or self:FindSlot()
    if slot == -1 then
        slot = 7 -- Default to first storage slot
    end

    self.Inventory[slot] = {
        Weapon = item.Weapon or item,
        Mats = item.Mats,
        Slot = slot,
        amount = item.amount or 0,
    }

    -- Give weapon to player
    self:Give(item.Weapon or item)
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory)
    net.WriteFloat(slot)
    net.WriteBool(bool ~= false) -- Default to true
    net.Send(self)
    net.Start("DataSendGrust")
    net.Send(self)
end

net.Receive("sAndbox_Inventory_Drop", function(len, ply)
    if not IsValid(ply) then return end
    local item = net.ReadString()
    local img = net.ReadString()
    local slotZ = net.ReadFloat()
    local slot = 7
    if item == "" then return end
    local r_Slot = ply:FindSlot()
    slot = r_Slot ~= slotZ and slotZ or r_Slot
    local ent = ents.Create("rust_item_drop")
    if not IsValid(ent) then return end
    ent:SetCount(ply.Inventory[slotZ].amount)
    ent:SetItem(item)
    ent:SetImage(img)
    ent:SetSlot(slot)
    ent:SetPos(ply:GetPos() + ply:GetForward() * 32 + Vector(0, 0, 16))
    ent:Spawn()
    ent:Activate()
    ply:RemoveInventoryItem(item)
    if ply:HasWeapon("rust_e_hands") then ply:SelectWeapon("rust_e_hands") end
end)

function PLAYER:CountInventory()
    if not self.Inventory then
        self.Inventory = {}
        return 0
    end

    local count = 0
    for i = 1, 30 do
        if self.Inventory[i] and self.Inventory[i].Weapon then count = count + 1 end
    end
    return count
end

function PLAYER:ClearInventory()
    if not self.Inventory then return end
    -- Strip all weapons
    for i = 1, 30 do
        if self.Inventory[i] and self.Inventory[i].Weapon then if self:HasWeapon(self.Inventory[i].Weapon) then self:StripWeapon(self.Inventory[i].Weapon) end end
    end

    -- Clear inventory table
    self.Inventory = {}
    -- Notify client
    net.Start("DataSendGrust")
    net.Send(self)
end

-- Initialize inventory on spawn
hook.Add("PlayerSpawn", "sAndbox_InitInventory", function(ply)
    if not ply.Inventory then ply.Inventory = {} end
    ply.StoredAmount = 0
end)