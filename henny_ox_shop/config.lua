-- NPCS DO NOT CURRENTLY LOAD BUT SCRIPT WILL START WITHOUT THEM SO ALL YOU NEED TO DO IS CHANGE THE VECTOR ONTO A PLACE YOU WANT TO OX TARGET TO GO TO. WILL BE FIXED IN A FUTURE UPDATE 

Config = {}

Config.Shops = {
    { 
        name = "24/7 Supermarket",
        location = vector4(-3039.1270, 585.0641, 9.2389, 92.3175),
        ped = "", -- do not touch
        scenario = "WORLD_HUMAN_CLIPBOARD",
        categories = {"Food", "Electronics"},
        blip = { sprite = 52, color = 2, scale = 0.8, display = 4 }
    }, 

    { 
        name = "Ammu-Nation",
        location = vector4(23.9080, -1106.7380, 30.8477, 42.1053),
        ped = "", -- do not touch
        scenario = "WORLD_HUMAN_CLIPBOARD",
        categories = {"Weapons", "Ammo"},
        blip = { sprite = 110, color = 38, scale = 0.8, display = 4 }
    }, 

    { 
        name = "Hardware Store",
        location = vector4(46.2, -1748.9, 29.5, 315.0),
        ped = "", -- do not touch
        scenario = "WORLD_HUMAN_CLIPBOARD",
        categories = {"Tools"},
        blip = { sprite = 402, color = 5, scale = 0.8, display = 4 }
    } 
}


Config.Categories = {
    ["Food"] = {
        label = "Food & Drinks",
        items = {
            {name = "weapon_pistol50", label = "Bottled Water", price = 5},
            {name = "food", label = "Burger", price = 10},
            {name = "cola", label = "eCola", price = 7},
        }
    },
    ["Electronics"] = {
        label = "Electronics",
        items = {
            {name = "phone", label = "Mobile Phone", price = 500},
            {name = "radio", label = "Radio", price = 150},
        }
    },
    ["Weapons"] = {
        label = "Weapons",
        items = {
            {name = "weapon_pistol", label = "Pistol", price = 2500},
            {name = "weapon_knife", label = "Knife", price = 7500},
        }
    },
    ["Ammo"] = {
        label = "Ammunition",
        items = {
            {name = "ammo-9", label = "9mm Rounds", price = 50},
        }
    },
    ["Tools"] = {
        label = "Tools",
        items = {
            {name = "lockpick", label = "Lockpick", price = 25},
            {name = "repairkit", label = "Repair Kit", price = 100},
        }
    }
}
