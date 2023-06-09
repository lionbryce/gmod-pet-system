local availableRotations = {
	Angle(90,0,0),
	Angle(-90,0,0),
	Angle(0,90,0),
	Angle(0,-90,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}
local function updateSnakesNew(snake)
	local FT = FrameTime()
	local CT = CurTime()
	
	local segments = snake.segments
	local moves = snake.moves
	
	snake.newposStartTime = snake.newposStartTime or CT
		
	local timeDiff = (CT - snake.newposStartTime) * snake.timeRatio
	
	for k,v in ipairs(segments) do
		if not IsValid(v) then continue end
		
		local ang = v:GetAngles()
		local pos = v:GetPos()
		
		if !v.newpos or !v.oldpos then
			v.oldpos = pos
			v.newpos = pos + moves[k]
		end
		
		v:SetPos( LerpVector( timeDiff, v.oldpos, v.newpos ) )
	end
	
	if timeDiff >= 1 then -- CT > snake.movingSegmentTime then
		snake.movingSegmentTime = CT + snake.movingSegmentDuration
		
		snake.newposStartTime = nil
		for k,v in ipairs(segments) do
			if IsValid(v) then
				v.oldpos = nil
				v:SetPos(v.newpos)
			end
		end
		
		for i = snake.segmentCount,2,-1 do
			moves[i] = moves[i-1]
		end
		
		local newMove = Vector(moves[1])
		
		newMove:Rotate(availableRotations[math.random(1,#availableRotations)])
		
		--local newMove = calculateNewMove()
		
		moves[1] = newMove
	end
end

dec_petsystem.DeclarePet("Wormy", function()
	local ent = {}
	
	local scale = 0.2
	local segmentCount = 10
	local pos = Vector()
	local timeRatio = 10
	
	ent.segments = {}
	
	ent.movingSegment = 1
	ent.movingSegmentDuration = 1
	ent.movingSegmentTime = CurTime() + ent.movingSegmentDuration
	ent.segmentCount = segmentCount
	ent.segmentGap = Vector(0,0,12) * scale
	ent.timeRatio = timeRatio
	
	local default = Vector(0,0,12) * scale
	ent.moves = {}
	
	local segments = ent.segments
	local segmentGap = ent.segmentGap
	local moves = ent.moves
	
	for i=1,segmentCount do
		moves[i] = default
		
		local segment = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
		segment:SetPos(pos - segmentGap * i)
		segment:SetAngles(Angle())
		segment:SetModelScale( scale, 0 )
		segment.moveVector = Vector(0,0,24) * scale
		segments[i] = segment
		
		segment:Spawn()
	end
	
	segments[1]:SetColor(Color(91,64,51))
	segments[segmentCount]:SetColor(Color(200,200,0))
	
	function ent.Remove(ent)
		for k,v in ipairs(segments) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
	
	function ent.SetPos(ent,newPos)
		local oldPos = ent:GetPos()
		local diff = newPos - oldPos
		for k,v in ipairs(segments) do
			v:SetPos(v:GetPos() + diff)
			
			if v.newpos then
				v.newpos = v.newpos + diff
			end
			
			if v.oldpos then
				v.oldpos = v.oldpos + diff
			end
		end
	end
	
	function ent.GetPos(ent,newPos)
		return segments[1]:GetPos()
	end
	
	ent.PetIdle = updateSnakesNew
	
	return ent
end)