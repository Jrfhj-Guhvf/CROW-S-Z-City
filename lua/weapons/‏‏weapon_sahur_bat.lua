if SERVER then
    AddCSLuaFile()
end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Sahur's Bat"
SWEP.Instructions = 'An old man took his phone to a Repair Shop.\nEvil Repairer: "Everything is wrong"\nOld Man with tears in his eyes said:\n"Tung Tung the Devil"'
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_hatchet.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/weapons/tfa_nmrih/w_me_bat_wood.mdl"
SWEP.DontChangeDropped = false
SWEP.weaponPos = Vector(0, 1, 2)
SWEP.weaponAng = Angle(0, -90, 0)
SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)
SWEP.basebone = 94
SWEP.BreakBoneMul = 0.5
SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_baseballbat")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_baseballbat"
    SWEP.BounceWeaponIcon = false
end
SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.NoHolster = false
SWEP.HoldPos = Vector(-15, 0, 0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.AttackPos = Vector(0, 0, 0)
SWEP.HoldType = "melee"
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 10
SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 6
SWEP.MaxPenLen = 2
SWEP.PainMultiplier = 0.85
SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.5
SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 5
SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 40
SWEP.AttackHit = "Wood.ImpactHard"
SWEP.Attack2Hit = "Wood.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Wood.ImpactSoft"
SWEP.weight = 1.5

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 65
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0