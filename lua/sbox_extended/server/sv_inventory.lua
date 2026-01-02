local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
util.AddNetworkString("sAndbox_GridSize_Inventory2")
util.AddNetworkString("sAndbox_Inventory_SaveSlots")
util.AddNetworkString("sAndbox_Inventory_Drop")
util.AddNetworkString("sAndbox_Inventory_SelectWeapon")
net.Receive("sAndbox_Inventory_SelectWeapon", function(len, pl)
    local str_Wep = net.ReadString()
    pl:SelectWeapon(str_Wep)
end)

function PLAYER:FindSlot()
    for i = 1, #self.Inventory do
        if not self.Inventory[i] or self.Inventory[i].Slot == nil then return i end
    end
    return -1
end

net.Receive("sAndbox_Inventory_SaveSlots", function(len, pl)
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local wep = net.ReadString()
    local mats = net.ReadString()
    if mats ~= "" then
        pl.Inventory[newslot] = {
            {
                Weapon = wep,
                Mats = mats,
                Slot = newslot,
            },
        }

        if newslot >= 7 and newslot <= 36 then pl:SelectWeapon("rust_e_hands") end
        if newslot >= 1 and newslot <= 6 then pl:SelectWeapon(wep) end
        --pl.Inventory[oldslot] = {}
        net.Start("sAndbox_GridSize_Inventory")
        net.WriteTable(pl.Inventory[newslot][1])
        net.WriteFloat(newslot)
        net.Send(pl)
    end
end)

function PLAYER:AddInventoryItem(item, bool)
    local slot = self:FindSlot()
    if slot == -1 then return end
    self.Inventory[slot] = {
        item,
        Slot = slot
    }

    self:Give(item.Weapon or item)
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot][1])
    net.WriteFloat(slot)
    net.WriteBool(bool)
    net.Send(self)
end

function FindItemSlot(ply, item)
    local num = -1
    for i = 1, #ply.Inventory do
        for k, v in pairs(ply.Inventory[i]) do
            if item == v.Weapon then
                num = i
                break
            end
        end
    end
    return num
end

function PLAYER:RemoveInventoryItem(item)
    local slot = FindItemSlot(self, item)
    self.Inventory[slot] = {
        {
            Weapon = nil,
            Mats = nil,
        },
    }

    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot][1])
    net.WriteFloat(slot)
    net.WriteBool(false)
    net.Send(self)
end

net.Receive("sAndbox_Inventory_Drop", function(len, ply)
    local item = net.ReadString()
    local img = net.ReadString()
    local ent = ents.Create("rust_item_drop")
    ent:SetCount(1)
    ent:SetItem(item)
    ent:SetImage(img)
    ent:SetPos(ply:GetPos() + ply:GetForward() * 32)
    ent:Spawn()
    ent:Activate()
    ply:RemoveInventoryItem(item)
    ply:SelectWeapon("rust_e_hands")
end)

function PLAYER:CountInventory()
    if not self.Inventory then self.Inventory = {} end
    return #self.Inventory
end