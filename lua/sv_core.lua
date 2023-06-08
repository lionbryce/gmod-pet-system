util.AddNetworkString("dec_petsystem")

dec_petsystem = dec_petsystem or {}
dec_petsystem.petcache = dec_petsystem.petcache or {}

local petcache = dec_petsystem.petcache

function dec_petsystem.SetPet(ply,petname)
	ply:SetNW2String("dec_pet",petname)
end

function dec_petsystem.GetPet(ply)
	return ply:GetNW2String("dec_pet"), petcache[ply]
end