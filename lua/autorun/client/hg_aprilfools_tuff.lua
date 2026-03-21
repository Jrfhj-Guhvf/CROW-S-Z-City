if not CLIENT then return end

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local function loadTuffMaterial(path)
	local mat = Material(path, "smooth")
	if not mat or mat:IsError() then
		mat = Material(path .. ".png", "smooth")
	end
	if not mat or mat:IsError() then
		mat = Material(string.lower(path), "smooth")
	end
	if not mat or mat:IsError() then
		mat = Material(string.lower(path) .. ".png", "smooth")
	end
	return mat
end

local state = {
	active = false,
	endTime = 0,
	material = nil
}

local function clearEffect()
	state.active = false
	state.endTime = 0
	state.material = nil
	timer.Remove("hg_aprilfools_tuff_end")
end

net.Receive("hg_aprilfools_tuff", function()
	if not aprilFoolsEnabled() then return end
	local soundPath = net.ReadString()
	local texturePath = net.ReadString()
	local duration = SoundDuration(soundPath)
	if not duration or duration <= 0 then
		duration = 8
	end

	state.active = true
	state.endTime = CurTime() + duration
	state.material = loadTuffMaterial(texturePath)

	surface.PlaySound(soundPath)

	timer.Remove("hg_aprilfools_tuff_end")
	timer.Create("hg_aprilfools_tuff_end", duration, 1, function()
		if not IsValid(LocalPlayer()) then return end
		net.Start("hg_aprilfools_tuff_done")
		net.SendToServer()
		clearEffect()
	end)
end)

hook.Add("HUDPaint", "hg-aprilfools-tuff", function()
	if not state.active then return end
	if state.endTime <= CurTime() then
		clearEffect()
		return
	end

	local sw, sh = ScrW(), ScrH()
	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(0, 0, sw, sh)

	if state.material and not state.material:IsError() then
		local size = ScreenScale(140)
		local x = sw * 0.5 - size * 0.5
		local y = sh * 0.68 - size * 0.5
		surface.SetMaterial(state.material)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x, y, size, size)
	end
end)

hook.Add("PlayerSpawn", "hg-aprilfools-tuff-clear", function(ply)
	if ply == LocalPlayer() then
		clearEffect()
	end
end)
