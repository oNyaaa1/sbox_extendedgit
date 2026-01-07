local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
util.AddNetworkString("sAndbox_GridSize_Inventory2")
util.AddNetworkString("sAndbox_Inventory_SaveSlots")
util.AddNetworkString("sAndbox_Inventory_Drop")
util.AddNetworkString("sAndbox_Inventory_SelectWeapon")
util.AddNetworkString("sAndbox_Inventory_RequestAll")
net.Receive("sAndbox_Inventory_RequestAll", function(len, pl)
    if not IsValid(pl) or not pl.Inventory then return end
    -- Send all inventory items to client
    for i = 1, 36 do
        if pl.Inventory[i] and pl.Inventory[i].Weapon then
            net.Start("sAndbox_GridSize_Inventory")
            net.WriteTable(pl.Inventory[i])
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

function PLAYER:FindSlot()
    for i = 1, 36 do
        if not self.Inventory[i] or not self.Inventory[i].Weapon then return i end
    end
    return -1
end

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
        }
    end

    -- Move item from old slot to new slot
    pl.Inventory[newslot] = {
        Weapon = wep,
        Mats = mats,
        Slot = newslot,
    }

    -- If there was an item in new slot, move it to old slot (swap)
    if swapItem then
        pl.Inventory[oldslot] = {
            Weapon = swapItem.Weapon,
            Mats = swapItem.Mats,
            Slot = oldslot,
        }
    else
        -- Clear old slot if no swap
        pl.Inventory[oldslot] = nil
    end

    -- Handle weapon selection based on slot
    if newslot >= 7 and newslot <= 36 then
        if pl:HasWeapon("rust_e_hands") then pl:SelectWeapon("rust_e_hands") end
    elseif newslot >= 1 and newslot <= 6 then
        if pl:HasWeapon(wep) then pl:SelectWeapon(wep) end
    end

    -- Send new slot update to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(pl.Inventory[newslot])
    net.WriteFloat(newslot)
    net.WriteBool(true)
    net.Send(pl)
    -- Send old slot update (either swapped item or clear)
    net.Start("sAndbox_GridSize_Inventory")
    if swapItem then
        net.WriteTable(pl.Inventory[oldslot])
        net.WriteFloat(oldslot)
        net.WriteBool(true)
    else
        net.WriteTable({
            Weapon = nil,
            Mats = nil
        })

        net.WriteFloat(oldslot)
        net.WriteBool(false)
    end

    net.Send(pl)
end)

function PLAYER:AddInventoryItem(item, bool, amount, slot)
    if not self.Inventory then self.Inventory = {} end
    slot = slot or self:FindSlot()
    if slot == -1 then
        slot = 7 -- Default to first storage slot
    end

    local itemz = ITEMS:GetItem(item.Weapon)
    -- Store item data
    self.Inventory[slot] = {
        Weapon = item.Weapon or item,
        Mats = itemz.model,
        Slot = slot,
        amount = amount or 1,
    }

    -- Give weapon to player
    self:Give(item.Weapon or item)
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot])
    net.WriteFloat(slot)
    net.WriteBool(bool ~= false) -- Default to true
    net.Send(self)
    net.Start("DAtaSendGrust")
    net.Send(self)
end

--[[

function FindItemSlot(ply, item)
    if not ply.Inventory then return -1 end
    for i = 1, 36 do
        if ply.Inventory[i] and ply.Inventory[i].Weapon == item then return i end
    end
    return -1
end
]]
function PLAYER:FindItemSlot(item)
    local itemz = ITEMS:GetItem(item)
    for k, v in pairs(self.Inventory) do
        if v.Weapon == item and v.amount <= itemz.StackSize then return v.Slot end
    end
    return 7
end

function PLAYER:ExistingInventoryItem(item, amount)
    if not self.Inventory then self.Inventory = {} end
    local itemslot = self:FindItemSlot(item.Weapon)
    local itemz = ITEMS:GetItem(item.Weapon)
    self:SetPData(item.Weapon, tonumber(self:GetPData(item.Weapon, 0) + amount))
    self.Inventory[itemslot] = {
        Weapon = item.Weapon or item,
        Mats = itemz.model,
        Slot = itemslot,
        amount = tonumber(self:GetPData(item.Weapon, 0)),
    }

    -- Give weapon to player
    --self:Give(item.Weapon or item)
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[itemslot])
    net.WriteFloat(itemslot)
    net.WriteBool(true) -- Default to true
    net.Send(self)
    net.Start("DAtaSendGrust")
    net.Send(self)
    return true
end

function PLAYER:RemoveInventoryItem(item)
    local slot = FindItemSlot(self, item)
    if slot == -1 then return end
    -- Clear inventory slot
    self.Inventory[slot] = nil
    -- Remove weapon from player
    if self:HasWeapon(item) then self:StripWeapon(item) end
    -- Send update to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable({
        Weapon = nil,
        Mats = nil
    })

    net.WriteFloat(slot)
    net.WriteBool(false)
    net.Send(self)
    net.Start("DAtaSendGrust")
    net.Send(self)
end

function PLAYER:LoadInventoryItem(item, bool, slot)
    self.Inventory = nil
    net.Start("DAtaSendGrust")
    net.Send(self)
    if not self.Inventory then self.Inventory = {} end
    slot = slot or self:FindSlot()
    if slot == -1 then
        slot = 7 -- Default to first storage slot
    end

    -- Store item data
    self.Inventory[slot] = {
        Weapon = item.Weapon or item,
        Mats = item.Mats,
        Slot = slot,
    }

    -- Give weapon to player
    self:Give(item.Weapon or item)
    -- Send to client
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot])
    net.WriteFloat(slot)
    net.WriteBool(bool ~= false) -- Default to true
    net.Send(self)
    net.Start("DAtaSendGrust")
    net.Send(self)
end

net.Receive("sAndbox_Inventory_Drop", function(len, ply)
    if not IsValid(ply) then return end
    local item = net.ReadString()
    local img = net.ReadString()
    if item == "" then return end
    -- Create dropped item entity
    local ent = ents.Create("rust_item_drop")
    if not IsValid(ent) then return end
    ent:SetCount(1)
    ent:SetItem(item)
    ent:SetImage(img)
    ent:SetPos(ply:GetPos() + ply:GetForward() * 32 + Vector(0, 0, 16))
    ent:Spawn()
    ent:Activate()
    -- Remove from inventory
    ply:RemoveInventoryItem(item)
    -- Equip hands
    if ply:HasWeapon("rust_e_hands") then ply:SelectWeapon("rust_e_hands") end
end)

function PLAYER:CountInventory()
    if not self.Inventory then
        self.Inventory = {}
        return 0
    end

    local count = 0
    for i = 1, 36 do
        if self.Inventory[i] and self.Inventory[i].Weapon then count = count + 1 end
    end
    return count
end

-- Initialize inventory on spawn
hook.Add("PlayerSpawn", "sAndbox_InitInventory", function(ply) if not ply.Inventory then ply.Inventory = {} end end)