dec_petsystem.PetTypes.sequence = nil

dec_petsystem.DeclarePet("Sequence", function(data)
	local ent = ClientsideModel(data.model or "models/seagull.mdl")
	
	ent:SetModelScale(data.scale or 1, 0)

	ent.wiggle = Vector()
	ent.wiggleTimeOffset = math.Rand(0,math.pi*2)

	local seq, _ = ent:LookupSequence(data.sequence or "fly")

	local i = 0 -- my explanation for this is that "source was stealing 2/3rds of my sequences"
	local speed = data.speed or 1

	timer.Simple(0,function()
		if IsValid(ent) then
			ent:ResetSequence(seq)
		end
	end)

	function ent:PetIdle()
		local dir = (ent.player:GetPos() - self:GetPos())
		dir.z = 0
		
		self:SetAngles(dir:GetNormalized():Angle())
		
		local wiggle = Vector(0,0,math.sin(CurTime()) * 5 + self.wiggleTimeOffset)
		self:SetPos(self:GetPos() + wiggle - ent.wiggle)

		ent.wiggle = wiggle
		
		i = (i + FrameTime() * speed) % 1
		self:SetCycle(i)
	end

	return ent
end)

local function E(n,m,s,q)
	dec_petsystem.DeclareSubPetEasy("Sequence",n,{model=m,scale=s,sequence=q})
end

E("Seagull","models/seagull.mdl",0.4,"fly")
E("Crow","models/crow.mdl",0.4,"fly01")
E("Pigeon","models/pigeon.mdl",0.4,"fly01")
E("Dog","models/fallout/dogskin.mdl",0.4,"run_h2h")
