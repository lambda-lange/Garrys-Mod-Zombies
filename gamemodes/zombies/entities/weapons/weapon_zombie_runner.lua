AddCSLuaFile()

SWEP.Base = "weapon_zombie_base"
SWEP.PrintName = "Zombie Runner"
SWEP.Spawnable = true

SWEP.HitDistance = 60
SWEP.Damage = 40

function SWEP:TranslateActivity(act)
    self.ActivityTranslate[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_ZOMBIE
    self.ActivityTranslate[ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_01
    self.ActivityTranslate[ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE_FAST
    self.ActivityTranslate[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
    self.ActivityTranslate[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
    self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
    self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
    self.ActivityTranslate[ACT_MP_JUMP] = ACT_ZOMBIE_LEAPING
    self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_GMOD_GESTURE_RANGE_ZOMBIE

    return self.ActivityTranslate[act] or -1
end