local PLAYER = FindMetaTable("Player")
util.AddNetworkString("sAndbox_GridSize_Inventory")
function PLAYER:CreateInventory(item, gridsize)
    if not self.InventoryGrid then self.InventoryGrid = {} end
    self.InventoryGrid[1] = {item, gridsize}
    net.Start("sAndbox_GridSize_Inventory")
    net.WriteTable(self.InventoryGrid[1])
    net.Send(self)
end

function PLAYER:AddInventoryItem(item)
    if not self.Inventory then self.Inventory = {} end
    self.Inventory[#self.Inventory + 1] = {item}
end

function PLAYER:CountInventory()
    if not self.Inventory then self.InventoryGriInventoryd = {} end
    return #self.Inventory
end