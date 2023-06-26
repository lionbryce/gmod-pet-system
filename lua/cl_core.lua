dec_petsystem = dec_petsystem or {} -- to whomever reads this, I did it this way because I wanted to
dec_petsystem.petcache = dec_petsystem.petcache or {}

dec_petsystem.PetTypes = dec_petsystem.PetTypes or {}
dec_petsystem.RequiredFunctions = {
	"Remove",
	"SetPos",
	"GetPos",
}
dec_petsystem.OptionalFunctions = {
	"PetIdle",
	"UpdatePos",
}

local petcache = dec_petsystem.petcache

function dec_petsystem.GetPetData(name)
	name = string.lower(name)
	
	return dec_petsystem.PetTypes[name]
end

function dec_petsystem.DeclarePet(name, spawnFunc, defaultData)
	assert(name, "Missing name (arg1)")
	assert(spawnFunc, "Missing spawnFunc (arg2)")
	
	defaultData = defaultData or {}
	name = string.lower(name)
	
	--assert(!dec_petsystem.GetPetData(name), "A pet type of that name has already been declared: " .. name)
	
	-- Print(spawnFunc,defaultData)

	local testent = spawnFunc(defaultData)
	for _,v in ipairs(dec_petsystem.RequiredFunctions) do
		local f = testent[v]
		assert(f, "Spawn function returned object which does not contain: " .. v)
		assert(isfunction(f), "Spawn function returned object which contains a non-function for: " .. v)
	end
	
	testent:Remove()
	
	dec_petsystem.PetTypes[name] = function(d) return spawnFunc(d or defaultData) end

	-- Print("declared pet: " .. name,spawnFunc)
end

function dec_petsystem.DeclareSubPet(base, name, data)
	assert(base, "Missing base (arg1)")
	assert(name, "Missing name (arg2)")
	assert(data, "Missing data (arg3)")

	base = string.lower(base)
	name = string.lower(name)

	local spawnFunc = dec_petsystem.GetPetData(base)

	assert(spawnFunc, "No pet type with that name has been declared: " .. base)

	dec_petsystem.DeclarePet(name, spawnFunc, data)
end

function dec_petsystem.DeclareSubPetEasy(base, name, data)
	dec_petsystem.DeclareSubPet(base, base..";"..name, data)
end

function dec_petsystem.SpawnPet(name, ply)
	assert(name, "Missing name (arg1)")
	assert(IsValid(ply), "Missing valid ply (arg2)")
	
	name = string.lower(name)
	local petData = dec_petsystem.GetPetData(name)
	
	assert(petData, "No pet type with that name has been declared")
	
	local pet = petData()
	for _,v in ipairs(dec_petsystem.OptionalFunctions) do
		pet[v] = pet[v] or function()end
	end
	
	pet:SetPos(ply:GetShootPos() + ply:GetAimVector() * 32)
	
	if ply.pet then 
		ply.pet:Remove() 
		ply.pet = nil
	end
	
	ply.pet = pet
	pet.player = ply
	pet.pettype = name

	return pet
end

--dec_petsystem.SpawnPet("Wormy", LocalPlayer(), {scale = 0.2})

local maxDistance = 48
local maxDistance2 = maxDistance * maxDistance

local minDistance = 36
local minDistance2 = minDistance * minDistance
hook.Add("Think", "dec_petsystem", function()

	for ply,pet in pairs(petcache) do
		if !IsValid(ply) then
			pet:Remove()
			petcache[ply] = nil 
			continue
		end

		if !pet:UpdatePos() then
			local petPos = pet:GetPos()
			local plyPos = ply:EyePos()
			local newPos = petPos
			
			local dist = petPos:DistToSqr(plyPos)
			if dist > maxDistance2 then
				newPos = plyPos + (petPos - plyPos):GetNormalized() * maxDistance
			elseif dist < minDistance2 then
				newPos = plyPos + (petPos - plyPos):GetNormalized() * minDistance
			end
			
			pet:SetPos(LerpVector(FrameTime(),petPos,newPos))
		end
		
		pet:PetIdle()
	end	
end)

 -- could cause some caching issues here, might just switch to a timer
hook.Add("EntityNetworkedVarChanged","dec_petsystem", function(ply, var, _, name)
	if var ~= "dec_pet" then return end

	if name then -- setup a new one if it exists, this will also remove it
		petcache[ply] = dec_petsystem.SpawnPet(name, ply)
	elseif ply.pet then --just remove it if it doesn't
		ply.pet:Remove()
		petcache[ply] = nil
	end
end)