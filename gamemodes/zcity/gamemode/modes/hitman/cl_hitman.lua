local MODE = MODE

MODE.TargetPlayersLocal = MODE.TargetPlayersLocal or {}
MODE.TargetHintsLocal = MODE.TargetHintsLocal or {}
MODE.TargetsRemaining = MODE.TargetsRemaining or 0
MODE.TargetsInitial = MODE.TargetsInitial or 0

local roleStartTime = 0
local roleFade = 0
local hintMenuOpen = false
local hintMenuSlide = 0

net.Receive("HITMAN_RoundStart", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	ply.isTraitor = net.ReadBool()
	ply.isGunner = net.ReadBool()

	MODE.TargetPlayersLocal = {}
	MODE.TargetHintsLocal = {}
	MODE.TargetsRemaining = 0
	MODE.TargetsInitial = 0
	hintMenuOpen = false

	roleStartTime = CurTime()
	roleFade = 0
end)

net.Receive("HITMAN_TargetsUpdate", function()
	MODE.TargetPlayersLocal = {}
	MODE.TargetHintsLocal = {}
	local count = net.ReadUInt(6)
	for i = 1, count do
		MODE.TargetPlayersLocal[i] = net.ReadEntity()
		MODE.TargetHintsLocal[i] = net.ReadString()
	end
	MODE.TargetsRemaining = net.ReadUInt(6)
	MODE.TargetsInitial = net.ReadUInt(6)
end)

-- Hook to toggle the hint menu with 'T' (assuming standard spray/custom bind, but using standard key hook)
hook.Add("PlayerBindPress", "Hitman_HintToggle", function(ply, bind, pressed)
	if bind == "impulse 201" and pressed then -- T is usually impulse 201 (spray logo)
		local mode = CurrentRound()
		if mode and mode.name == "hitman" and ply.isTraitor then
			hintMenuOpen = not hintMenuOpen
			return true -- Block spray if we want to use T for this
		end
	end
end)

function MODE:PreDrawHalos()
	-- Removed target glowing as per request
end

-- Define a sharp, handwritten-style font for hints
surface.CreateFont("HitmanHintFont", {
	font = "Permanent Marker", -- Or "Coming Soon", "Architects Daughter" if available. Fallback "Trebuchet MS" usually works well as generic sans. 
    -- "Permanent Marker" is standard GMod font? No. Let's use "DermaLarge" or create a sharp one.
    -- User asked for "sharp" and "smaller".
    -- "BudgetLabel" is sharp/pixelated.
    -- Let's try "Trebuchet MS" or "Roboto" with antialias=false for "sharp" look, or just a clean font.
    -- The image description "like i showed in the photo" (which I can't see but user implies a specific style)
    -- typically implies a "sketchy" or "handwritten" look if it's hitman notes, OR a clean tactical HUD.
    -- "Hint Target Skin" in the user prompt "Hint Target skin [box]" suggests a hand-drawn note style maybe?
    -- User said "sharp". Let's go with a clean, sharp, smaller font.
	font = "Trebuchet MS",
	size = 20,
	weight = 800,
	antialias = true, -- Sharp usually means high contrast, but no-antialias looks jagged.
    outline = true, -- Outline makes it stand out? User said "outline blue". That's likely the box.
})

-- Define a title font
surface.CreateFont("HitmanHintTitle", {
	font = "Trebuchet MS",
	size = 24,
	weight = 1000,
	antialias = true,
})

function MODE:HUDPaint()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Team() == TEAM_SPECTATOR then return end

	local now = CurTime()
	local sw, sh = ScrW(), ScrH()
	
	if roleStartTime + 12 >= now then
		roleFade = Lerp(FrameTime() * 1, roleFade, math.Clamp(roleStartTime + 5 - now, -2, 2))

		draw.SimpleText("Hitman", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * roleFade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local roleName
		local roleColor
		local objective

		if ply.isTraitor then
			roleName = "the Hitman"
			roleColor = Color(190, 0, 0, 255 * roleFade)
			objective = "Eliminate your assigned targets. Press 'T' for hints."
		elseif ply.isGunner then
			roleName = "an Armed Bystander"
			roleColor = Color(158, 0, 190, 255 * roleFade)
			objective = "Stay alive and stop the hitman."
		else
			roleName = "a Bystander"
			roleColor = Color(0, 120, 190, 255 * roleFade)
			objective = "Stay alive and stop the hitman."
		end

		draw.SimpleText("You are " .. roleName, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, Color(roleColor.r, roleColor.g, roleColor.b, 255 * roleFade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if ply.isTraitor then
		-- draw.SimpleText("Targets remaining: " .. (MODE.TargetsRemaining or 0) .. "/" .. (MODE.TargetsInitial or 0), "ZB_HomicideMedium", ScrW() * 0.5, ScrH() * 0.1, Color(255, 60, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("[T] Target Hints", "ZB_HomicideMedium", ScrW() * 0.5, ScrH() * 0.13, Color(200, 200, 200, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		-- Hint Menu Slide Logic
		hintMenuSlide = Lerp(FrameTime() * 10, hintMenuSlide, hintMenuOpen and 1 or 0)
		
		if hintMenuSlide > 0.01 then
            -- Position: "on the corner" - assuming right corner sliding in
			local boxWidth = ScrW() * 0.15 -- Smaller width
			local boxHeight = ScrH() * 0.25
			local startX = ScrW()
			local endX = ScrW() - boxWidth - 30 -- Slight padding from edge
			
			local currentX = startX - ((startX - endX) * hintMenuSlide)
			local currentY = ScrH() * 0.4 -- Middle-ish right
			
            -- Draw Box with Blue Outline
            -- Background
			draw.RoundedBox(0, currentX, currentY, boxWidth, boxHeight, Color(0, 0, 0, 200)) -- Dark transparent background
            
            -- Blue Outline (Hollow Box)
            surface.SetDrawColor(0, 162, 255, 255) -- Blue color
            surface.DrawOutlinedRect(currentX, currentY, boxWidth, boxHeight, 2) -- 2px thickness
			
			draw.SimpleText("TARGET INTEL", "HitmanHintTitle", currentX + boxWidth/2, currentY + 10, Color(0, 162, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            -- Draw Divider Line
            surface.SetDrawColor(0, 162, 255, 100)
            surface.DrawLine(currentX + 10, currentY + 40, currentX + boxWidth - 10, currentY + 40)
			
			local yOffset = 50
			if MODE.TargetHintsLocal and #MODE.TargetHintsLocal > 0 then
				for i, hint in ipairs(MODE.TargetHintsLocal) do
                    -- Draw Hint Text
					draw.SimpleText("• " .. hint, "HitmanHintFont", currentX + 15, currentY + yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					yOffset = yOffset + 25
				end
			else
				draw.SimpleText("No active targets.", "HitmanHintFont", currentX + 15, currentY + yOffset, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
	end
end
