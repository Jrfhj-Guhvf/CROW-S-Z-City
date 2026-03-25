local CurTime, IsValid = CurTime, IsValid
local math_random, math_sin, math_clamp = math.random, math.sin, math.Clamp
local VectorRand = VectorRand

local DECORT_FORCE, DECEREB_FORCE = 40, 40
local PD_STARTUP_DELAY = 0.2
local ARM_VEL_DAMP     = 0.25
local CHANCE           = 0.05
local HEADSHOT_TTL     = 2
local LEG_VEL_DAMP     = 0.06
local WATER_DRAG_XY    = 1.2
local WATER_SPEED_CAP  = 120

local LEG_STEER_SPEED  = 150
local LEG_STEER_GAIN   = 8

local FOOT_EXTRA_PITCH = 25
local ROLL_IN          = 18

local decorticateArms = {
	{"ValveBiped.Bip01_R_Hand",    "ValveBiped.Bip01_Spine2",    1.2},
	{"ValveBiped.Bip01_L_Hand",    "ValveBiped.Bip01_Spine2",    1.2},
	{"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_Spine2",    1.0},
	{"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_Spine2",    1.0}
}

local decerebrateArms = {
	{"ValveBiped.Bip01_R_Hand",    "ValveBiped.Bip01_R_Thigh",   1.0},
	{"ValveBiped.Bip01_L_Hand",    "ValveBiped.Bip01_L_Thigh",   1.0},
	{"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_UpperArm",0.6},
	{"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_UpperArm",0.6}
}

local SPINE_BONE_NAMES = {
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Pelvis",
}

local leg_patterns = {"thigh","calf","shin","leg","foot","ankle","knee"}
local function IsLegBoneName(name)
	if not name then return false end
	name = string.lower(name)
	for i = 1, #leg_patterns do
		if string.find(name, leg_patterns[i], 1, true) then return true end
	end
	return false
end

local function GetSpinePhysIdx(rag)
	if rag._spinePhysIdx ~= nil then return rag._spinePhysIdx end
	local count = rag:GetPhysicsObjectCount()
	local nameToIdx = {}
	for i = 0, count - 1 do
		local boneId = rag:TranslatePhysBoneToBone(i)
		local name   = boneId and rag:GetBoneName(boneId) or ""
		if name ~= "" then nameToIdx[name] = i end
	end
	for i = 1, #SPINE_BONE_NAMES do
		local candidate = SPINE_BONE_NAMES[i]
		if nameToIdx[candidate] then
			rag._spinePhysIdx = nameToIdx[candidate]
			return rag._spinePhysIdx
		end
	end
	rag._spinePhysIdx = false
	return false
end

local function NormalizeAngleDiff(diff)
	local function norm(v)
		v = v % 360
		if v > 180 then v = v - 360 end
		if v < -180 then v = v + 360 end
		return v
	end
	return Angle(norm(diff.p), norm(diff.y), norm(diff.r))
end

local function SteerBoneAngle(phys, targetAng, speed, gain)
	if not IsValid(phys) or not phys:IsMoveable() then return end
	local diff = NormalizeAngleDiff(targetAng - phys:GetAngles())
	phys:SetAngleVelocity(Vector(
		math_clamp(diff.p * gain, -speed, speed),
		math_clamp(diff.y * gain, -speed, speed),
		math_clamp(diff.r * gain, -speed, speed)
	))
end

local function EnsureLegPDCache(rag)
	if rag.pdLegCache and rag.pdLegCacheModel == rag:GetModel() then return end
	local count = rag:GetPhysicsObjectCount()

	local boneNameToPhysIdx = {}
	for i = 0, count - 1 do
		local boneId = rag:TranslatePhysBoneToBone(i)
		local name   = boneId and rag:GetBoneName(boneId) or ""
		if name ~= "" then
			boneNameToPhysIdx[name] = i
		end
	end

	local t = {}
	for i = 0, count - 1 do
		local boneId = rag:TranslatePhysBoneToBone(i)
		local name   = boneId and rag:GetBoneName(boneId) or ""
		if name == "" or not IsLegBoneName(name) then continue end

		local lname   = string.lower(name)
		local isRight = string.find(name, "_R_") ~= nil

		local boneType
		if     string.find(lname, "thigh")                              then boneType = "thigh"
		elseif string.find(lname, "calf") or string.find(lname, "shin") then boneType = "calf"
		elseif string.find(lname, "foot")                               then boneType = "foot"
		else                                                                  boneType = "other" end

		local parentBoneName
		if boneType == "thigh" then
			parentBoneName = "ValveBiped.Bip01_Pelvis"
		elseif boneType == "calf" then
			parentBoneName = isRight and "ValveBiped.Bip01_R_Thigh" or "ValveBiped.Bip01_L_Thigh"
		elseif boneType == "foot" then
			parentBoneName = isRight and "ValveBiped.Bip01_R_Calf" or "ValveBiped.Bip01_L_Calf"
			if not boneNameToPhysIdx[parentBoneName] then
				parentBoneName = isRight and "ValveBiped.Bip01_R_Shin" or "ValveBiped.Bip01_L_Shin"
			end
		else
			parentBoneName = "ValveBiped.Bip01_Pelvis"
		end

		local parentPhysIdx = parentBoneName and boneNameToPhysIdx[parentBoneName]
		if not parentPhysIdx and boneType == "thigh" then
			parentPhysIdx = boneNameToPhysIdx["ValveBiped.Bip01_Spine"] or boneNameToPhysIdx["ValveBiped.Bip01_Spine1"]
		end

		t[#t+1] = {
			i             = i,
			name          = name,
			boneType      = boneType,
			isRight       = isRight,
			parentPhysIdx = parentPhysIdx,
			roll          = isRight and -ROLL_IN or ROLL_IN
		}
	end
	rag.pdLegCache      = t
	rag.pdLegCacheModel = rag:GetModel()
end

local function EnvScales(rag)
	local pelvis = rag:LookupBone("ValveBiped.Bip01_Pelvis") or rag:LookupBone("ValveBiped.Bip01_Spine")
	local pos = pelvis and select(1, rag:GetBonePosition(pelvis)) or rag:GetPos()
	local tr = util.QuickTrace(pos, Vector(0,0,-30), rag)
	local airborne = not tr.Hit
	local water = rag:WaterLevel() > 0
	local forceScale = 1
	local damp = LEG_VEL_DAMP
	if airborne then
		if rag._postureBlastUntil and CurTime() < rag._postureBlastUntil then
			forceScale = 0
			damp = 0
		else
			forceScale = forceScale * 0.25
			damp = 0
		end
	end
	if water then forceScale = forceScale * 0.2 damp = damp * 6 end
	return forceScale, damp, airborne, water
end

local function ApplyWaterDrag(rag)
	if rag:WaterLevel() <= 0 then return end
	local count = rag:GetPhysicsObjectCount()
	for i = 0, count - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			local v = phys:GetVelocity()
			local lateral = Vector(v.x, v.y, 0)
			local ls = lateral:Length()
			if ls > 0 then
				local cap = math.min(ls, WATER_SPEED_CAP)
				local drag = lateral:GetNormalized() * cap * phys:GetMass() * WATER_DRAG_XY
				phys:ApplyForceCenter(-drag)
			end
		end
	end
end

local function processLegExtension(rag)
	EnsureLegPDCache(rag)
	local cache = rag.pdLegCache or {}
	if #cache == 0 then return end

	local pelvisBone = rag:LookupBone("ValveBiped.Bip01_Pelvis") or rag:LookupBone("ValveBiped.Bip01_Spine")
	if not pelvisBone then return end
	local pelvisPos = rag:GetBonePosition(pelvisBone)

	local spineIdx = GetSpinePhysIdx(rag)
	local spineYaw = 0
	if spineIdx then
		local sp = rag:GetPhysicsObjectNum(spineIdx)
		if IsValid(sp) then spineYaw = sp:GetAngles().y end
	end
	local legDir = -Vector(math.cos(math.rad(spineYaw)), math.sin(math.rad(spineYaw)), 0)

	local targets = {
		thigh = pelvisPos + legDir * 18,
		calf  = pelvisPos + legDir * 36,
		foot  = pelvisPos + legDir * 52,
	}

	local scale, dampMul = EnvScales(rag)
	local FORCE = 9.7 * scale

	for i = 1, #cache do
		local data = cache[i]
		local phys = rag:GetPhysicsObjectNum(data.i)
		if not IsValid(phys) then continue end

		local tgt = targets[data.boneType]
		if not tgt then continue end

		local bonePos = phys:GetPos()
		local dir = tgt - bonePos
		dir.z = 0
		local dist = dir:Length()
		if dist < 1 then continue end
		dir:Normalize()

		local v = phys:GetVelocity()
		v.z = 0
		phys:ApplyForceCenter(-v * phys:GetMass() * dampMul)
		phys:ApplyForceCenter(dir * FORCE * phys:GetMass())
	end
	ApplyWaterDrag(rag)
end

local function processDecorticate(rag)
	local pulse = 0.85 + math_sin(CurTime() * 4) * 0.15
	local chest = rag:LookupBone("ValveBiped.Bip01_Spine2")
	            or rag:LookupBone("ValveBiped.Bip01_Spine1")
	            or rag:LookupBone("ValveBiped.Bip01_Spine")
	local chestPos = chest and rag:GetBonePosition(chest) or rag:GetPos()
	local chestAng = (chest and rag:GetBoneMatrix(chest) and rag:GetBoneMatrix(chest):GetAngles()) or Angle()
	local chestTarget = chestPos + chestAng:Up() * 4 + chestAng:Forward() * 6
	if rag.postureLimpUntil and CurTime() < rag.postureLimpUntil then
		processLegExtension(rag)
		return
	end
	if rag._postureBlastUntil and CurTime() < rag._postureBlastUntil then
		processLegExtension(rag)
		return
	end
	local forceScale, _, airborne = EnvScales(rag)
	for i = 1, #decorticateArms do
		local d    = decorticateArms[i]
		local bone = rag:LookupBone(d[1])
		if not bone then continue end
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
		if not IsValid(phys) then continue end
		local vel = phys:GetVelocity()
		vel.z = 0
		if not airborne then
			phys:ApplyForceCenter(-vel * phys:GetMass() * ARM_VEL_DAMP)
		end
		local dir = (chestTarget - rag:GetBonePosition(bone)):GetNormalized()
		if airborne then dir.z = 0 end
		phys:ApplyForceCenter(dir * DECORT_FORCE * d[3] * pulse * forceScale + VectorRand(-20,20) * forceScale)
	end
	processLegExtension(rag)
	ApplyWaterDrag(rag)
end

local function processDecerebrate(rag)
	local pulse = 0.9 + math_sin(CurTime() * 3) * 0.1
	if rag.postureLimpUntil and CurTime() < rag.postureLimpUntil then
		processLegExtension(rag)
		return
	end
	if rag._postureBlastUntil and CurTime() < rag._postureBlastUntil then
		processLegExtension(rag)
		return
	end
	local forceScale, _, airborne = EnvScales(rag)
	for i = 1, #decerebrateArms do
		local d          = decerebrateArms[i]
		local bone       = rag:LookupBone(d[1])
		local targetBone = rag:LookupBone(d[2])
		if not bone or not targetBone then continue end
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(bone))
		if not IsValid(phys) then continue end
		local vel  = phys:GetVelocity()
		vel.z = 0
		if not airborne then
			phys:ApplyForceCenter(-vel * phys:GetMass() * ARM_VEL_DAMP)
		end
		local dir = (rag:GetBonePosition(targetBone) - rag:GetBonePosition(bone)):GetNormalized()
		if airborne then dir.z = 0 end
		phys:ApplyForceCenter(dir * DECEREB_FORCE * d[3] * pulse * forceScale + VectorRand(-15,15) * forceScale)
	end
	processLegExtension(rag)
	ApplyWaterDrag(rag)
end

-- -------------------------------------------------------
-- FIX 1: Track headshots BEFORE death via ScalePlayerDamage.
-- This runs every time a player takes damage, giving us the
-- hitgroup reliably. We stamp a short-lived flag on the player.
-- -------------------------------------------------------
hook.Add("ScalePlayerDamage", "Posturing_TrackHeadshot", function(ply, hitgroup, dmginfo)
	if hitgroup == HITGROUP_HEAD then
		ply._posturing_headshot_until = CurTime() + HEADSHOT_TTL
	end
end)

-- -------------------------------------------------------
-- FIX 2: RagdollDeath now has a layered check:
--   Layer 1 - reliable: the _posturing_headshot flag set above
--   Layer 2 - your organism system (kept as bonus condition)
-- Either condition alone is enough to trigger posturing.
-- -------------------------------------------------------
hook.Add("RagdollDeath", "Posturing_Start", function(ply, rag)
	local flagHeadshot = (ply._posturing_headshot_until or 0) >= CurTime()
	ply._posturing_headshot_until = nil

	timer.Simple(0.1, function()
		if not IsValid(ply) or not IsValid(rag) then return end

		local orgHeadshot = false
		local org = rag.organism or ply.organism
		if org then
			orgHeadshot = (org.brain and org.brain > 0)
			            or (org.skull and org.skull > 0)
			            or (org.dmgstack and org.dmgstack[HITGROUP_HEAD]
			                and (org.dmgstack[HITGROUP_HEAD][1] or 0) > 0)
		end

		local ragHeadshot = rag.noHead or rag.headexploded
		local headshot = flagHeadshot or ragHeadshot or orgHeadshot

		if headshot and math_random() < CHANCE then
			rag.posture      = math_random(2) == 1 and "decorticate" or "decerebrate"
			rag.postureActive = true
			rag.postureStart  = CurTime() + (0.01 + math_random() * 0.05)
			rag.postureEnd    = CurTime() + 8
			rag.postureShots  = 0
			rag.postureStopThreshold = math_random(2,5)
			rag.spasmScale = 1
		end
	end)
end)

-- -------------------------------------------------------
-- FIX 3: Run posturing on the standard Think hook instead of
-- (or in addition to) "Org Think", which won't fire unless
-- your gamemode explicitly calls hook.Run("Org Think", ...).
-- We iterate all active ragdolls on the server each tick.
-- -------------------------------------------------------
hook.Add("Think", "Posturing_Think", function()
	local now = CurTime()
	for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
		if not IsValid(ent) or not ent.postureActive then continue end

		if ent.postureEnd and now > ent.postureEnd then
			ent.postureActive = nil
			ent.posture       = nil
			ent.postureEnd    = nil
			ent.postureStart  = nil
			continue
		end

		if ent.postureStart and now < ent.postureStart then continue end

		if ent.posture == "decorticate" then
			processDecorticate(ent)
		elseif ent.posture == "decerebrate" then
			processDecerebrate(ent)
		end
	end
end)

hook.Add("EntityTakeDamage", "Posturing_InterruptOnShots", function(ent, dmginfo)
	if not IsValid(ent) then return end
	if not ent:IsRagdoll() then return end
	if not ent.postureActive then return end
	-- Only count shots after posturing actually begins (after startup delay)
	if ent.postureStart and CurTime() < ent.postureStart then return end
	if dmginfo:IsDamageType(DMG_BLAST) then
		ent._postureBlastUntil = CurTime() + 0.6
		return
	end
	if not dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end
	-- Headshot filter: find nearest phys bone to damage position and require head
	local dmgPos = dmginfo:GetDamagePosition()
	if dmgPos then
		local nearestIdx, best = nil, 1e12
		local count = ent:GetPhysicsObjectCount()
		for i = 0, count - 1 do
			local phys = ent:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				local d = phys:GetPos():DistToSqr(dmgPos)
				if d < best then
					best, nearestIdx = d, i
				end
			end
		end
		if nearestIdx ~= nil then
			local boneId = ent:TranslatePhysBoneToBone(nearestIdx) or 0
			local bonename = ent:GetBoneName(boneId) or ""
			if not string.find(bonename, "Head", 1, true) then return end
		end
	end
	-- Apply a single noticeable but safe impulse only once per limp window
	local inLimp = ent.postureLimpUntil and CurTime() < ent.postureLimpUntil
	if not inLimp then
		local spScale = ent.spasmScale or 1
		local base = math.max(DECORT_FORCE, DECEREB_FORCE) * 2.4 * spScale
		local cap = 140
		local dir = dmginfo:GetDamageForce()
		dir = dir:IsZero() and VectorRand(-1,1) or dir:GetNormalized()
		base = math.min(base, cap)
		local count = ent:GetPhysicsObjectCount()
		for i = 0, count - 1 do
			local phys = ent:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				local jitter = VectorRand(-0.4,0.4)
				local impulse = (dir + jitter):GetNormalized() * base
				phys:ApplyForceCenter(impulse)
			end
		end
		ent.spasmScale = spScale * 0.8
		ent.postureLimpUntil = CurTime() + 0.2
	end
	ent.postureShots = (ent.postureShots or 0) + 1
	local threshold = ent.postureStopThreshold or 2
	if ent.postureShots >= threshold then
		ent.postureActive = nil
		ent.posture = nil
		ent.postureEnd = nil
		ent.postureStart = nil
		ent.postureShots = nil
		ent.postureStopThreshold = nil
		ent.spasmScale = nil
	end
end)

-- Keep "Org Think" wired up too in case your gamemode does call it
hook.Add("Org Think", "Posturing_Think_Org", function(owner)
	if not IsValid(owner) then return end
	local rag = owner:IsRagdoll() and owner or owner.FakeRagdoll
	if not IsValid(rag) or not rag.postureActive then return end

	local now = CurTime()
	if rag.postureStart and now < rag.postureStart then return end

	if rag.postureEnd and now > rag.postureEnd then
		rag.postureActive = nil
		rag.posture       = nil
		rag.postureEnd    = nil
		rag.postureStart  = nil
		return
	end

	if rag.posture == "decorticate" then
		processDecorticate(rag)
	elseif rag.posture == "decerebrate" then
		processDecerebrate(rag)
	end
end)
