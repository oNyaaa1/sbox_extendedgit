local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
util.AddNetworkString("sAndbox_GridSize_Inventory2")
util.AddNetworkString("sAndbox_Inventory_SaveSlots")
function PLAYER:FindSlot()
    local num = -1
    for i = 1, #self.Inventory do
        if self.Inventory[i] then
            num = i
            break
        end
    end
    return num
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
            },
        }

        --pl.Inventory[oldslot] = {}
        net.Start("sAndbox_GridSize_Inventory")
        net.WriteTable(pl.Inventory[newslot][1])
        net.WriteFloat(newslot)
        net.Send(pl)
    end
end)

function PLAYER:AddInventoryItem(item)
    local slot = self:FindSlot()
    if slot == -1 then return end
    self.Inventory[slot] = {item}
    self:Give(item.Weapon)
    -- self:SelectWeapon(item.Weapon)
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot][1])
    net.WriteFloat(slot)
    net.Send(self)
end

function PLAYER:CountInventory()
    if not self.Inventory then self.Inventory = {} end
    return #self.Inventory
end