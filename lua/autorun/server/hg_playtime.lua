if not SERVER then return end

local function getStoredTime(ply)
	return tonumber(ply:GetPData("hg_playtime", 0)) or 0
end

local function updatePlaytime(ply, forceSave)
	if not IsValid(ply) then return end
	local base = ply.hg_playtime_base or 0
	local join = ply.hg_playtime_join or CurTime()
	local total = base + math.max(0, CurTime() - join)
	ply:SetNWFloat("hg_playtime_total", total)
	if forceSave then
		ply:SetPData("hg_playtime", math.floor(total))
	end
end

hook.Add("PlayerInitialSpawn", "hg-playtime-join", function(ply)
	ply.hg_playtime_base = getStoredTime(ply)
	ply.hg_playtime_join = CurTime()
	updatePlaytime(ply, true)
end)

hook.Add("PlayerDisconnected", "hg-playtime-leave", function(ply)
	updatePlaytime(ply, true)
end)

timer.Create("hg-playtime-sync", 10, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		updatePlaytime(ply, false)
	end
end)

timer.Create("hg-playtime-save", 60, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		updatePlaytime(ply, true)
	end
end)
