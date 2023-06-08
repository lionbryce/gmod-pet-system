dec_petsystem = dec_petsystem or {}

AddCSLuaFile("cl_core.lua")

if CLIENT then
	include("cl_core.lua")
end

if SERVER then
	include("sv_core.lua")
end

function dec_petsystem.LoadPetDefinitions()
	for _, F in SortedPairs(file.Find("pets/*.lua", "LUA"), true) do
		if SERVER then
			AddCSLuaFile("pets/" .. F)
		else
			include("pets/" .. F)
		end
	end

	local petcache = dec_petsystem.petcache or {}
	for ply,ent in pairs(petcache) do
		if IsValid(ply) then 
			ent:Remove()
			petcache[ply] = dec_petsystem.SpawnPet(ent.pettype, ply)
		end
	end
end

dec_petsystem.LoadPetDefinitions()