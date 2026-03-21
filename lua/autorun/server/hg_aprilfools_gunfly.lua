if not SERVER then return end

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local function isGun(wep)
	if not IsValid(wep) or not wep:IsWeapon() then return false end
	if wep.ismelee or wep.ismelee2 then return false end
	if wep:GetClass() == "weapon_hands_sh" then return false end
	return ishgweapon(wep)
end

local function triggerGunFly(ply)
	if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then return end
	local wep = ply:GetActiveWeapon()
	if not isGun(wep) or wep.NoDrop then return end
	if wep.hgGunFlyActive then return end
	wep.hgGunFlyActive = true

	wep:EmitSound("cartoony ass run.wav", 75, 100, 1, CHAN_ITEM)
	local start = CurTime()
	local duration = 1.4
	wep:SetNWFloat("hg_gunfly_start", start)
	wep:SetNWFloat("hg_gunfly_end", start + duration)

	timer.Simple(duration + 0.1, function()
		if IsValid(wep) then
			local owner = wep:GetOwner()
			if IsValid(owner) and owner:IsPlayer() then
				owner:SelectWeapon("weapon_hands_sh")
			end
			wep:Remove()
		end
	end)
end

local nextCheck = 0
hook.Add("Think", "hg-aprilfools-gunfly", function()
	if not aprilFoolsEnabled() then return end
	local now = CurTime()
	if now < nextCheck then return end
	nextCheck = now + 0.5

	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then continue end
		ply.HG_AF_GunFlyNext = ply.HG_AF_GunFlyNext or 0
		if now < ply.HG_AF_GunFlyNext then continue end
		ply.HG_AF_GunFlyNext = now + 2

		if math.random() > 0.05 then continue end
		triggerGunFly(ply)
	end
end)

concommand.Add("hg_gunfly", function(ply, _, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local target = ply
	if not IsValid(ply) and args[1] then
		for _, p in ipairs(player.GetAll()) do
			if string.find(string.lower(p:Nick()), string.lower(args[1]), 1, true) then
				target = p
				break
			end
		end
	end
	if IsValid(target) then
		triggerGunFly(target)
	end
end)
