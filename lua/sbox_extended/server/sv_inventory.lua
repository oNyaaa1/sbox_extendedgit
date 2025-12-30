local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
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

function PLAYER:AddInventoryItem(item)
    local slot = self:FindSlot()
    if slot == -1 then return end
    self.Inventory[slot] = {item}
    self:Give(item.Weapon)
    -- self:SelectWeapon(item.Weapon)
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot])
    net.WriteTable(self.Inventory2[slot])
    net.WriteFloat(slot)
    net.Send(self)
end

function PLAYER:CountInventory()
    if not self.Inventory then self.Inventory = {} end
    return #self.Inventory
end