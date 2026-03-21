if not SERVER then return end

util.AddNetworkString("hg_aprilfools_tuff")
util.AddNetworkString("hg_aprilfools_tuff_done")

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local sounds = {
	"aprilfools/matheus.mp3",
	"aprilfools/jellybean.mp3",
	"aprilfools/phonksleep.mp3",
	"aprilfools/luffy.mp3"
}

local textures = {
	"custom/tuff1",
	"custom/tuff2",
	"custom/tuff3",
	"custom/brazil"
}

local globalBlockUntil = 0

hook.Add("PostCleanupMap", "hg-aprilfools-tuff-block", function()
	globalBlockUntil = CurTime() + 60
end)

hook.Add("Initialize", "hg-aprilfools-tuff-init", function()
	globalBlockUntil = CurTime() + 60
end)

local function startTuff(ply)
	if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then return end
	if ply.hg_tuff_active then return end
	ply.hg_tuff_active = true
	ply:Freeze(true)
	local id = ply:SteamID64() or ply:EntIndex()
	ply.hg_tuff_end = CurTime() + 10
	timer.Remove("hg_tuff_force_" .. id)
	timer.Create("hg_tuff_force_" .. id, 20, 1, function()
		if IsValid(ply) then
			clearEffect(ply)
		end
	end)

	net.Start("hg_aprilfools_tuff")
	local sound = sounds[math.random(#sounds)]
	local texture = textures[math.random(#textures)]
	if sound == "aprilfools/luffy.mp3" then
		texture = "custom/brazil"
	elseif texture == "custom/brazil" then
		sound = "aprilfools/luffy.mp3"
	end
	net.WriteString(sound)
	net.WriteString(texture)
	net.Send(ply)
end

local function clearEffect(ply)
	if not IsValid(ply) then return end
	if ply.hg_tuff_active then
		ply:Freeze(false)
		ply.hg_tuff_active = nil
		ply.hg_tuff_end = nil
	end
	local id = ply:SteamID64() or ply:EntIndex()
	timer.Remove("hg_tuff_force_" .. id)
end

net.Receive("hg_aprilfools_tuff_done", function(_, ply)
	clearEffect(ply)
end)

hook.Add("PlayerDeath", "hg-aprilfools-tuff-clear", function(ply)
	clearEffect(ply)
end)

hook.Add("PlayerDisconnected", "hg-aprilfools-tuff-clear", function(ply)
	clearEffect(ply)
end)

hook.Add("PlayerSpawn", "hg-aprilfools-tuff-clear", function(ply)
	clearEffect(ply)
end)

local nextCheck = 0
hook.Add("Think", "hg-aprilfools-tuff", function()
	local now = CurTime()
	if now < nextCheck then return end
	nextCheck = now + 1

	if not aprilFoolsEnabled() then
		for _, ply in ipairs(player.GetAll()) do
			clearEffect(ply)
		end
		return
	end

	if now < globalBlockUntil then return end

	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then continue end
		ply.hg_tuff_next = ply.hg_tuff_next or 0
		if ply.hg_tuff_active then
			if ply.hg_tuff_end and now >= ply.hg_tuff_end then
				clearEffect(ply)
			end
			continue
		end
		if now < ply.hg_tuff_next then continue end
		ply.hg_tuff_next = now + math.Rand(30, 50)

		startTuff(ply)
	end
end)

concommand.Add("hg_tuff", function(ply, _, args)
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
		startTuff(target)
	end
end)
