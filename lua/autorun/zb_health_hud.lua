--================================================================================
-- ZB Health HUD — FINAL VERSION WITH BLEEDING STATUS AND NEW EFFECTS
-- Features:
--   • Bleeding status for external wounds (neck cuts, arterial wounds)
--   • Internal bleeding status (from organ damage)
--   • Fixed stamina calculation using org.stamina[1] and org.stamina.max
--   • Consciousness hidden at >=90%
--   • Shared level backgrounds for pain/conscious/stamina
--   • Complete hiding of amputated limbs
--   • Recolored limb sprites: Gray → Orange → Red
--   • NEW: 13 additional status effects (Blood loss, Cardiac arrest, Temperature, Adrenaline, Shock, Trauma, etc.)
--   • NEW: Status descriptions appear when hovering over icons with C-menu open
--   • NEW: Language support (Russian/English) with hg_languagepopa command
--   • NEW: Death icon appears when player is dead (status_death.png)
--   • NEW: Berserk icon (status_berserk.png) and special behavior during berserk mode
--   • NEW: All limbs appear when any damage is taken, smoothly fade out when fully healed
--   • UPDATED: Removed arm fracture status, added amputation status (status_amputant.png)
--   • UPDATED: Merged arm and leg fractures into one "Fracture" status
--   • UPDATED: Berserk mode shows only specific statuses with unique descriptions
--   • UPDATED: English berserk texts use "Who asks Satan" font
--   • NEW: Alternative icons system with hg_nopixelicons command
--   • NEW: Developer parameters for alternative icon size adjustment (no console commands)
--================================================================================

if SERVER then
	-- Limb sprites
	local SPRITES = {
		"materials/vgui/hud/health_head.png",
		"materials/vgui/hud/health_torso.png",
		"materials/vgui/hud/health_right_arm.png",
		"materials/vgui/hud/health_left_arm.png",
		"materials/vgui/hud/health_right_leg.png",
		"materials/vgui/hud/health_left_leg.png",
	}
	
	-- Parameter icons
	local ICONS = {
		"materials/vgui/hud/bloodmeter.png",
		"materials/vgui/hud/pulsemeter.png",
		"materials/vgui/hud/assimilationmeter.png",
		"materials/vgui/hud/o2meter.png",
		"materials/vgui/hud/o2meter_alt.png",
	}
	
	local STATUS_SPRITES = {
		"materials/vgui/hud/status_level1_bg.png",   
		"materials/vgui/hud/status_level2_bg.png",   
		"materials/vgui/hud/status_level3_bg.png",   
		"materials/vgui/hud/status_level4_bg.png",   
		
		"materials/vgui/hud/status_background.png",
		
		"materials/vgui/hud/status_pain_icon.png",
		"materials/vgui/hud/status_conscious_icon.png",
		"materials/vgui/hud/status_stamina_icon.png",
		"materials/vgui/hud/status_bleeding_icon.png",
		"materials/vgui/hud/status_internal_bleed_icon.png",
		"materials/vgui/hud/status_organ_damage.png",
		"materials/vgui/hud/status_dislocation.png",
		"materials/vgui/hud/status_spine_fracture.png",
		"materials/vgui/hud/status_leg_fracture.png",
		
		"materials/vgui/hud/status_blood_loss.png",      
		"materials/vgui/hud/status_cardiac_arrest.png",  
		"materials/vgui/hud/status_cold.png",            
		"materials/vgui/hud/status_heat.png",            
		"materials/vgui/hud/status_hemothorax.png",      
		"materials/vgui/hud/status_lungs_failure.png",   
		"materials/vgui/hud/status_overdose.png",        
		"materials/vgui/hud/status_oxygen.png",          
		"materials/vgui/hud/status_vomit.png",           
		"materials/vgui/hud/status_brain_damage.png",
		
		"materials/vgui/hud/status_adrenaline.png",
		"materials/vgui/hud/status_shock.png",
		"materials/vgui/hud/status_trauma.png",
		
		"materials/vgui/hud/status_death.png",
		"materials/vgui/hud/status_berserk.png",
		"materials/vgui/hud/status_amputant.png",
		
		-- Alternative icons
		"materials/vgui/hud/status_adrenalinealt.png",
		"materials/vgui/hud/status_amputantalt.png",
		"materials/vgui/hud/status_backgroundalt.png",
		"materials/vgui/hud/status_berserkalt.png",
		"materials/vgui/hud/status_bleeding_iconalt.png",
		"materials/vgui/hud/status_blood_lossalt.png",
		"materials/vgui/hud/status_brain_damagealt.png",
		"materials/vgui/hud/status_cardiac_arrestalt.png",
		"materials/vgui/hud/status_coldalt.png",
		"materials/vgui/hud/status_conscious_iconalt.png",
		"materials/vgui/hud/status_deathalt.png",
		"materials/vgui/hud/status_dislocationalt.png",
		"materials/vgui/hud/status_heatalt.png",
		"materials/vgui/hud/status_hemothoraxalt.png",
		"materials/vgui/hud/status_internal_bleed_iconalt.png",
		"materials/vgui/hud/status_leg_fracturealt.png",
		"materials/vgui/hud/status_level1_bgalt.png",
		"materials/vgui/hud/status_level2_bgalt.png",
		"materials/vgui/hud/status_level3_bgalt.png",
		"materials/vgui/hud/status_level4_bgalt.png",
		"materials/vgui/hud/status_lungs_failurealt.png",
		"materials/vgui/hud/status_organ_damagealt.png",
		"materials/vgui/hud/status_overdosealt.png",
		"materials/vgui/hud/status_oxygenalt.png",
		"materials/vgui/hud/status_pain_iconalt.png",
		"materials/vgui/hud/status_shockalt.png",
		"materials/vgui/hud/status_spine_fracturealt.png",
		"materials/vgui/hud/status_stamina_iconalt.png",
		"materials/vgui/hud/status_traumaalt.png",
		"materials/vgui/hud/status_vomitalt.png",
	}
	
	for _, path in ipairs(SPRITES) do resource.AddFile(path) end
	for _, path in ipairs(ICONS) do resource.AddFile(path) end
	for _, path in ipairs(STATUS_SPRITES) do resource.AddFile(path) end
	
	AddCSLuaFile("autorun/zb_health_hud.lua")
	
	hook.Add("Initialize", "ZB_HealthHUD_ServerInit", function()
	end)
	
	return
end

--================================================================================
-- CLIENT SIDE (WITH BLEEDING STATUS AND NEW EFFECTS)
--================================================================================

-- CRITICAL FIX: Added math.sin to local variables!
local math_min, math_max, math_floor, math_sin = math.min, math.max, math.floor, math.sin
local Color = Color
local draw_SimpleText = draw.SimpleText
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local ScrW, ScrH = ScrW, ScrH
local FrameTime = FrameTime
local Lerp = Lerp
local CurTime = CurTime
local gui = gui

-- Language setting (default: English)
local LANGUAGE = "en" -- "ru" for Russian, "en" for English

-- Alternative icons setting (default: false = normal icons)
local USE_ALT_ICONS = false

--================================================================================
-- DEVELOPER SETTINGS - Alternative icon size adjustment
-- Modify these values to change the size of alternative icons
-- These are for developer use only and have no console commands
--================================================================================
local ALT_ICON_SETTINGS = {
	-- Main size multiplier for all alternative icons
	-- 1.0 = normal size, 0.8 = 80% size, 1.2 = 120% size
	size_multiplier = 0.85, -- Slightly smaller than default
	
	-- Individual icon size overrides (uncomment and modify as needed)
	-- If set to nil, uses size_multiplier
	-- individual = {
	--     adrenaline = 0.9,
	--     amputant = 0.8,
	--     berserk = 1.1,
	--     death = 0.95,
	--     brain_damage = 0.85,
	-- },
	
	-- Background size multiplier (for level backgrounds)
	background_multiplier = 0.85,
	
	-- Padding adjustment (how much space around the icon)
	-- Negative values make icons closer to the edge
	padding_offset = -1, -- Slightly less padding for smaller icons
}

-- Safe value getter
local function getOrgVal(org, key, def)
	local v = org[key]
	return type(v) == "number" and v or (def or 0)
end

-- Get nested table value (e.g., org.stamina[1])
local function getOrgTableVal(org, tbl, key, index, def)
	if not org[tbl] or type(org[tbl]) ~= "table" then return def or 0 end
	local val = org[tbl][key]
	if index and type(val) == "table" then
		val = val[index]
	end
	return type(val) == "number" and val or (def or 0)
end

-- Get O2 value from org.o2 table
local function getO2Value(org)
	if not org.o2 then return 30 end
	if type(org.o2) == "table" then
		return org.o2[1] or 30
	end
	return type(org.o2) == "number" and org.o2 or 30
end

-- Get O2 max value
local function getO2Max(org)
	if not org.o2 then return 30 end
	if type(org.o2) == "table" then
		return org.o2.range or 30
	end
	return 30
end

-- Check if player is dead
local function isPlayerDead(ply)
	if not IsValid(ply) then return true end
	if not ply:Alive() then return true end
	local org = ply.organism
	if org and org.alive == false then return true end
	return false
end

-- Check if berserk is active
local function isBerserkActive(org)
	return org and org.berserkActive2 == true
end

-- Color interpolation
local function lerpCol(ratio, from, to)
	ratio = math_min(math_max(ratio, 0), 1)
	return Color(
		math_floor((from.r or 0) + ((to.r or 0) - (from.r or 0)) * ratio),
		math_floor((from.g or 0) + ((to.g or 0) - (from.g or 0)) * ratio),
		math_floor((from.b or 0) + ((to.b or 0) - (from.b or 0)) * ratio),
		255
	)
end

-- NEW: Limb color scheme (Gray → Orange → Red)
local function getLimbColor(damage)
	local ratio = math_min(math_max(damage, 0), 1)
	if ratio <= 0.3 then return Color(128, 128, 128, 255)    -- Gray = healthy
	elseif ratio <= 0.6 then return Color(255, 165, 0, 255)  -- Orange = moderate
	else return Color(255, 0, 0, 255) end                    -- Red = severe
end

-- NEW: Check if any limb is damaged
local function hasAnyLimbDamage(org)
	return (getOrgVal(org, "skull", 0) > 0.01 or
			getOrgVal(org, "jaw", 0) > 0.01 or
			getOrgVal(org, "chest", 0) > 0.01 or
			getOrgVal(org, "spine1", 0) > 0.01 or
			getOrgVal(org, "spine2", 0) > 0.01 or
			getOrgVal(org, "spine3", 0) > 0.01 or
			getOrgVal(org, "pelvis", 0) > 0.01 or
			getOrgVal(org, "rarm", 0) > 0.01 or
			getOrgVal(org, "larm", 0) > 0.01 or
			getOrgVal(org, "rleg", 0) > 0.01 or
			getOrgVal(org, "lleg", 0) > 0.01)
end

-- Check if any limb is amputated
local function hasAnyAmputation(org)
	return org.llegamputated == true or 
		   org.rlegamputated == true or 
		   org.larmamputated == true or 
		   org.rarmamputated == true
end

-- Check if any limb is fractured (arm or leg)
local function hasAnyFracture(org, threshold)
	threshold = threshold or 0.95
	
	local lleg = getOrgVal(org, "lleg", 0)
	local rleg = getOrgVal(org, "rleg", 0)
	local larm = getOrgVal(org, "larm", 0)
	local rarm = getOrgVal(org, "rarm", 0)
	
	return (lleg >= threshold and not org.llegamputated) or
		   (rleg >= threshold and not org.rlegamputated) or
		   (larm >= threshold and not org.larmamputated) or
		   (rarm >= threshold and not org.rarmamputated)
end

-- ===== CONFIGURATION =====
local HUD = {
	enabled = true,
	bar_y = 4440,
	bar_scale = 0,
	base_x = nil,
	base_y = 60,
	use_alt_icons = false,
	
	limb_offsets = {
		head =        { x = 55,   y = -15 },
		torso =       { x = 54	,   y = 33 },
		right_arm =   { x = 83,  y = 36 },
		left_arm =    { x = 24, y = 38 },
		right_leg =   { x = 66,  y = 92 },
		left_leg =    { x = 35, y = 106 },
	},
	
	limb_scale = {
		head =        { w = 1, h = 1 },
		torso =       { w = 1.4, h = 1.8 },
		right_arm =   { w = 1, h = 2 },
		left_arm =    { w = 1, h = 2 },
		right_leg =   { w = 1.2, h = 3.5 },
		left_leg =    { w = 1.2, h = 2.7 },
	},
	
	sprite_visibility = 100,
	always_show_limbs = false, -- Changed to false by default - limbs hide when healed
	smooth = 0.35,
	show_damage_percent = false,
	
	blood_hide_threshold = 4500,
	pulse_hide_min = 60,
	pulse_hide_max = 100,
	stable_time = 15,
	
	status_effects_x = -10,
	status_effects_y = 220,
	status_effects_spacing = 55,
	status_effects_size = 58,
	show_status_effects = true,
	
	organ_damage_threshold = 0.3,
	fracture_threshold = 0.95,
	
	-- Bleeding thresholds
	bleeding_threshold = 0.1,
	internal_bleed_threshold = 0.1,
	
	-- NEW: Thresholds for additional status effects
	blood_loss_threshold = 4700,        -- Show blood loss icon when blood < 3000
	cardiac_arrest_threshold = true,    -- Show when heartstop = true
	cold_threshold = 36,                 -- Show when temperature < 36°C
	heat_threshold = 37,                  -- Show when temperature > 37°C
	hemothorax_threshold = 0.01,          -- Show when pneumothorax > 0
	oxygen_threshold = 28,                 -- Show when o2 < 25
	vomit_threshold = 0.2,                 -- Show when wantToVomit > 0.5
	brain_damage_threshold = 0.01,         -- Show when brain damage > 0
	
	-- NEW: Thresholds for additional 3 status effects
	adrenaline_threshold = 0.3,           -- Show when adrenaline > 1.5
	shock_threshold = 20,                  -- Show when shock > 20
	trauma_threshold = 0.2,                -- Show when disorientation > 0.5
	
	-- NEW: Limb damage thresholds
	limb_damage_threshold = 0.01,          -- Show limb when damage > this value
	limb_fade_speed = 3.0,                  -- Speed of fade in/out (higher = faster)
}

-- Material cache
local sprites = {}
local icons = {}
local status_sprites = {
	level_backgrounds = {nil, nil, nil, nil},
	background = nil,
	pain_icon = nil,
	conscious_icon = nil,
	stamina_icon = nil,
	bleeding_icon = nil,
	internal_bleed_icon = nil,
	organ_damage = nil,
	dislocation = nil,
	spine_fracture = nil,
	fracture = nil, -- Combined fracture (using leg_fracture icon)
	
	-- NEW status icons (first 10)
	blood_loss = nil,
	cardiac_arrest = nil,
	cold = nil,
	heat = nil,
	hemothorax = nil,
	lungs_failure = nil,
	overdose = nil,
	oxygen = nil,
	vomit = nil,
	brain_damage = nil,
	
	-- NEW status icons (additional 3)
	adrenaline = nil,
	shock = nil,
	trauma = nil,
	
	-- NEW: Death, Berserk and Amputation icons
	death = nil,
	berserk = nil,
	amputant = nil,
}
local status_sprites_loaded = false
local debug_done = false
local statusEffectAppearance = {}
local statusEffectPositions = {}
local tooltipHoverTime = {}
local lastHoveredStatus = nil

-- Smoothed values (added new ones)
local smooth = {
	blood = 5000,
	conscious = 1.0,
	pain = 0,
	pulse = 70,
	assimilation = 0,
	o2 = 30,
	bleed = 0,
	internalBleed = 0,
	
	-- NEW smoothed values
	temperature = 36.7,
	pneumothorax = 0,
	analgesia = 0,
	brain = 0,
	wantToVomit = 0,
	
	-- Additional smoothed values
	adrenaline = 0,
	shock = 0,
	disorientation = 0,
}

-- NEW: Limb fade states for smooth transitions
local limbFadeStates = {
	head = {alpha = 0, target = 0},
	torso = {alpha = 0, target = 0},
	right_arm = {alpha = 0, target = 0},
	left_arm = {alpha = 0, target = 0},
	right_leg = {alpha = 0, target = 0},
	left_leg = {alpha = 0, target = 0},
}

-- NEW: Track if limbs have been revealed
local limbsRevealed = false

-- Stability tracking
local stability = {
	blood = {last_value = 5000, last_change = 0, hidden = false},
	pulse = {last_value = 70, last_change = 0, hidden = false},
}

local function isContextMenuOpen()
    local menu = g_ContextMenu
    if not menu then return false end
    
    if menu.Visible then return true end
    if menu:IsVisible() then return true end
    
    local hovered = vgui.GetHoveredPanel()
    if hovered and (hovered:GetName() == "ContextMenu" or (hovered:GetParent() and hovered:GetParent():GetName() == "ContextMenu")) then
        return true
    end
    
    return false
end

--================================================================================
-- LANGUAGE SUPPORT: Tooltip texts in Russian and English
--================================================================================

local tooltipTexts = {
	ru = {
		pain = {
			[4] = "Agony - Unbearable pain. Movement is limited. Death sounds tempting now.",
			[3] = "Severe Pain - Semi-conscious, mind clouded by severe pain.",
			[2] = "Pain - Quite severe pain.",
			[1] = "Slight pain - A slight pain is felt."
		},
		bleeding = "Bleeding - Blood pours from a relatively large wound. This is unlikely to be fatal if you are otherwise healthy.",
		internal_bleed = "Internal bleeding - As it turns out, your intestines and lungs are definitely NOT the place for your blood. Treatment is highly recommended.",
		conscious = {
			[4] = "Unconscious - No response to any external stimuli. You're out cold.",
			[3] = "Fainting - Barely conscious, feeling like you could fall at any moment.",
			[2] = "Confused - Feeling confused and dizzy, difficulty perceiving the world around you.",
			[1] = "Confused - Slightly disoriented with slight dizziness."
		},
		stamina = {
			[4] = "Completely exhausted - barely able to breathe.",
			[3] = "I'm out of breath - I can barely move.",
			[2] = "Exhausted - You feel discomfort and fatigue, and find it difficult to move and work.",
			[1] = "Slightly tired - Minor physical exertion."
		},
		spine_fracture = "Broken spine - The spine is broken. If the spinal cord isn't severed, consider it lucky.",
		fracture = "Limb Fracture - You have a broken arm or leg. Movement of the injured limb is difficult and causes severe pain.",
		organ_damage = "Organ Damage - The organs inside you are not feeling well.",
		dislocation = "Joint Dislocation - You've dislocated a limb. Try not to use the injured limb and find a way to realign it.",
		amputant = "Amputee - One of your limbs was severed. Traumatic. You permanently lost the use of the severed limb.",
		blood_loss = {
			[4] = "Exsanguinated - Life-threatening loss of blood. Anything more and the heart will stop. Death is inevitable.",
			[3] = "Critical hypovolemia - Severe blood loss. Semiconscious. Your vision is blurred... Treatment is needed.",
			[2] = "Hypovolemia - Weakness and disorientation due to blood loss. You feel very unwell. Treatment is recommended.",
			[1] = "Pale - Minor blood loss. Blood pressure is low. You feel slightly weak, your skin is pale."
		},
		cardiac_arrest = "Cardiac arrest - Your heart has stopped beating, meaning oxygen is no longer reaching your brain.",
		cold = {
			[4] = "Freezing to Death - For some unknown reason, you become warm...",
			[3] = "Hypothermia - A dangerously low temperature that causes the body and mind to become exhausted from the cold.",
			[2] = "Cold - Uncomfortably cold. Your body slows down.",
			[1] = "Cool - A little cool for comfort."
		},
		heat = {
			[4] = "Heat stroke - Your body clearly won't last long in this heat.",
			[3] = "Hyperthermia - Dangerously hot. You're having trouble tolerating the heat...",
			[2] = "Hot - Uncomfortably hot.",
			[1] = "Тепло - Немного жарковато для комфорта."
		},
		hemothorax = {
			[4] = "Критический гемоторакс - Лёгкие пытаются зачерпнуть хоть каплю кислорода, но всё четно... Спокойной ночи.",
			[3] = "Сильнейший гемоторакс - Грудная клетка очень сильно болит. Кровь уже заполнила лёгкие больше, чем на половину.",
			[2] = "Серьёзный гемоторакс - Кровь скопилась до такого уровня, что дышать стало труднее.",
			[1] = "Гемоторакс - В плевральной полости скапливается кровь из-за внутреннего кровотечения или прокола лёгких. У тебя болит грудь... Требуется лечение."
		},
		lungs_failure = "Отказ лёгких - лёгкие перестали работать в связи с повреждением, долгим отсутсвием цикла дыхания или по другой причине.",
		overdose = {
			[4] = "Фатальная передозировка - Дыхательная недостаточность. Ты покидаешь этот мир в состоянии эйфории, вызванной наркотиками, но тебе уже глубоко наплевать.",
			[3] = "Передозировка - Дышать тяжело, в голове царит эйфория. Это определенно плохо для организма. Если бы только это могло длиться вечно...",
			[2] = "Средняя доза - Очень расслаблен и спокоен, но легкие ощущаются тяжелыми. Устаешь немного быстрее обычного. Чувствуешь себя отлично, пока что...",
			[1] = "Доза - Расслаблен и спокоен. Тело чувствуется онемевшим."
		},
		oxygen = {
			[4] = "Аноксемия - Мозг отмирает от кислородного голодания. Весь организм стремительно отказывает. Смерть неизбежна.",
			[3] = "Асфиксия - Теряешь сознание. Ткани лишены кислорода.",
			[2] = "Сильная гипоксемия - Недостаточно кислорода в организме. Головокружение и онемение конечностей. Что-то ЯВНО не так.",
			[1] = "Гипоксемия - Понижен уровень кислорода в крови. Немного запутан, кожа вялая. Что-то не так..."
		},
		vomit = {
			[4] = "Ужасная тошнота - Опасная тошнота. Внутри что-то ОЧЕНЬ не так.",
			[3] = "Сильная тошнота - Сильный дискомфорт. Сильная склонность к рвоте.",
			[2] = "Тошнота - Дискомфорт в области желудка. Склонность к рвоте.",
			[1] = "Подташнивает - Чувствуешь дискомфорт. Немного плохо. Небольшая склонность к рвоте."
		},
		brain_damage = {
			[4] = "Кома - Едва цепляясь за жизнь, ты страдаешь от cильнейшего повреждения мозга. Ты - овощ. Восстановление маловероятно.",
			[3] = "Тяжелое нейрофизиологическое ухудшение - Сильно умственно отстал, едва способный мыслить разумно и оставаться в сознании. Серьёзная мозговая травма",
			[2] = "Неврологические повреждения - Тяжелый ментальный дефицит. Ограничена способность к интеллектуальному мышлению и самодостаточности. Серьезные повреждения головного мозга.",
			[1] = "Когнитивные нарушения - Психические расстройства вследствие повреждения головного мозга. Ты чувствуешь странную растерянность..."
		},
		adrenaline = {
			[4] = "Адреналин - Сердце работает на износ качая кровь. Практически полное отсутствие боли, прилив сил, и увеличенная стойкость.",
			[3] = "Адреналин - Почти не чувствуешь боль. Выносливость увеличилась в разы.",
			[2] = "Адреналин - Боль притупилась. Состояние повышенной готовности",
			[1] = "Адреналин - Ты чувствуешь небольшой прилив сил."
		},
		shock = {
			[4] = "Шок - Организм включает самый лучший защитный механизм, чтобы справится с этой болью. Сладких снов.",
			[3] = "Шок - Сильнейшая боль в твоей жизни туманит разум и рассудок делая из тебя животное.",
			[2] = "Шок - Агонизирующая боль прорезает каждую клеточку твоего тела.",
			[1] = "Шок - Входишь в состояние шока"
		},
		trauma = {
			[4] = "Контужен - Ужас и Беспомощность.",
			[3] = "Сильная дезориентация - Звон в ушах и мир, как на карусели.",
			[2] = "Серьёзная дезориентация - Голова кружится и всё кругом плывёт.",
			[1] = "Лёгкая дезориентация - Чувствуешь себя сонным."
		},
		death = "Смерть - Пермаментная и грустная или весёлая, а впрочем уже не важно.",
		berserk = {
			[4] = "Берсерк - Невообразимая сила, регенерация, и стойкость. Ты машина для убийств.",
			[3] = "Берсерк - Невообразимая сила, регенерация, и стойкость. Ты машина для убийств.",
			[2] = "Берсерк - Невообразимая сила, регенерация, и стойкость. Ты машина для убийств.",
			[1] = "Берсерк - Невообразимая сила, регенерация, и стойкость. Ты машина для убийств."
		},
		-- Уникальные описания для статусов в режиме берсерка
		berserk_brain_damage = "Повреждение мозга - ЧУТЬ ЧУТЬ ОТЛЕЖУСЬ И НОРМАЛЬНО.",
		berserk_fracture = "Перелом - МНЕ РАЗВЕ ДОЛЖНО БЫТЬ НЕ БОЛЬНО... А ПОХУЙ ВООБЩЕМ.",
		berserk_dislocation = "Вывих - ДА КОГО ОН ЁБЕТ ВООБЩЕ.",
		berserk_adrenaline = "Адреналин - ПРИЯТНЫЙ БОНУС.",
		berserk_oxygen = "Кислородное голодание - ОДНА ВЕЩЬ, КОТОРАЯ МЕНЯ ПУГАЕТ.",
		berserk_trauma = "Дезориентация - ЭТО ОЧЕНЬ ЗАВОРАЖИВАЕТ.",
		berserk_amputant = "Ампутант - МЕНЯ ЭТО ДОЛЖНО ОСТАНОВИТЬ?",
		berserk_cardiac_arrest = "Остановка сердца - ЭТО УЖЕ ЗВУЧИТ НЕ ТАК КРУТО.",
		berserk_lungs_failure = "Отказ лёгких - ЭТО УЖЕ ЗВУЧИТ НЕ ТАК КРУТО.",
	},
	
	en = {
		pain = {
			[4] = "Agony - Unbearable pain. Movement is limited. Death sounds tempting right now.",
			[3] = "Severe pain - Semi-conscious, mind clouded by intense pain.",
			[2] = "Pain - Quite severe pain.",
			[1] = "Mild pain - Slight pain is felt."
		},
		bleeding = "Bleeding - Blood is flowing from a relatively large wound. It's unlikely to be fatal if you're completely healthy.",
		internal_bleed = "Internal bleeding - As it turns out, your intestines and lungs are definitely NOT the place for your blood. Treatment is highly recommended.",
		conscious = {
			[4] = "Unconscious - No reaction to any external stimuli. You're out cold.",
			[3] = "Fainting - Barely conscious, feeling like you could fall at any moment.",
			[2] = "Confused - Feeling of confusion and dizziness, difficulty perceiving the world around you.",
			[1] = "Disoriented - Slightly disoriented with mild dizziness."
		},
		stamina = {
			[4] = "Completely exhausted - Barely able to breathe.",
			[3] = "Very exhausted - Practically unable to move.",
			[2] = "Exhausted - Experiencing discomfort and fatigue, difficulty moving and working.",
			[1] = "Slightly tired - Minor physical strain."
		},
		spine_fracture = "Spine fracture - Broken spine. If the spinal cord isn't severed, consider yourself lucky.",
		fracture = "Limb fracture - You have a broken arm or leg. Movement with the injured limb is difficult and causes severe pain.",
		organ_damage = "Organ damage - The organs inside you don't feel well.",
		dislocation = "Joint dislocation - You've dislocated a limb. Try not to use the injured limb and find a way to reset it.",
		amputant = "Amputation - A limb has been amputated. You will never be able to use it again.",
		blood_loss = {
			[4] = "Exsanguination - Blood loss threatens your life. A little more and your heart will stop. Death is inevitable.",
			[3] = "Critical hypovolemia - Severe blood loss. Semi-conscious. You see blurry... Treatment needed.",
			[2] = "Hypovolemia - Weakness and disorientation due to blood loss. You feel very unwell. Treatment recommended.",
			[1] = "Pale - Minor blood loss. Blood pressure is low. You feel slight weakness, skin is pale."
		},
		cardiac_arrest = "Cardiac arrest - Your heart has stopped beating, which means oxygen no longer reaches your brain.",
		cold = {
			[4] = "Freezing to death - For some unknown reason, you're feeling warm... Good night.",
			[3] = "Hypothermia - Dangerously low temperature, body and mind exhausted from cold. The whole body is gradually failing.",
			[2] = "Cold - Unpleasantly cold. Your body is slowing down.",
			[1] = "Chilly - A bit chilly for comfort."
		},
		heat = {
			[4] = "Heat stroke - Brain cells are starting to die from intense heat.",
			[3] = "Hyperthermia - Dangerously hot. It's hard for you to bear the heat...",
			[2] = "Hot - Unpleasantly hot.",
			[1] = "Warm - A bit too warm for comfort."
		},
		hemothorax = {
			[4] = "Critical hemothorax - Your lungs are trying to grasp at least a drop of oxygen, but it's hopeless... Good night.",
			[3] = "Severe hemothorax - Your chest is about to explode, and blood has already filled more than half of your lungs.",
			[2] = "Serious hemothorax - Blood has accumulated to the point where breathing has become difficult.",
			[1] = "Hemothorax - Blood is accumulating in the pleural cavity due to internal bleeding or lung puncture. Your chest hurts... Treatment required."
		},
		lungs_failure = "Lung failure - Lungs have stopped working due to damage or prolonged absence of breathing cycle.",
		overdose = {
			[4] = "Fatal overdose - Respiratory failure. You're leaving this world in a drug-induced euphoria, but you couldn't care less.",
			[3] = "Overdose - Breathing is hard, euphoria reigns in your head. This is definitely bad for the body. If only this could last forever...",
			[2] = "Moderate dose - Very relaxed and calm, but your lungs feel heavy. You tire a bit faster than usual. You feel great, for now...",
			[1] = "Dose - Relaxed and calm. Your body feels numb."
		},
		oxygen = {
			[4] = "Anoxemia - Your brain is dying from oxygen starvation. The whole body is rapidly failing. Death is inevitable.",
			[3] = "Asphyxia - You're losing consciousness. Tissues are deprived of oxygen. Inevitable brain damage.",
			[2] = "Severe hypoxemia - Insufficient oxygen in the body. Dizziness and numbness in extremities. Something is DEFINITELY wrong.",
			[1] = "Hypoxemia - Low blood oxygen level. Slightly confused, skin is sluggish. Something's not right..."
		},
		vomit = {
			[4] = "Terrible nausea - Dangerous nausea. Something is VERY wrong inside.",
			[3] = "Severe nausea - Severe discomfort. Strong tendency to vomit.",
			[2] = "Nausea - Discomfort in the stomach area. Tendency to vomit.",
			[1] = "Queasy - You feel discomfort. Slightly unwell. Slight tendency to vomit."
		},
		brain_damage = {
			[4] = "Coma - Barely clinging to life, you suffer from severe brain damage. You're a vegetable. Recovery is unlikely.",
			[3] = "Severe neurophysiological deterioration - Severely mentally impaired, barely able to think rationally and remain conscious. Serious brain injury.",
			[2] = "Neurological damage - Severe mental deficit. Limited ability for intellectual thinking and self-sufficiency. Serious brain damage.",
			[1] = "Cognitive impairment - Mental disorders due to brain damage. You feel strange confusion..."
		},
		adrenaline = {
			[4] = "Adrenaline - Heart working overtime pumping blood. Almost complete absence of pain, surge of strength, and increased resilience.",
			[3] = "Adrenaline - Almost no pain felt. Stamina increased dramatically.",
			[2] = "Adrenaline - Pain dulled. State of heightened alertness.",
			[1] = "Adrenaline - You feel a slight surge of strength."
		},
		shock = {
			[4] = "Shock - Your body activates the best defense mechanism to cope with this pain. Sweet dreams.",
			[3] = "Shock - The most intense pain of your life clouds your mind and reason, turning you into an animal.",
			[2] = "Shock - Agonizing pain cuts through every cell of your body.",
			[1] = "Shock - Entering a state of shock"
		},
		trauma = {
			[4] = "Shell-shocked - Terror. Helplessness.",
			[3] = "Severe disorientation - Ringing in ears and the world like a carousel.",
			[2] = "Serious disorientation - Head spinning and everything floating around.",
			[1] = "Mild disorientation - Feeling sleepy."
		},
		death = "Death - You are dead. Observe what's happening.",
		berserk = {
			[4] = "Berserk - Unimaginable strength, regeneration, and resilience. You are a killing machine.",
			[3] = "Berserk - Unimaginable strength, regeneration, and resilience. You are a killing machine.",
			[2] = "Berserk - Unimaginable strength, regeneration, and resilience. You are a killing machine.",
			[1] = "Berserk - Unimaginable strength, regeneration, and resilience. You are a killing machine."
		},
		-- Unique descriptions for statuses in berserk mode (using "Who asks Satan" font style)
		berserk_brain_damage = "Brain damage - Even in rage, your damaged brain affects you.",
		berserk_fracture = "Fracture - Adrenaline numbs the pain, but the bone is still broken.",
		berserk_dislocation = "Dislocation - The joint is out of place, but rage allows you to ignore it.",
		berserk_adrenaline = "Adrenaline - Your body is working at its limit.",
		berserk_oxygen = "Oxygen deprivation - Your brain lacks oxygen, even in berserk mode.",
		berserk_trauma = "Disorientation - The world is spinning, but rage drives you forward.",
		berserk_amputant = "Amputation - The limb is gone, but nothing will stop you.",
		berserk_cardiac_arrest = "Cardiac arrest - You are already dead, but rage still drives you.",
		berserk_lungs_failure = "Lung failure - No air to breathe, but berserk won't let you fall.",
	}
}

--================================================================================
-- HELPER FUNCTION: Get tooltip text for a status (with language support)
--================================================================================
local function getTooltipText(statusName, pos, berserkActive)
	local lang = LANGUAGE
	local texts = tooltipTexts[lang] or tooltipTexts.ru
	
	if berserkActive then
		local berserkKey = "berserk_" .. statusName
		if texts[berserkKey] then
			return texts[berserkKey]
		end
	end
	
	if statusName == "pain" or statusName == "conscious" or statusName == "stamina" or 
	   statusName == "blood_loss" or statusName == "cold" or statusName == "heat" or
	   statusName == "hemothorax" or statusName == "overdose" or statusName == "oxygen" or
	   statusName == "vomit" or statusName == "brain_damage" or statusName == "adrenaline" or
	   statusName == "shock" or statusName == "trauma" or statusName == "berserk" then
		
		local levelTexts = texts[statusName]
		if levelTexts and type(levelTexts) == "table" then
			return levelTexts[pos.level_num] or levelTexts[1] or ""
		end
	else
		-- Simple status without levels
		return texts[statusName] or ""
	end
	
	return ""
end

--================================================================================
-- LOAD PARAMETER ICONS
--================================================================================
local function load_icons()
	if icons.loaded and icons.alt == HUD.use_alt_icons then return end
	icons.loaded = true
	icons.alt = HUD.use_alt_icons
	
	local fixed_icons = {
		blood = "vgui/hud/bloodmeter.png",
		pulse = "vgui/hud/pulsemeter.png",
		assimilation = "vgui/hud/assimilationmeter.png",
	}
	
	local suffix = HUD.use_alt_icons and "_alt" or ""
	local dynamic_icons = {
		o2 = "vgui/hud/o2meter" .. suffix .. ".png",
	}
	
	for name, path in pairs(fixed_icons) do
		local mat = Material(path, "smooth")
		icons[name] = (mat and not mat:IsError()) and mat or false
	end
	
	for name, path in pairs(dynamic_icons) do
		local mat = Material(path, "smooth")
		icons[name] = (mat and not mat:IsError()) and mat or false
	end
end

--================================================================================
-- LOAD STATUS EFFECT SPRITES (INCLUDING BLEEDING AND NEW EFFECTS)
--================================================================================
local function load_status_sprites()
	if status_sprites_loaded and icons.alt == USE_ALT_ICONS then return end
	status_sprites_loaded = true
	icons.alt = USE_ALT_ICONS
	
	local suffix = USE_ALT_ICONS and "alt" or ""
	
	-- Helper function to load material with optional suffix
	local function loadMaterial(basePath, suffix)
		local path = basePath
		if suffix ~= "" then
			-- Insert 'alt' before file extension
			local dotPos = string.find(path, ".png")
			if dotPos then
				path = string.sub(path, 1, dotPos - 1) .. suffix .. string.sub(path, dotPos)
			end
		end
		local mat = Material(path, "smooth")
		return (mat and not mat:IsError()) and mat or nil
	end
	
	-- Load 4 shared level backgrounds for ALL leveled statuses
	for i = 1, 4 do
		status_sprites.level_backgrounds[i] = loadMaterial("vgui/hud/status_level" .. i .. "_bg.png", suffix)
	end
	
	-- Base background for non-leveled statuses
	status_sprites.background = loadMaterial("vgui/hud/status_background.png", suffix)
	
	-- Status icons (existing)
	status_sprites.pain_icon = loadMaterial("vgui/hud/status_pain_icon.png", suffix)
	status_sprites.conscious_icon = loadMaterial("vgui/hud/status_conscious_icon.png", suffix)
	status_sprites.stamina_icon = loadMaterial("vgui/hud/status_stamina_icon.png", suffix)
	status_sprites.bleeding_icon = loadMaterial("vgui/hud/status_bleeding_icon.png", suffix)
	status_sprites.internal_bleed_icon = loadMaterial("vgui/hud/status_internal_bleed_icon.png", suffix)
	status_sprites.organ_damage = loadMaterial("vgui/hud/status_organ_damage.png", suffix)
	status_sprites.dislocation = loadMaterial("vgui/hud/status_dislocation.png", suffix)
	status_sprites.spine_fracture = loadMaterial("vgui/hud/status_spine_fracture.png", suffix)
	status_sprites.fracture = loadMaterial("vgui/hud/status_leg_fracture.png", suffix) -- Using leg_fracture icon for combined fracture
	
	-- NEW status icons (first 10)
	status_sprites.blood_loss = loadMaterial("vgui/hud/status_blood_loss.png", suffix)
	status_sprites.cardiac_arrest = loadMaterial("vgui/hud/status_cardiac_arrest.png", suffix)
	status_sprites.cold = loadMaterial("vgui/hud/status_cold.png", suffix)
	status_sprites.heat = loadMaterial("vgui/hud/status_heat.png", suffix)
	status_sprites.hemothorax = loadMaterial("vgui/hud/status_hemothorax.png", suffix)
	status_sprites.lungs_failure = loadMaterial("vgui/hud/status_lungs_failure.png", suffix)
	status_sprites.overdose = loadMaterial("vgui/hud/status_overdose.png", suffix)
	status_sprites.oxygen = loadMaterial("vgui/hud/status_oxygen.png", suffix)
	status_sprites.vomit = loadMaterial("vgui/hud/status_vomit.png", suffix)
	status_sprites.brain_damage = loadMaterial("vgui/hud/status_brain_damage.png", suffix)
	
	-- NEW status icons (additional 3)
	status_sprites.adrenaline = loadMaterial("vgui/hud/status_adrenaline.png", suffix)
	status_sprites.shock = loadMaterial("vgui/hud/status_shock.png", suffix)
	status_sprites.trauma = loadMaterial("vgui/hud/status_trauma.png", suffix)
	
	-- NEW: Death, Berserk and Amputation icons
	status_sprites.death = loadMaterial("vgui/hud/status_death.png", suffix)
	status_sprites.berserk = loadMaterial("vgui/hud/status_berserk.png", suffix)
	status_sprites.amputant = loadMaterial("vgui/hud/status_amputant.png", suffix)
end

--================================================================================
-- UPDATE STABILITY TRACKERS
--================================================================================
local function update_stability(blood_val, pulse_val)
	local now = CurTime()
	
	if math.abs(blood_val - stability.blood.last_value) > 50 then
		stability.blood.last_value = blood_val
		stability.blood.last_change = now
		stability.blood.hidden = false
	end
	
	if math.abs(pulse_val - stability.pulse.last_value) > 3 then
		stability.pulse.last_value = pulse_val
		stability.pulse.last_change = now
		stability.pulse.hidden = false
	end
	
	if blood_val >= HUD.blood_hide_threshold and (now - stability.blood.last_change) >= HUD.stable_time then
		stability.blood.hidden = true
	end
	
	if pulse_val >= HUD.pulse_hide_min and pulse_val <= HUD.pulse_hide_max and (now - stability.pulse.last_change) >= HUD.stable_time then
		stability.pulse.hidden = true
	end
end

--================================================================================
-- DRAW: Status bar (PAIN/CONSCIOUS REMOVED)
--================================================================================
local function draw_bar()
	if not HUD.enabled then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.organism then return end
	
	local org = ply.organism
	local scale = math_max(HUD.bar_scale, 0.5)
	
	local base_bar_h = 34
	local base_bar_w = 440
	local bar_h = math_floor(base_bar_h * scale)
	local bar_w = math_floor(base_bar_w * scale)
	local bar_y = ScrH() + HUD.bar_y
	
	local max_bar_w = ScrW() * 0.95
	local max_scale = max_bar_w / base_bar_w
	if scale > max_scale then
		scale = max_scale
		bar_w = math_floor(base_bar_w * scale)
		bar_h = math_floor(base_bar_h * scale)
	end
	
	local bar_x = ScrW() * 0.5 - bar_w * 0.5
	local pad = math_floor(5 * scale)
	local icon_size = math_floor(26 * scale)
	
	load_icons()
	
	local dt = math_min(FrameTime() * 60, 1)
	local s = HUD.smooth
	
	-- FIX: Get O2 value correctly
	local o2_val = getO2Value(org)
	local o2_max = getO2Max(org)
	
	smooth.blood = Lerp(s * dt, smooth.blood or 5000, getOrgVal(org, "blood", 5000))
	smooth.conscious = Lerp(s * dt, smooth.conscious or 1.0, getOrgVal(org, "consciousness", 1))
	smooth.pain = Lerp(s * dt, smooth.pain or 0, getOrgVal(org, "pain", 0))
	smooth.pulse = Lerp(s * dt, smooth.pulse or 70, getOrgVal(org, "pulse", 70))
	smooth.assimilation = Lerp(s * dt, smooth.assimilation or 0, getOrgVal(org, "assimilated", 0))
	smooth.o2 = Lerp(s * dt, smooth.o2 or o2_max, o2_val)
	smooth.bleed = Lerp(s * dt, smooth.bleed or 0, getOrgVal(org, "bleed", 0))
	smooth.internalBleed = Lerp(s * dt, smooth.internalBleed or 0, getOrgVal(org, "internalBleed", 0))
	
	-- NEW: Smooth new values
	smooth.temperature = Lerp(s * dt, smooth.temperature or 36.7, getOrgVal(org, "temperature", 36.7))
	smooth.pneumothorax = Lerp(s * dt, smooth.pneumothorax or 0, getOrgVal(org, "pneumothorax", 0))
	smooth.analgesia = Lerp(s * dt, smooth.analgesia or 0, getOrgVal(org, "analgesia", 0))
	smooth.brain = Lerp(s * dt, smooth.brain or 0, getOrgVal(org, "brain", 0))
	smooth.wantToVomit = Lerp(s * dt, smooth.wantToVomit or 0, getOrgVal(org, "wantToVomit", 0))
	
	-- Additional smoothed values
	smooth.adrenaline = Lerp(s * dt, smooth.adrenaline or 0, getOrgVal(org, "adrenaline", 0))
	smooth.shock = Lerp(s * dt, smooth.shock or 0, getOrgVal(org, "shock", 0))
	smooth.disorientation = Lerp(s * dt, smooth.disorientation or 0, getOrgVal(org, "disorientation", 0))
	
	update_stability(smooth.blood or 5000, smooth.pulse or 70)
	
	local segs = {}
	
	-- Blood
	local blood_val = smooth.blood or 5000
	if not stability.blood.hidden then
		local r_blood = math_min(blood_val / 5000, 1)
		local c_blood = r_blood < 0.5 and lerpCol(r_blood * 2, Color(80, 255, 80), Color(255, 180, 50)) or lerpCol((r_blood - 0.5) * 2, Color(255, 180, 50), Color(255, 50, 50))
		table.insert(segs, {label = "BLOOD", val = math_floor(blood_val), suf = "ml", ratio = r_blood, col = c_blood, w = math_floor(95 * scale), icon = "blood", prio = 1})
	end
	
	-- Oxygen - FIX: Use correct ratio based on max value
	local o2_val = smooth.o2 or o2_max
	local r_o2 = math_min(o2_val / o2_max, 1)
	local c_o2 = lerpCol(r_o2, Color(255, 50, 50), Color(80, 200, 255))
	-- Always show oxygen if below threshold, or if pulse is hidden (to have at least one bar)
	if o2_val < HUD.oxygen_threshold or (#segs == 0 and not stability.pulse.hidden) then
		table.insert(segs, {label = "O2", val = math_floor(o2_val), suf = "%", ratio = r_o2, col = c_o2, w = math_floor(75 * scale), icon = "o2", prio = 2})
	end
	
	-- Assimilation
	local assim_val = smooth.assimilation or 0
	if assim_val > 0.005 then
		local r_assim = assim_val
		table.insert(segs, {label = "ASSIMILATION", val = math_floor(assim_val * 100), suf = "%", ratio = r_assim, col = Color(180, 50, 255, 255), w = math_floor(105 * scale), icon = "assimilation", prio = 3})
	end
	
	-- Pulse
	local pulse_val = smooth.pulse or 70
	if not stability.pulse.hidden then
		local r_pulse = math_min(pulse_val / 100, 1)
		local c_pulse = (pulse_val < 50 or pulse_val > 130) and Color(255, 80, 80) or Color(180, 220, 255)
		table.insert(segs, {label = "PULSE", val = math_floor(pulse_val), suf = "bpm", ratio = r_pulse, col = c_pulse, w = math_floor(80 * scale), icon = "pulse", prio = 4})
	end
	
	if #segs == 0 then return end
	
	table.sort(segs, function(a, b) return a.prio < b.prio end)
	
	local total_width = pad
	for _, seg in ipairs(segs) do total_width = total_width + seg.w + pad end
	
	if total_width > bar_w then
		local new_scale = (bar_w - pad) / (total_width - pad)
		scale = scale * new_scale * 0.98
		bar_w = math_floor(base_bar_w * scale)
		bar_h = math_floor(base_bar_h * scale)
		bar_x = ScrW() * 0.5 - bar_w * 0.5
		pad = math_floor(5 * scale)
		icon_size = math_floor(26 * scale)
		
		for i, seg in ipairs(segs) do
			segs[i].w = math_floor(segs[i].w * new_scale * 0.98)
		end
	end
	
	local x = bar_x + pad
	
	for _, seg in ipairs(segs) do
		local icon = icons[seg.icon]
		if icon and not icon:IsError() then
			surface_SetDrawColor(255, 255, 255, 255)
			surface_SetMaterial(icon)
			surface_DrawTexturedRect(x, bar_y + (bar_h - icon_size) * 0.5, icon_size, icon_size)
		else
			local letters = {blood = "B", o2 = "O", assimilation = "A", pulse = "♥"}
			surface_SetDrawColor(40, 40, 50, 200)
			surface_DrawRect(x + 1, bar_y + (bar_h - icon_size) * 0.5 + 1, icon_size - 2, icon_size - 2)
			surface_SetDrawColor(seg.col.r, seg.col.g, seg.col.b, 255)
			surface_DrawRect(x + 2, bar_y + (bar_h - icon_size) * 0.5 + 2, icon_size - 4, icon_size - 4)
			draw_SimpleText(letters[seg.icon] or "?", "TargetID", x + icon_size * 0.5, bar_y + bar_h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local meter_x = x + icon_size + math_floor(3 * scale)
		local meter_w = seg.w - icon_size - math_floor(10 * scale)
		local meter_y = bar_y + pad + math_floor(2 * scale)
		local meter_h = bar_h - pad * 2 - math_floor(4 * scale)
		
		surface_SetDrawColor(30, 30, 40, 180)
		surface_DrawRect(meter_x, meter_y, meter_w, meter_h)
		
		surface_SetDrawColor(seg.col.r, seg.col.g, seg.col.b, 200)
		surface_DrawRect(meter_x, meter_y, meter_w * seg.ratio, meter_h)
		
		surface_SetDrawColor(80, 80, 90, 230)
		surface_DrawOutlinedRect(meter_x, meter_y, meter_w, meter_h)
		
		local value_text = seg.val .. (seg.suf or "")
		local text_x = meter_x + math_floor(4 * scale)
		local text_y = bar_y + bar_h * 0.5
		draw_SimpleText(value_text, "DermaDefault", text_x, text_y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		x = x + seg.w + pad
	end
end

--================================================================================
-- DRAW: Status effects with BLEEDING STATUS and NEW EFFECTS
--================================================================================
local function draw_status_effects()
	if not HUD.enabled or not HUD.show_status_effects then 
		statusEffectPositions = {}
		return 
	end
	
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.organism then 
		statusEffectPositions = {}
		return 
	end
	
	local org = ply.organism
	local base_x = ScrW() + HUD.status_effects_x
	local base_y = HUD.status_effects_y
	local spacing = HUD.status_effects_spacing
	local size = HUD.status_effects_size
	local currentTime = CurTime()
	
	-- Check if player is dead
	local dead = isPlayerDead(ply)
	
	-- Check if berserk is active
	local berserkActive = isBerserkActive(org)
	
	load_status_sprites()
	statusEffectPositions = {}
	
	local currentEffectNames = {}
	local effects = {}
	
	-- If player is dead, only show death icon
	if dead then
		table.insert(effects, {
			name = "death",
			priority = -1000, -- Highest priority
			value = nil
		})
		currentEffectNames["death"] = true
	else
		-- PAIN STATUS (4 LEVELS) - НЕ показываем в берсерке
		local pain_val = smooth.pain or getOrgVal(org, "pain", 0)
		if pain_val > 10 and not berserkActive then
			local level_num = 1
			if pain_val >= 60 then level_num = 4
			elseif pain_val >= 40 then level_num = 3
			elseif pain_val >= 25 then level_num = 2 end
			
			table.insert(effects, {
				name = "pain",
				level_num = level_num,
				has_levels = true,
				priority = 0,
				value = math_floor(pain_val)
			})
			currentEffectNames["pain"] = true
		end
		
		-- BERSERK STATUS
		if berserkActive then
			local berserk_val = org.berserk or 0
			local level_num = 1
			if berserk_val > 2.5 then level_num = 4
			elseif berserk_val > 1.5 then level_num = 3
			elseif berserk_val > 0.5 then level_num = 2 end
			
			table.insert(effects, {
				name = "berserk",
				level_num = level_num,
				has_levels = true,
				priority = -1, -- Very high priority
				value = math_floor(berserk_val * 10) / 10
			})
			currentEffectNames["berserk"] = true
		end
		
		local showAllIcons = not berserkActive
		
		if berserkActive then
			local brain_val = smooth.brain or getOrgVal(org, "brain", 0)
			if brain_val > HUD.brain_damage_threshold then
				local level_num = 1
				if brain_val > 0.3 then level_num = 4
				elseif brain_val > 0.25 then level_num = 3
				elseif brain_val > 0.15 then level_num = 2 end
				
				table.insert(effects, {
					name = "brain_damage",
					level_num = level_num,
					has_levels = true,
					priority = 0.6,
					value = math_floor(brain_val * 100)
				})
				currentEffectNames["brain_damage"] = true
			end
			
			local spine1 = getOrgVal(org, "spine1", 0)
			local spine2 = getOrgVal(org, "spine2", 0)
			local spine3 = getOrgVal(org, "spine3", 0)
			local spine_fracture = spine1 >= HUD.fracture_threshold or spine2 >= HUD.fracture_threshold or spine3 >= HUD.fracture_threshold
			if spine_fracture then
				table.insert(effects, {name = "spine_fracture", priority = 3})
				currentEffectNames["spine_fracture"] = true
			end
			
			if hasAnyFracture(org, HUD.fracture_threshold) then
				table.insert(effects, {name = "fracture", priority = 6})
				currentEffectNames["fracture"] = true
			end
			
			if org.llegdislocation or org.rlegdislocation or 
			   org.larmdislocation or org.rarmdislocation or 
			   org.jawdislocation then
				table.insert(effects, {name = "dislocation", priority = 5})
				currentEffectNames["dislocation"] = true
			end
			
			local adrenaline_val = smooth.adrenaline or getOrgVal(org, "adrenaline", 0)
			if adrenaline_val > HUD.adrenaline_threshold then
				local level_num = 1
				if adrenaline_val > 2.1 then level_num = 4
				elseif adrenaline_val > 1.5 then level_num = 3
				elseif adrenaline_val > 0.8 then level_num = 2 end
				
				table.insert(effects, {
					name = "adrenaline",
					level_num = level_num,
					has_levels = true,
					priority = 0.65,
					value = math_floor(adrenaline_val * 10) / 10
				})
				currentEffectNames["adrenaline"] = true
			end
			
			local o2_val = getO2Value(org)
			if o2_val < HUD.oxygen_threshold then
				local level_num = 1
				if o2_val < 8 then level_num = 4
				elseif o2_val < 14 then level_num = 3
				elseif o2_val < 23 then level_num = 2 end
				
				table.insert(effects, {
					name = "oxygen",
					level_num = level_num,
					has_levels = true,
					priority = 0.5,
					value = math_floor(o2_val)
				})
				currentEffectNames["oxygen"] = true
			end
			
			local trauma_val = smooth.disorientation or getOrgVal(org, "disorientation", 0)
			if trauma_val > HUD.trauma_threshold then
				local level_num = 1
				if trauma_val > 3 then level_num = 4
				elseif trauma_val > 2.5 then level_num = 3
				elseif trauma_val > 1 then level_num = 2 end
				
				table.insert(effects, {
					name = "trauma",
					level_num = level_num,
					has_levels = true,
					priority = 0.75,
					value = math_floor(trauma_val * 10) / 10
				})
				currentEffectNames["trauma"] = true
			end
			
			if hasAnyAmputation(org) then
				table.insert(effects, {name = "amputant", priority = 8})
				currentEffectNames["amputant"] = true
			end
			
			if org.heartstop == true then
				table.insert(effects, {name = "cardiac_arrest", priority = 0.15})
				currentEffectNames["cardiac_arrest"] = true
			end
			
			if org.lungsfunction == false then
				table.insert(effects, {name = "lungs_failure", priority = 0.35})
				currentEffectNames["lungs_failure"] = true
			end
		end
		
		if showAllIcons then
			local bleed_val = smooth.bleed or getOrgVal(org, "bleed", 0)
			if bleed_val > HUD.bleeding_threshold then
				table.insert(effects, {
					name = "bleeding",
					priority = 0.3,
					value = math_floor(bleed_val)
				})
				currentEffectNames["bleeding"] = true
			end
			
			-- INTERNAL BLEEDING STATUS
			local internal_bleed_val = smooth.internalBleed or getOrgVal(org, "internalBleed", 0)
			if internal_bleed_val > HUD.internal_bleed_threshold then
				table.insert(effects, {
					name = "internal_bleed",
					priority = 0.4,
					value = math_floor(internal_bleed_val * 100)
				})
				currentEffectNames["internal_bleed"] = true
			end
			
			-- CONSCIOUSNESS STATUS (HIDDEN AT >=90%)
			local cons_val = smooth.conscious or getOrgVal(org, "consciousness", 1)
			local cons_percent = math_floor(cons_val * 100)
			if cons_percent < 90 then
				local level_num = 1
				if cons_percent <= 24 then level_num = 4
				elseif cons_percent <= 49 then level_num = 3
				elseif cons_percent <= 74 then level_num = 2 end
				
				table.insert(effects, {
					name = "conscious",
					level_num = level_num,
					has_levels = true,
					priority = 1,
					value = cons_percent
				})
				currentEffectNames["conscious"] = true
			end
			
			-- STAMINA STATUS (4 LEVELS)
			local stamina_table = org.stamina
			if stamina_table and type(stamina_table) == "table" then
				local stamina_val = stamina_table[1] or 0
				local stamina_max = stamina_table.max or 180
				
				if stamina_max <= 0 then stamina_max = 180 end
				
				local stamina_percent = (stamina_val / stamina_max) * 100
				
				if stamina_percent < 75 then
					local level_num = 1
					if stamina_percent <= 24 then level_num = 4
					elseif stamina_percent <= 49 then level_num = 3
					elseif stamina_percent <= 74 then level_num = 2 end
					
					table.insert(effects, {
						name = "stamina",
						level_num = level_num,
						has_levels = true,
						priority = 2,
						value = math_floor(stamina_percent)
					})
					currentEffectNames["stamina"] = true
				end
			end
			
			-- SPINE FRACTURE
			local spine1 = getOrgVal(org, "spine1", 0)
			local spine2 = getOrgVal(org, "spine2", 0)
			local spine3 = getOrgVal(org, "spine3", 0)
			local spine_fracture = spine1 >= HUD.fracture_threshold or spine2 >= HUD.fracture_threshold or spine3 >= HUD.fracture_threshold
			if spine_fracture then
				table.insert(effects, {name = "spine_fracture", priority = 3})
				currentEffectNames["spine_fracture"] = true
			end
			
			-- ОБЪЕДИНЁННЫЙ ПЕРЕЛОМ КОНЕЧНОСТЕЙ (вне берсерка)
			if hasAnyFracture(org, HUD.fracture_threshold) then
				table.insert(effects, {name = "fracture", priority = 6})
				currentEffectNames["fracture"] = true
			end
			
			-- ORGAN DAMAGE
			local organ_damage = math_max(
				getOrgVal(org, "heart", 0),
				getOrgVal(org, "liver", 0),
				getOrgVal(org, "stomach", 0),
				getOrgVal(org, "intestines", 0),
				getOrgTableVal(org, "lungsR", 1, nil, 0),
				getOrgTableVal(org, "lungsL", 1, nil, 0),
				getOrgTableVal(org, "lungsR", 2, nil, 0),
				getOrgTableVal(org, "lungsL", 2, nil, 0)
			)
			if organ_damage > HUD.organ_damage_threshold then
				table.insert(effects, {name = "organ_damage", priority = 4})
				currentEffectNames["organ_damage"] = true
			end
			
			-- DISLOCATIONS
			if org.llegdislocation or org.rlegdislocation or 
			   org.larmdislocation or org.rarmdislocation or 
			   org.jawdislocation then
				table.insert(effects, {name = "dislocation", priority = 5})
				currentEffectNames["dislocation"] = true
			end
			
			-- ===== NEW STATUS EFFECTS (FIRST 10) =====
			
			-- 1. BLOOD LOSS (low blood)
			local blood_val = smooth.blood or getOrgVal(org, "blood", 5000)
			if blood_val < HUD.blood_loss_threshold then
				local level_num = 1
				if blood_val < 2500 then level_num = 4
				elseif blood_val < 3600 then level_num = 3
				elseif blood_val < 4500 then level_num = 2 end
				
				table.insert(effects, {
					name = "blood_loss",
					level_num = level_num,
					has_levels = true,
					priority = 0.1,
					value = math_floor(blood_val)
				})
				currentEffectNames["blood_loss"] = true
			end
			
			-- 2. CARDIAC ARREST
			if org.heartstop == true then
				table.insert(effects, {
					name = "cardiac_arrest",
					priority = 0.15
				})
				currentEffectNames["cardiac_arrest"] = true
			end
			
			-- 3. COLD (hypothermia)
			local temp_val = smooth.temperature or getOrgVal(org, "temperature", 36.7)
			if temp_val < HUD.cold_threshold then
				local level_num = 1
				if temp_val < 31 then level_num = 4
				elseif temp_val < 33 then level_num = 3
				elseif temp_val < 35 then level_num = 2 end
				
				table.insert(effects, {
					name = "cold",
					level_num = level_num,
					has_levels = true,
					priority = 0.2,
					value = math_floor(temp_val * 10) / 10
				})
				currentEffectNames["cold"] = true
			end
			
			-- 4. HEAT (hyperthermia)
			if temp_val > HUD.heat_threshold then
				local level_num = 1
				if temp_val > 40 then level_num = 4
				elseif temp_val > 39 then level_num = 3
				elseif temp_val > 38 then level_num = 2 end
				
				table.insert(effects, {
					name = "heat",
					level_num = level_num,
					has_levels = true,
					priority = 0.2,
					value = math_floor(temp_val * 10) / 10
				})
				currentEffectNames["heat"] = true
			end
			
			-- 5. HEMOTHORAX (pneumothorax)
			local pneumo_val = smooth.pneumothorax or getOrgVal(org, "pneumothorax", 0)
			if pneumo_val > HUD.hemothorax_threshold then
				local level_num = 1
				if pneumo_val > 0.7 then level_num = 4
				elseif pneumo_val > 0.3 then level_num = 3
				elseif pneumo_val > 0.1 then level_num = 2 end
				
				table.insert(effects, {
					name = "hemothorax",
					level_num = level_num,
					has_levels = true,
					priority = 0.25,
					value = math_floor(pneumo_val * 100)
				})
				currentEffectNames["hemothorax"] = true
			end
			
			-- 6. LUNGS FAILURE
			if org.lungsfunction == false then
				table.insert(effects, {
					name = "lungs_failure",
					priority = 0.35
				})
				currentEffectNames["lungs_failure"] = true
			end
			
			-- 7. OVERDOSE (analgesia)
			local analgesia_val = smooth.analgesia or getOrgVal(org, "analgesia", 0)
			if analgesia_val > 0.1 then
				local level_num = 1
				if analgesia_val > 2 then level_num = 4
				elseif analgesia_val > 1.6 then level_num = 3
				elseif analgesia_val > 1 then level_num = 2 end
				
				table.insert(effects, {
					name = "overdose",
					level_num = level_num,
					has_levels = true,
					priority = 0.45,
					value = math_floor(analgesia_val * 10) / 10
				})
				currentEffectNames["overdose"] = true
			end
			
			-- 8. OXYGEN (low oxygen)
			local o2_val = getO2Value(org)
			if o2_val < HUD.oxygen_threshold then
				local level_num = 1
				if o2_val < 8 then level_num = 4
				elseif o2_val < 14 then level_num = 3
				elseif o2_val < 23 then level_num = 2 end
				
				table.insert(effects, {
					name = "oxygen",
					level_num = level_num,
					has_levels = true,
					priority = 0.5,
					value = math_floor(o2_val)
				})
				currentEffectNames["oxygen"] = true
			end
			
			-- 9. VOMIT
			local vomit_val = smooth.wantToVomit or getOrgVal(org, "wantToVomit", 0)
			if vomit_val > HUD.vomit_threshold then
				local level_num = 1
				if vomit_val > 0.9 then level_num = 4
				elseif vomit_val > 0.8 then level_num = 3
				elseif vomit_val > 0.6 then level_num = 2 end
				
				table.insert(effects, {
					name = "vomit",
					level_num = level_num,
					has_levels = true,
					priority = 0.55,
					value = math_floor(vomit_val * 100)
				})
				currentEffectNames["vomit"] = true
			end
			
			-- 10. BRAIN DAMAGE
			local brain_val = smooth.brain or getOrgVal(org, "brain", 0)
			if brain_val > HUD.brain_damage_threshold then
				local level_num = 1
				if brain_val > 0.3 then level_num = 4
				elseif brain_val > 0.25 then level_num = 3
				elseif brain_val > 0.15 then level_num = 2 end
				
				table.insert(effects, {
					name = "brain_damage",
					level_num = level_num,
					has_levels = true,
					priority = 0.6,
					value = math_floor(brain_val * 100)
				})
				currentEffectNames["brain_damage"] = true
			end
			
			-- ===== ADDITIONAL 3 NEW STATUS EFFECTS =====
			
			-- 11. ADRENALINE
			local adrenaline_val = smooth.adrenaline or getOrgVal(org, "adrenaline", 0)
			if adrenaline_val > HUD.adrenaline_threshold then
				local level_num = 1
				if adrenaline_val > 2.1 then level_num = 4
				elseif adrenaline_val > 1.5 then level_num = 3
				elseif adrenaline_val > 0.8 then level_num = 2 end
				
				table.insert(effects, {
					name = "adrenaline",
					level_num = level_num,
					has_levels = true,
					priority = 0.65,
					value = math_floor(adrenaline_val * 10) / 10
				})
				currentEffectNames["adrenaline"] = true
			end
			
			-- 12. SHOCK
			local shock_val = smooth.shock or getOrgVal(org, "shock", 0)
			if shock_val > HUD.shock_threshold then
				local level_num = 1
				if shock_val > 35 then level_num = 4
				elseif shock_val > 25 then level_num = 3
				elseif shock_val > 10 then level_num = 2 end
				
				table.insert(effects, {
					name = "shock",
					level_num = level_num,
					has_levels = true,
					priority = 0.7,
					value = math_floor(shock_val)
				})
				currentEffectNames["shock"] = true
			end
			
			-- 13. TRAUMA (Disorientation)
			local trauma_val = smooth.disorientation or getOrgVal(org, "disorientation", 0)
			if trauma_val > HUD.trauma_threshold then
				local level_num = 1
				if trauma_val > 3 then level_num = 4
				elseif trauma_val > 2.5 then level_num = 3
				elseif trauma_val > 1 then level_num = 2 end
				
				table.insert(effects, {
					name = "trauma",
					level_num = level_num,
					has_levels = true,
					priority = 0.75,
					value = math_floor(trauma_val * 10) / 10
				})
				currentEffectNames["trauma"] = true
			end
			
			-- AMPUTATION (вне берсерка)
			if hasAnyAmputation(org) then
				table.insert(effects, {name = "amputant", priority = 8})
				currentEffectNames["amputant"] = true
			end
		end
	end
	
	-- Clean up appearance tracker
	for name, _ in pairs(statusEffectAppearance) do
		if not currentEffectNames[name] then
			statusEffectAppearance[name] = nil
			tooltipHoverTime[name] = nil
		end
	end
	
	-- Set appearance time for new effects
	for _, effect in ipairs(effects) do
		if not statusEffectAppearance[effect.name] then
			statusEffectAppearance[effect.name] = currentTime
		end
	end
	
	table.sort(effects, function(a, b) return a.priority < b.priority end)
	
	-- Draw effects with CORRECT SHAKE ANIMATION
	for i, effect in ipairs(effects) do
		-- BASE POSITION (without shake)
		local base_x_pos = base_x - size
		local base_y_pos = base_y + (i - 1) * spacing
		
		-- CALCULATE SHAKE OFFSET
		local shakeOffset = 0
		local appearanceTime = statusEffectAppearance[effect.name]
		if appearanceTime then
			local timeActive = currentTime - appearanceTime
			if timeActive < 1.5 then
				local easeOut = (1 - timeActive) ^ 3
				shakeOffset = math_sin(timeActive * 18) * easeOut * 30
			end
		end
		
		-- FINAL POSITION WITH SHAKE
		local final_x = base_x_pos + shakeOffset
		local final_y = base_y_pos
		
		-- Save position for tooltips
		table.insert(statusEffectPositions, {
			x = final_x,
			y = final_y,
			size = size,
			name = effect.name,
			level_num = effect.level_num,
			value = effect.value
		})
		
		-- SELECT BACKGROUND
		local bg_mat
		if effect.has_levels then
			bg_mat = status_sprites.level_backgrounds[effect.level_num] or status_sprites.background
		else
			bg_mat = status_sprites.background
		end
		
		-- DRAW BACKGROUND
		if bg_mat and not bg_mat:IsError() then
			surface_SetDrawColor(255, 255, 255, 220)
			surface_SetMaterial(bg_mat)
			
			-- Apply size multiplier for alternative icons
			local drawSize = size
			local drawX = final_x
			local drawY = final_y
			local padding = 0
			
			if USE_ALT_ICONS then
				-- Determine which multiplier to use
				local multiplier = ALT_ICON_SETTINGS.background_multiplier
				
				-- Apply size modification
				drawSize = size * multiplier
				padding = ALT_ICON_SETTINGS.padding_offset
				
				-- Center the smaller icon
				drawX = final_x + (size - drawSize) / 2
				drawY = final_y + (size - drawSize) / 2
			end
			
			surface_DrawTexturedRect(drawX + padding, drawY + padding, drawSize - padding * 2, drawSize - padding * 2)
		else
			-- Fallback colored background
			local bg_color = Color(40, 40, 50, 220)
			if effect.name == "bleeding" then
				bg_color = Color(180, 30, 30, 220)
			elseif effect.name == "internal_bleed" then
				bg_color = Color(200, 50, 100, 220)
			elseif effect.name == "blood_loss" then
				bg_color = Color(150, 0, 0, 220)
			elseif effect.name == "cardiac_arrest" then
				bg_color = Color(100, 0, 100, 220)
			elseif effect.name == "cold" then
				bg_color = Color(0, 100, 200, 220)
			elseif effect.name == "heat" then
				bg_color = Color(200, 100, 0, 220)
			elseif effect.name == "hemothorax" then
				bg_color = Color(150, 50, 0, 220)
			elseif effect.name == "lungs_failure" then
				bg_color = Color(100, 100, 100, 220)
			elseif effect.name == "overdose" then
				bg_color = Color(150, 0, 150, 220)
			elseif effect.name == "oxygen" then
				bg_color = Color(0, 50, 150, 220)
			elseif effect.name == "vomit" then
				bg_color = Color(100, 80, 0, 220)
			elseif effect.name == "brain_damage" then
				bg_color = Color(100, 0, 50, 220)
			elseif effect.name == "adrenaline" then
				bg_color = Color(255, 100, 0, 220)  -- Orange for adrenaline
			elseif effect.name == "shock" then
				bg_color = Color(100, 100, 200, 220)  -- Blue for shock
			elseif effect.name == "trauma" then
				bg_color = Color(150, 50, 150, 220)  -- Purple for trauma
			elseif effect.name == "death" then
				bg_color = Color(0, 0, 0, 220)  -- Black for death
			elseif effect.name == "berserk" then
				bg_color = Color(180, 0, 0, 220)  -- Dark red for berserk
			elseif effect.name == "amputant" then
				bg_color = Color(80, 40, 40, 220)  -- Dark brown/red for amputation
			elseif effect.name == "fracture" then
				bg_color = Color(200, 100, 0, 220)  -- Orange for fracture
			elseif effect.has_levels then
				if effect.level_num == 4 then bg_color = Color(180, 30, 30, 220)
				elseif effect.level_num == 3 then bg_color = Color(220, 60, 30, 220)
				elseif effect.level_num == 2 then bg_color = Color(255, 140, 40, 220)
				else bg_color = Color(80, 200, 100, 220) end
			end
			
			surface_SetDrawColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
			surface_DrawRect(final_x, final_y, size, size)
			surface_SetDrawColor(255, 255, 255, 255)
			surface_DrawOutlinedRect(final_x, final_y, size, size)
		end
		
		-- DRAW ICON
		local icon_mat = nil
		if effect.name == "pain" then icon_mat = status_sprites.pain_icon
		elseif effect.name == "conscious" then icon_mat = status_sprites.conscious_icon
		elseif effect.name == "stamina" then icon_mat = status_sprites.stamina_icon
		elseif effect.name == "bleeding" then icon_mat = status_sprites.bleeding_icon
		elseif effect.name == "internal_bleed" then icon_mat = status_sprites.internal_bleed_icon
		elseif effect.name == "blood_loss" then icon_mat = status_sprites.blood_loss
		elseif effect.name == "cardiac_arrest" then icon_mat = status_sprites.cardiac_arrest
		elseif effect.name == "cold" then icon_mat = status_sprites.cold
		elseif effect.name == "heat" then icon_mat = status_sprites.heat
		elseif effect.name == "hemothorax" then icon_mat = status_sprites.hemothorax
		elseif effect.name == "lungs_failure" then icon_mat = status_sprites.lungs_failure
		elseif effect.name == "overdose" then icon_mat = status_sprites.overdose
		elseif effect.name == "oxygen" then icon_mat = status_sprites.oxygen
		elseif effect.name == "vomit" then icon_mat = status_sprites.vomit
		elseif effect.name == "brain_damage" then icon_mat = status_sprites.brain_damage
		elseif effect.name == "adrenaline" then icon_mat = status_sprites.adrenaline
		elseif effect.name == "shock" then icon_mat = status_sprites.shock
		elseif effect.name == "trauma" then icon_mat = status_sprites.trauma
		elseif effect.name == "death" then icon_mat = status_sprites.death
		elseif effect.name == "berserk" then icon_mat = status_sprites.berserk
		elseif effect.name == "amputant" then icon_mat = status_sprites.amputant
		elseif effect.name == "fracture" then icon_mat = status_sprites.fracture
		else icon_mat = status_sprites[effect.name] end
		
		if icon_mat and not icon_mat:IsError() then
			surface_SetDrawColor(255, 255, 255, 255)
			surface_SetMaterial(icon_mat)
			
			-- Apply size multiplier for alternative icons
			local drawSize = size - 4
			local drawX = final_x + 2
			local drawY = final_y + 2
			
			if USE_ALT_ICONS then
				-- Get individual multiplier or use default
				local multiplier = ALT_ICON_SETTINGS.size_multiplier
				if ALT_ICON_SETTINGS.individual and ALT_ICON_SETTINGS.individual[effect.name] then
					multiplier = ALT_ICON_SETTINGS.individual[effect.name]
				end
				
				drawSize = (size - 4) * multiplier
				drawX = final_x + (size - drawSize) / 2
				drawY = final_y + (size - drawSize) / 2
			end
			
			surface_DrawTexturedRect(drawX, drawY, drawSize, drawSize)
		else
			-- Fallback letters with value
			local letter = "?"
			local value_text = ""
			
			if effect.name == "pain" then
				letter = "P"
				value_text = effect.value .. ""
			elseif effect.name == "conscious" then
				letter = "C"
				value_text = effect.value .. "%"
			elseif effect.name == "stamina" then
				letter = "S"
				value_text = effect.value .. "%"
			elseif effect.name == "bleeding" then
				letter = "B"
				value_text = effect.value .. ""
			elseif effect.name == "internal_bleed" then
				letter = "IB"
				value_text = effect.value .. "%"
			elseif effect.name == "blood_loss" then
				letter = "BL"
				value_text = effect.value .. "ml"
			elseif effect.name == "cardiac_arrest" then
				letter = "CA"
			elseif effect.name == "cold" then
				letter = "C"
				value_text = effect.value .. "°C"
			elseif effect.name == "heat" then
				letter = "H"
				value_text = effect.value .. "°C"
			elseif effect.name == "hemothorax" then
				letter = "HX"
				value_text = effect.value .. "%"
			elseif effect.name == "lungs_failure" then
				letter = "LF"
			elseif effect.name == "overdose" then
				letter = "OD"
				value_text = effect.value .. ""
			elseif effect.name == "oxygen" then
				letter = "O2"
				value_text = effect.value .. "%"
			elseif effect.name == "vomit" then
				letter = "V"
				value_text = effect.value .. "%"
			elseif effect.name == "brain_damage" then
				letter = "BD"
				value_text = effect.value .. "%"
			elseif effect.name == "adrenaline" then
				letter = "A"
				value_text = effect.value .. ""
			elseif effect.name == "shock" then
				letter = "SH"
				value_text = effect.value .. ""
			elseif effect.name == "trauma" then
				letter = "T"
				value_text = effect.value .. ""
			elseif effect.name == "death" then
				letter = "☠"
			elseif effect.name == "berserk" then
				letter = "⚡"
				value_text = effect.value .. ""
			elseif effect.name == "amputant" then
				letter = "✂"
			elseif effect.name == "fracture" then
				letter = "F"
			else
				local letters = {spine_fracture = "SF", organ_damage = "OD", dislocation = "D"}
				letter = letters[effect.name] or "?"
			end
			
			draw_SimpleText(letter, "TargetID", final_x + size * 0.4, final_y + size * 0.3, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if value_text ~= "" then
				draw_SimpleText(value_text, "DermaDefault", final_x + size * 0.5, final_y + size * 0.7, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end

local function draw_status_tooltips()
    if not HUD.enabled or not HUD.show_status_effects or #statusEffectPositions == 0 then return end
    
    if not isContextMenuOpen() then return end
    
    local mx, my = gui.MousePos()
    if not mx or mx == 0 then return end
    
    local ply = LocalPlayer()
    local berserkActive = IsValid(ply) and ply.organism and isBerserkActive(ply.organism) or false
    
    local hoveredStatus = nil
    local hoveredPos = nil
    
    for _, pos in ipairs(statusEffectPositions) do
        if mx >= pos.x and mx <= pos.x + pos.size and my >= pos.y and my <= pos.y + pos.size then
            hoveredStatus = pos.name
            hoveredPos = pos
            break
        end
    end
    
    if hoveredStatus and hoveredPos then
        local tooltipText = getTooltipText(hoveredStatus, hoveredPos, berserkActive)
        
        if tooltipText and tooltipText ~= "" then
            local font = "DermaDefault"
            if LANGUAGE == "en" and berserkActive then
                font = "BerserkChatFont"
            end
            
            surface.SetFont(font)
            local textW, textH = surface.GetTextSize(tooltipText)
            
            local tooltipX = mx - textW - 20
            local tooltipY = my - textH / 2
            
            if tooltipX < 10 then tooltipX = 10 end
            if tooltipY < 10 then tooltipY = 10 end
            if tooltipY + textH > ScrH() - 10 then tooltipY = ScrH() - textH - 10 end
            
            local padding = 8
            
            surface.SetDrawColor(25, 25, 35, 240)
            surface.DrawRect(tooltipX - padding, tooltipY - padding, textW + padding * 2, textH + padding * 2)
            
            surface.SetDrawColor(255, 50, 50, 255)
            surface.DrawOutlinedRect(tooltipX - padding, tooltipY - padding, textW + padding * 2, textH + padding * 2)
            
            draw.SimpleText(tooltipText, font, tooltipX, tooltipY, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
end

--================================================================================
-- DRAW: Limb sprites with smooth fade transitions
--================================================================================
local function draw_sprites()
	if not HUD.enabled then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.organism then return end
	
	if HUD.base_x == nil then HUD.base_x = ScrW() - 120 end
	
	local org = ply.organism
	local base_x = HUD.base_x
	local base_y = HUD.base_y
	local dt = FrameTime() * HUD.limb_fade_speed
	
	if not debug_done then
		debug_done = true
		local paths = {
			head = {"vgui/hud/health_head.png", "vgui/hud/health_head"},
			torso = {"vgui/hud/health_torso.png", "vgui/hud/health_torso"},
			right_arm = {"vgui/hud/health_right_arm.png", "vgui/hud/health_right_arm"},
			left_arm = {"vgui/hud/health_left_arm.png", "vgui/hud/health_left_arm"},
			right_leg = {"vgui/hud/health_right_leg.png", "vgui/hud/health_right_leg"},
			left_leg = {"vgui/hud/health_left_leg.png", "vgui/hud/health_left_leg"},
		}
		
		for name, tries in pairs(paths) do
			for _, path in ipairs(tries) do
				local mat = Material(path, "smooth")
				if mat and not mat:IsError() then
					sprites[name] = mat
					break
				end
			end
			if not sprites[name] then sprites[name] = false end
		end
	end
	
	-- Check if any limb is damaged
	local anyDamage = hasAnyLimbDamage(org)
	
	-- Update reveal state
	if anyDamage and not limbsRevealed then
		limbsRevealed = true
	elseif not anyDamage and limbsRevealed then
		limbsRevealed = false
	end
	
	-- Define limbs with their damage values and amputation flags
	local limbs = {
		{name = "head", dmg = math_max(getOrgVal(org, "skull", 0), getOrgVal(org, "jaw", 0) * 0.7), amput = "headamputated", label = "H"},
		{name = "torso", dmg = math_max(getOrgVal(org, "chest", 0), getOrgVal(org, "spine1", 0), getOrgVal(org, "spine2", 0), getOrgVal(org, "spine3", 0), getOrgVal(org, "pelvis", 0) * 0.9), amput = nil, label = "T"},
		{name = "right_arm", dmg = getOrgVal(org, "rarm", 0), amput = "rarmamputated", label = "RA"},
		{name = "left_arm", dmg = getOrgVal(org, "larm", 0), amput = "larmamputated", label = "LA"},
		{name = "right_leg", dmg = getOrgVal(org, "rleg", 0), amput = "rlegamputated", label = "RL"},
		{name = "left_leg", dmg = getOrgVal(org, "lleg", 0), amput = "llegamputated", label = "LL"},
	}
	
	-- Update fade states for each limb
	for _, limb in ipairs(limbs) do
		local state = limbFadeStates[limb.name]
		if not state then continue end
		
		-- Skip if limb is amputated (always hidden)
		if limb.amput and org[limb.amput] then
			state.target = 0
		else
			-- Set target alpha based on reveal state
			if HUD.always_show_limbs then
				state.target = 255
			else
				-- Show all limbs when any damage is present, hide when completely healed
				state.target = limbsRevealed and 255 or 0
			end
		end
		
		-- Smoothly interpolate alpha
		state.alpha = Lerp(dt, state.alpha, state.target)
		
		-- If alpha is very low, skip drawing (optimization)
		if state.alpha < 1 then
			continue
		end
		
		local dmg = limb.dmg
		local ofs = HUD.limb_offsets[limb.name] or {x = 0, y = 0}
		local scale = HUD.limb_scale[limb.name] or {w = 1.0, h = 1.0}
		
		local x = base_x + ofs.x
		local y = base_y + ofs.y
		
		local base_size = 40
		local width = base_size * scale.w
		local height = base_size * scale.h
		
		local col = getLimbColor(dmg)
		local damage_boost = math_min(dmg * 150, 100)
		local total_visibility = math_min(HUD.sprite_visibility + damage_boost, 100)
		local alpha = math_floor(state.alpha * (total_visibility / 100))
		
		local mat = sprites[limb.name]
		if mat and not mat:IsError() then
			surface_SetDrawColor(col.r, col.g, col.b, alpha)
			surface_SetMaterial(mat)
			surface_DrawTexturedRect(x - width * 0.5, y - height * 0.5, width, height)
		else
			surface_SetDrawColor(0, 0, 0, math_floor(alpha * 0.5))
			surface_DrawRect(x - width * 0.5 + 2, y - height * 0.5 + 2, width - 4, height - 4)
			surface_SetDrawColor(col.r, col.g, col.b, alpha)
			surface_DrawRect(x - width * 0.5 + 4, y - height * 0.5 + 4, width - 8, height - 8)
			draw_SimpleText(limb.label, "TargetID", x, y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

--================================================================================
-- LANGUAGE SWITCH COMMAND: hg_languagepopa Ru/Eng
--================================================================================
concommand.Add("mzb_languagepopa", function(ply, cmd, args)
	if args[1] then
		local lang = string.lower(args[1])
		if lang == "ru" or lang == "русский" or lang == "russian" then
			LANGUAGE = "ru"
			chat.AddText(Color(0, 200, 255), "Language set to: ", Color(255, 255, 255), "Русский")
		elseif lang == "en" or lang == "eng" or lang == "english" or lang == "английский" then
			LANGUAGE = "en"
			chat.AddText(Color(0, 200, 255), "Language set to: ", Color(255, 255, 255), "English")
		else
			chat.AddText(Color(255, 100, 100), "Unknown language. Use: Ru or Eng")
		end
	else
		chat.AddText(Color(0, 200, 255), "Current language: ", Color(255, 255, 255), 
			LANGUAGE == "ru" and "Русский" or "English")
		chat.AddText(Color(200, 200, 200), "Usage: mzb_languagepopa Ru / Eng")
	end
end)

--================================================================================
-- ALTERNATIVE ICONS SWITCH COMMAND: hg_nopixelicons
--================================================================================
concommand.Add("mzb_nopixelicons", function(ply, cmd, args)
	USE_ALT_ICONS = not USE_ALT_ICONS
	status_sprites_loaded = false -- Force reload of status sprites
	status_sprites = {
		level_backgrounds = {nil, nil, nil, nil},
		background = nil,
		pain_icon = nil,
		conscious_icon = nil,
		stamina_icon = nil,
		bleeding_icon = nil,
		internal_bleed_icon = nil,
		organ_damage = nil,
		dislocation = nil,
		spine_fracture = nil,
		fracture = nil,
		blood_loss = nil,
		cardiac_arrest = nil,
		cold = nil,
		heat = nil,
		hemothorax = nil,
		lungs_failure = nil,
		overdose = nil,
		oxygen = nil,
		vomit = nil,
		brain_damage = nil,
		adrenaline = nil,
		shock = nil,
		trauma = nil,
		death = nil,
		berserk = nil,
		amputant = nil,
	}
	
	local status = USE_ALT_ICONS and "Nopixelicons" or "Pixelicons"
	chat.AddText(Color(0, 200, 255), "Alticons: ", USE_ALT_ICONS and Color(100, 255, 100, 255) or Color(255, 100, 100, 255), status)
end)

-- Register hooks
hook.Add("HUDPaint", "ZB_Health_Bar", draw_bar)
hook.Add("HUDPaint", "ZB_Health_Sprites", draw_sprites)
hook.Add("HUDPaint", "ZB_Health_StatusEffects", draw_status_effects)
hook.Add("HUDPaint", "ZB_Health_StatusTooltips", draw_status_tooltips)

--================================================================================
-- Console commands
--================================================================================
concommand.Add("mzb_health_toggle", function(ply, cmd, args)
	HUD.enabled = args[1] and (tonumber(args[1]) ~= 0) or not HUD.enabled
	chat.AddText(Color(0, 200, 255), "HealthHud", HUD.enabled and "Enabled" or "Disabled")
end)

concommand.Add("mzb_health_reload", function()
	sprites = {}
	icons = {}
	status_sprites = {level_backgrounds = {nil, nil, nil, nil}}
	status_sprites_loaded = false
	debug_done = false
	statusEffectAppearance = {}
	statusEffectPositions = {}
	tooltipHoverTime = {}
	lastHoveredStatus = nil
	
	-- Reset limb fade states
	limbFadeStates = {
		head = {alpha = 0, target = 0},
		torso = {alpha = 0, target = 0},
		right_arm = {alpha = 0, target = 0},
		left_arm = {alpha = 0, target = 0},
		right_leg = {alpha = 0, target = 0},
		left_leg = {alpha = 0, target = 0},
	}
	limbsRevealed = false
	
	smooth = {blood = 5000, conscious = 1.0, pain = 0, pulse = 70, assimilation = 0, o2 = 30, bleed = 0, internalBleed = 0,
	          temperature = 36.7, pneumothorax = 0, analgesia = 0, brain = 0, wantToVomit = 0,
	          adrenaline = 0, shock = 0, disorientation = 0}
	stability = {
		blood = {last_value = 5000, last_change = CurTime(), hidden = false},
		pulse = {last_value = 70, last_change = CurTime(), hidden = false},
	}
	chat.AddText(Color(0, 200, 255), "")
end)

concommand.Add("mzb_health_smooth", function(ply, cmd, args)
	if args[1] then
		local v = tonumber(args[1])
		if v then
			HUD.smooth = math.Clamp(v, 0, 1)
			chat.AddText(Color(0, 200, 255), "Smoothness: ", Color(255, 255, 255), tostring(HUD.smooth))
		end
	end
end)

concommand.Add("mzb_health_alpha", function(ply, cmd, args)
	if args[1] then
		local v = tonumber(args[1])
		if v then
			HUD.sprite_visibility = math.Clamp(v, 0, 100)
			chat.AddText(Color(0, 200, 255), "Limb visibility: ", Color(255, 255, 255), HUD.sprite_visibility .. "%")
		end
	end
end)

concommand.Add("mzb_popalimbs", function(ply, cmd, args)
	HUD.always_show_limbs = not HUD.always_show_limbs
	local status = HUD.always_show_limbs and "ON (always visible)" or "OFF (show if damaged)"
	chat.AddText(Color(0, 200, 255), "Limbs Viewer: ", HUD.always_show_limbs and Color(100, 255, 100, 255) or Color(255, 100, 100, 255), status)
end)

concommand.Add("mzb_health_bar_scale", function(ply, cmd, args)
	if args[1] then
		local v = tonumber(args[1])
		if v then
			HUD.bar_scale = math.Clamp(v, 0.5, 2.5)
			local pct = math_floor(HUD.bar_scale * 100)
			chat.AddText(Color(0, 200, 255), "Status bar scale: ", Color(255, 255, 255), HUD.bar_scale .. "x (" .. pct .. "%)")
		end
	end
end)

concommand.Add("mzb_health_fade_speed", function(ply, cmd, args)
	if args[1] then
		local v = tonumber(args[1])
		if v then
			HUD.limb_fade_speed = math.Clamp(v, 0.5, 10)
			chat.AddText(Color(0, 200, 255), "Limb fade speed: ", Color(255, 255, 255), HUD.limb_fade_speed)
		end
	end
end)

concommand.Add("mzb_health_showall", function()
	stability.blood.hidden = false
	stability.blood.last_change = CurTime() - HUD.stable_time - 1
	stability.pulse.hidden = false
	stability.pulse.last_change = CurTime() - HUD.stable_time - 1
	chat.AddText(Color(0, 200, 255), "All parameters forced visible")
end)

concommand.Add("mzb_health_percent", function(ply, cmd, args)
	HUD.show_damage_percent = not HUD.show_damage_percent
	chat.AddText(Color(0, 200, 255), "Limb damage percent: ", HUD.show_damage_percent and Color(100, 255, 100, 255) or Color(255, 100, 100, 255), HUD.show_damage_percent and "ON" or "OFF")
end)

concommand.Add("mzb_health_status", function(ply, cmd, args)
	HUD.show_status_effects = not HUD.show_status_effects
	chat.AddText(Color(0, 200, 255), "Status effects: ", HUD.show_status_effects and Color(100, 255, 100, 255) or Color(255, 100, 100, 255), HUD.show_status_effects and "ON" or "OFF")
end)
