AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Item Loot Drop"
ENT.Count = 0
ENT.Item = ""
ENT.Image = ""
function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/environment/misc/loot_bag.mdl")
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:SetCount(count)
    self.Count = count
end

function ENT:SetItem(item)
    self.Item = item
end

function ENT:SetImage(img)
    self.Image = img
end

function ENT:GetImage()
    return self.Image
end

function ENT:GetItem()
    return self.Item
end

function ENT:GetCount()
    return self.Count
end

function ENT:Use(act, ply)
    ply:AddInventoryItem({
        Weapon = self:GetItem(),
        Mats = self:GetImage(),
    })

    self:Remove()
end