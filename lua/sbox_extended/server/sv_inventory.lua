local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
function PLAYER:CreateInventory(item, gridsize)
    self.InventoryGrid[1] = {item, gridsize}
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.InventoryGrid[1])
    net.Send(self)
end

function PLAYER:AddInventoryItem(item)
    self.InventoryGrid[#self.InventoryGrid + 1] = {item}
end

function PLAYER:CountInventory()
    return #self.InventoryGrid
end