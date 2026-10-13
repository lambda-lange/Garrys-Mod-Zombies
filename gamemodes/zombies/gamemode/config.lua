ZConfig = ZConfig or {}

ZConfig = {
    title = "Zombies",
    version = "099",
    roundtimer = 300,
    roundtimerprep = 30,
    roundidle = 8,
    xpMultiplier = 1.096, -- old 1.096 // updated 2026.03

    maxrounds = 6,
    mapvotetimer = 30,
    maps = {
        {title = "Far", map = "gm_far", id = "3165609019", png = Material("zombies/ui/maps/far.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }},
        {title = "Tunnels", map = "gm_explore_tunnels", id = "1529025790", png = Material("zombies/ui/maps/tunnels.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }},
        {title = "M3 Facility", map = "gm_m3_facility", id = "3155350743", png = Material("zombies/ui/maps/m3.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }},
        {title = "Port Klax", map = "gm_port_klax", id = "3143258705", png = Material("zombies/ui/maps/port.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }},
        {title = "Mono Market", map = "gm_mono_market", id = "3256304807", png = Material("zombies/ui/maps/mono.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }},
        {title = "Grant Street", map = "gm_grant_street", id = "3110660376", png = Material("zombies/ui/maps/grant.png"), extraction = { Vector(0, 0, 0), Vector(220, 0, 0) }}
    },

    // NEW WEAPON SHOP CONFIG
    shop = {
        weapons = { -- name = Display Name, price = cost, swep = weapon_m9k_swep, slot 1-2 (1=primary, 2=secondary)
            [1] = { name = "MP5", price = 0, swep = "m9k_mp5", slot = 1, default = true }, -- default primary
            [2] = { name = "M92 Beretta", price = 0, swep = "m9k_m92beretta", slot = 2, default = true }, -- default secondary

            // SMGS 1000-5000
            [3] = { name = "Honeybadger", price = 3000, swep = "m9k_honeybadger", slot = 1 },
            [4] = { name = "PP19", price = 4000, swep = "m9k_bizonp19", slot = 1 },
            [5] = { name = "P90", price = 3500, swep = "m9k_smgp90", slot = 1 },
            [6] = { name = "MP-7", price = 10000, swep = "m9k_mp7", slot = 1 },
            [7] = { name = "UMP-45", price = 1500, swep = "m9k_ump45", slot = 1 },
            [8] = { name = "USC", price = 1500, swep = "m9k_usc", slot = 1 },
            [9] = { name = "KAC PDW", price = 1500, swep = "m9k_kac_pdw", slot = 1 },
            [10] = { name = "KRISS Vector", price = 2000, swep = "m9k_vector", slot = 1 },
            [11] = { name = "Magpul PDR", price = 2000, swep = "m9k_magpulpdr", slot = 1 },
            [12] = { name = "MP-40", price = 4000, swep = "m9k_mp40", slot = 1 },
            [13] = { name = "MP5-SD", price = 4500, swep = "m9k_mp5sd", slot = 1 },
            [14] = { name = "MP9", price = 5000, swep = "m9k_mp9", slot = 1 },
            [15] = { name = "Sten", price = 1000, swep = "m9k_sten", slot = 1 },
            [16] = { name = "TEC-9", price = 4500, swep = "m9k_tec9", slot = 2 },
            [17] = { name = "Tommy Gun", price = 3000, swep = "m9k_thompson", slot = 1 },
            [18] = { name = "UZI", price = 5000, swep = "m9k_uzi", slot = 2 },

            [19] = { name = "HK G3A3", price = 17500, swep = "m9k_g3a3", slot = 1 },
            [20] = { name = "M4A1", price = 15000, swep = "m9k_m4a1", slot = 1 },
            [21] = { name = "M16A4 ACOG", price = 17500, swep = "m9k_m16a4_acog", slot = 1 },
            [22] = { name = "73 Winchester", price = 10000, swep = "m9k_winchester73", slot = 1 },
            [23] = { name = "Ak-74", price = 12500, swep = "m9k_ak74", slot = 1 },
            [24] = { name = "ACR", price = 12500, swep = "m9k_acr", slot = 1 },
            [25] = { name = "TAR-21", price = 10000, swep = "m9k_tar21", slot = 1 },
            [26] = { name = "HK 416", price = 15000, swep = "m9k_m416", slot = 1 },
            [27] = { name = "SCAR", price = 20000, swep = "m9k_scar", slot = 1 },
            [28] = { name = "FN-FAL", price = 13000, swep = "m9k_fal", slot = 1 },
            [29] = { name = "Colt Python", price = 10000, swep = "m9k_coltpython", slot = 2 },
            [30] = { name = "Luger", price = 5000, swep = "m9k_luger", slot = 2 },
            [31] = { name = "Deagle", price = 6000, swep = "m9k_deagle", slot = 2 },
            [32] = { name = "USP", price = 4000, swep = "m9k_usp", slot = 2 },
            [33] = { name = "Dragunov", price = 25000, swep = "m9k_dragunov", slot = 1 },
            [34] = { name = "Barret M82", price = 27500, swep = "m9k_barret_m82", slot = 1 },
            [35] = { name = "M24", price = 22500, swep = "m9k_m24", slot = 1 },
            [36] = { name = "Famas", price = 12500, swep = "m9k_famas", slot = 1 },
            [37] = { name = "Double Barrel Shotgun", price = 20000, swep = "m9k_dbarrel", slot = 1 },
            [38] = { name = "Striker 12", price = 15000, swep = "m9k_striker12", slot = 1 },
            [39] = { name = "Spas 12", price = 12500, swep = "m9k_spas12", slot = 1 },
            [40] = { name = "USAS", price = 15000, swep = "m9k_usas", slot = 1 },
            [41] = { name = "Beneli M3", price = 15000, swep = "m9k_m3", slot = 1 },
            [42] = { name = "Vikhr", price = 12500, swep = "m9k_vikhr", slot = 1 },
            [43] = { name = "Jackhammer", price = 12500, swep = "m9k_jackhammer", slot = 1 },
            [44] = { name = "AMD 65", price = 12500, swep = "m9k_amd65", slot = 1 },
            [45] = { name = "AS VAL", price = 11000, swep = "m9k_val", slot = 1 }
        }
    },

    classes = {
        zombies = {
            [1] = {
                name = "Walker",
                desc = "A slow but sturdy zombie. Good for absorbing damage.",
                health = 250,
                swep = "weapon_zombie_walker",
                speed = 300,
                jump = 250,
                model = "models/player/zombie_classic.mdl",
                level = 0
            },
            [2] = {
                name = "Runner",
                desc = "A fast zombie capable of swift attacks.",
                health = 100,
                swep = "weapon_zombie_runner",
                speed = 400,
                jump = 200,
                model = "models/player/corpse1.mdl",
                level = 1
            },
            [3] = {
                name = "Jumper",
                desc = "An agile zombie with exceptional jumping abilities.",
                health = 150,
                swep = "weapon_zombie_walker",
                speed = 250,
                jump = 500,
                model = "models/player/zombie_fast.mdl",
                level = 0
            },
            [4] = {
                name = "Tank",
                desc = "A heavy and powerful zombie, but slow-moving.",
                health = 1000,
                swep = "weapon_zombie_tank",
                speed = 140,
                jump = 200,
                model = "models/player/zombie_soldier.mdl",
                footsteps = {"npc/combine_soldier/gear1.wav", "npc/combine_soldier/gear2.wav", "npc/combine_soldier/gear3.wav", "npc/combine_soldier/gear4.wav", "npc/combine_soldier/gear5.wav" ,"npc/combine_soldier/gear6.wav"},
                level = 4
            },
            [5] = {
                name = "Ghost",
                desc = "A stealthy and elusive undead creature.",
                health = 50,
                swep = "weapon_zombie_ghost",
                speed = 240,
                jump = 200,
                model = "models/player/skeleton.mdl",
                level = 6
            },
            [6] = {
                name = "Bomber",
                desc = "Full of nasty stuff, explodes on death causing significant damage.",
                health = 200,
                swep = "weapon_zombie_walker",
                speed = 260,
                jump = 200,
                model = "models/player/poison_player.mdl",
                level = 8
            },
            [7] = {
                name = "Smoker",
                desc = "The Smoker employs toxic smokes, dealing damage and impairing vision.",
                health = 150,
                swep = "weapon_zombie_smoker",
                speed = 260,
                jump = 200,
                model = "models/player/soldier_stripped.mdl",
                level = 2
            }
        },

        humans = {
            [1] = {
                name = "Survivor",
                desc = "Resilient and resourceful, the Survivor endures tough situations relying on instinct.",
                speed = 200,
                jump = 160,
                health = 150,
                model = "models/player/Group01/male_07.mdl",
                level = 0
            },
            [2] = {
                name = "Demolisher",
                desc = "A heavily armed specialist equipped with a powerful grenade launcher with 5 grenades.",
                speed = 180,
                health = 120,
                jump = 160,
                model = "models/player/Group03/male_02.mdl",
                swep = "m9k_m79gl",
                level = 5
            },
            [3] = {
                name = "Trapper",
                desc = "The Trapper uses 5 proximity mines to deal massive damage against zombies.",
                speed = 180,
                jump = 160,
                model = "models/player/phoenix.mdl",
                swep = "swep_trapper",
                level = 6
            },
            [4] = {
                name = "Medic",
                desc = "Compassionate healer armed with a healpack, providing essential medical support.",
                speed = 190,
                jump = 160,
                model = "models/player/Group03m/female_04.mdl",
                swep = "swep_healmed",
                level = 2
            },
            [5] = {
                name = "Gunner",
                desc = "Armed with a powerful PKM, slightly slower but with unmatched firepower.",
                speed = 140,
                jump = 160,
                model = "models/player/guerilla.mdl",
                swep = "m9k_pkm",
                level = 10
            },
            [6] = {
                name = "Scout",
                desc = "A quick and agile survivor, adept at navigating challenging environments.",
                speed = 240,
                jump = 200,
                health = 80,
                model = "models/player/p2_chell.mdl",
                level = 8
            },
            [7] = {
                name = "Barricader",
                desc = "The barricader secures the perimeter with sturdy barriers, shielding allies from the relentless undead.",
                speed = 180,
                jump = 160,
                health = 150,
                model = "models/player/barney.mdl",
                swep = "swep_barricader",
                level = 4
            },
        }
    },

    // sadly never finished (2026 last  ote)
    badges = {
        ["alphatester"] = {title = "Alpha", desc = "You have played the alpha version of Zombies", png = Material("zombies/ui/badges/badge.png")}
        --["zombiehunter"] = {title = "Zombie Hunter", desc = "You killed 1.000 Zombies!", png = Material("zombies/ui/badges/badge.png")}
    }
}