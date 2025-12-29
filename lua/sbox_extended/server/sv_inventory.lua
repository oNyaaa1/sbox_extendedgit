local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
function PLAYER:FindSlot()
    for i = 1, #self.Inventory do
        print(i)
        if i ~= nil then return i end
    end
    return -1
end

function PLAYER:AddInventoryItem(item)
    if not self.Inventory then self.Inventory = {} end
    local slot = 1 --self:FindSlot()
    if slot == -1 then return end
    self.Inventory[slot] = {item}
    self:Give(item.Weapon)
    self:SelectWeapon(item.Weapon)
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.Inventory[slot])
    net.WriteFloat(24)
    net.Send(self)
end

function PLAYER:CountInventory()
    if not self.Inventory then self.Inventory = {} end
    return #self.Inventory
end