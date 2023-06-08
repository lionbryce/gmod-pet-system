dec_petsystem.PetTypes.simple = nil

dec_petsystem.DeclarePet("Simple", function(data)
	local ent = ClientsideModel(data.model or "models/props_combine/breenbust.mdl")
	
	ent:SetModelScale(data.scale or 1, 0)

	ent.wiggle = Vector()
	ent.wiggleTimeOffset = math.Rand(0,math.pi*2)

	function ent:PetIdle()
		local dir = (ent.player:GetPos() - self:GetPos())
		dir.z = 0
		
		self:SetAngles(dir:GetNormalized():Angle())
		
		local wiggle = Vector(0,0,math.sin(CurTime()) * 5 + self.wiggleTimeOffset)
		self:SetPos(self:GetPos() + wiggle - ent.wiggle)

		ent.wiggle = wiggle
	end

	return ent
end)

dec_petsystem.DeclareSubPetEasy("Simple", "Cube", {model = [[models/hunter/blocks/cube025x025x025.mdl]]})
dec_petsystem.DeclareSubPetEasy("Simple", "Plate", {model = [[models/hunter/plates/plate.mdl]]})
dec_petsystem.DeclareSubPetEasy("Simple", "2x2Cube", {model = [[models/hunter/blocks/cube05x05x05.mdl]]})
dec_petsystem.DeclareSubPetEasy("Simple", "Hula", {model = [[models/props_lab/huladoll.mdl]]})
dec_petsystem.DeclareSubPetEasy("Simple", "Skull", {model = [[models/Gibs/HGIBS.mdl]]})