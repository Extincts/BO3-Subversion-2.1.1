loadarrays()
{
    level dmc2_load_font();
    
    SetDvar("bg_fallDamageMinHeight", 9999);
    SetDvar("bg_fallDamageMaxHeight", 9999);
    
    level.box_weapons = [];

    //Overrides
    level.callbackActorDamage = ::_actor_damage_override_wrapper;
    level.overridePlayerDamage = ::_player_damage_override_wrapper;
    
    if( IsDefined( level.powerup_special_drop_override ) )
        level._original_powerup_special_drop_override = level.powerup_special_drop_override;
        
    level.powerup_special_drop_override = ::powerup_special_drop_override;
    level._original_minigun_grab        = level._custom_powerups["minigun"].grab_powerup;
    level._custom_powerups["minigun"].grab_powerup = ::minigun_wrapper;

    level._lightning_params = lightning_chain::create_lightning_chain_params(7, 15, 300, 10, 75, 0.11, 10, 128, 4, undefined, undefined, "wpn_tesla_bounce");

    level.spawnPoints  = get_teleport_points();
    level.achievements = array("CP_COMPLETE_PROLOGUE", "CP_COMPLETE_NEWWORLD", "CP_COMPLETE_BLACKSTATION", "CP_COMPLETE_BIODOMES", "CP_COMPLETE_SGEN", "CP_COMPLETE_VENGEANCE", "CP_COMPLETE_RAMSES", "CP_COMPLETE_INFECTION", "CP_COMPLETE_AQUIFER", "CP_COMPLETE_LOTUS", "CP_HARD_COMPLETE", "CP_REALISTIC_COMPLETE","CP_CAMPAIGN_COMPLETE", "CP_FIREFLIES_KILL", "CP_UNSTOPPABLE_KILL", "CP_FLYING_WASP_KILL", "CP_TIMED_KILL", "CP_ALL_COLLECTIBLES", "CP_DIFFERENT_GUN_KILL", "CP_ALL_DECORATIONS", "CP_ALL_WEAPON_CAMOS", "CP_CONTROL_QUAD", "CP_MISSION_COLLECTIBLES",   "CP_DISTANCE_KILL", "CP_OBSTRUCTED_KILL", "CP_MELEE_COMBO_KILL", "CP_COMPLETE_WALL_RUN", "CP_TRAINING_GOLD", "CP_COMBAT_ROBOT_KILL", "CP_KILL_WASPS", "CP_CYBERCORE_UPGRADE", "CP_ALL_WEAPON_ATTACHMENTS", "CP_TIMED_STUNNED_KILL", "CP_UNLOCK_DOA", "ZM_COMPLETE_RITUALS", "ZM_SPOT_SHADOWMAN", "GOBBLE_GUM", "ZM_STORE_KILL", "ZM_ROCKET_SHIELD_KILL", "ZM_CIVIL_PROTECTOR", "ZM_WINE_GRENADE_KILL", "ZM_MARGWA_KILL", "ZM_PARASITE_KILL", "MP_REACH_SERGEANT", "MP_REACH_ARENA", "MP_SPECIALIST_MEDALS", "MP_MULTI_KILL_MEDALS", "ZM_CASTLE_EE", "ZM_CASTLE_ALL_BOWS", "ZM_CASTLE_MINIGUN_MURDER",   "ZM_CASTLE_UPGRADED_BOW", "ZM_CASTLE_MECH_TRAPPER", "ZM_CASTLE_SPIKE_REVIVE", "ZM_CASTLE_WALL_RUNNER", "ZM_CASTLE_ELECTROCUTIONER", "ZM_CASTLE_WUNDER_TOURIST", "ZM_CASTLE_WUNDER_SNIPER", "ZM_ISLAND_COMPLETE_EE", "ZM_ISLAND_DRINK_WINE", "ZM_ISLAND_CLONE_REVIVE", "ZM_ISLAND_OBTAIN_SKULL", "ZM_ISLAND_WONDER_KILL", "ZM_ISLAND_STAY_UNDERWATER", "ZM_ISLAND_THRASHER_RESCUE", "ZM_ISLAND_ELECTRIC_SHIELD", "ZM_ISLAND_DESTROY_WEBS", "ZM_ISLAND_EAT_FRUIT", "ZM_STALINGRAD_NIKOLAI", "ZM_STALINGRAD_WIELD_DRAGON", "ZM_STALINGRAD_TWENTY_ROUNDS", "ZM_STALINGRAD_RIDE_DRAGON", "ZM_STALINGRAD_LOCKDOWN", "ZM_STALINGRAD_SOLO_TRIALS", "ZM_STALINGRAD_BEAM_KILL", "ZM_STALINGRAD_STRIKE_DRAGON", "ZM_STALINGRAD_FAFNIR_KILL", "ZM_STALINGRAD_AIR_ZOMBIES", "ZM_GENESIS_EE", "ZM_GENESIS_SUPER_EE", "ZM_GENESIS_PACKECTOMY", "ZM_GENESIS_KEEPER_ASSIST", "ZM_GENESIS_DEATH_RAY", "ZM_GENESIS_GRAND_TOUR", "ZM_GENESIS_WARDROBE_CHANGE", "ZM_GENESIS_WONDERFUL", "ZM_GENESIS_CONTROLLED_CHAOS", "DLC2_ZOMBIE_ALL_TRAPS", "DLC2_ZOM_LUNARLANDERS", "DLC2_ZOM_FIREMONKEY", "DLC4_ZOM_TEMPLE_SIDEQUEST", "DLC4_ZOM_SMALL_CONSOLATION", "DLC5_ZOM_CRYOGENIC_PARTY", "DLC5_ZOM_GROUND_CONTROL", "ZM_DLC4_TOMB_SIDEQUEST", "ZM_DLC4_OVERACHIEVER", "ZM_PROTOTYPE_I_SAID_WERE_CLOSED", "ZM_ASYLUM_ACTED_ALONE", "ZM_THEATER_IVE_SEEN_SOME_THINGS");

    level.m_snappable_models = ["All", "The Giant"]; // supported maps
    level.r_snappable_models = ["Magic Box", "Metal Desk"]; // model real names
   	level.snappable_models = [getMagicBoxModel(), "p7_desk_metal_old_01_body_rusty"]; // model id names
	level.snappable_dimensions = ["90;24;57;17.5", "72;36;54;34"]; // model dimensions

    level.weapons = [];
    level.weapon_categories = ["Assault Rifles", "Submachine Guns", "Shotguns", "Light Machine Guns", "Sniper Rifles", "Pistols", "Launchers", "Extras"]; 
    weapon_types = ["assault", "smg", "cqb", "lmg", "sniper", "pistol", "launcher"];

    weapNames = [];
    foreach(weapon in getArrayKeys(level.zombie_weapons))
        weapNames[weapNames.size] = weapon.name;

    for(i=0;i<weapon_types.size;i++)
    {
        level.weapons[i] = []; 
        for(e=1;e<100;e++)
        {
            weapon_categ = tableLookup( "gamedata/stats/zm/zm_statstable.csv", 0, e, 2 );
            weapon_id = tableLookup( "gamedata/stats/zm/zm_statstable.csv", 0, e, 4 );

            if( weapon_categ == "weapon_" + weapon_types[i] )
            {
                if( IsInArray(weapNames, weapon_id) )
                {
                    weapon      = spawnStruct();
                    weapon.name = MakeLocalizedString( getWeapon( weapon_id ).displayname );
                    weapon.id   = weapon_id;
                    level.weapons[i][level.weapons[i].size] = weapon;
                }
            }
        }
    }

    level getMiscWeapons();

    attachment_types = ["rig", "optic", "mod"];
    level.attachments = [];
    for(i=0;i<attachment_types.size;i++)
    {
        level.attachments[i] = [];
        for(e=0;e<43;e++)
        {
            attachment_categ = tableLookup( "gamedata/weapons/common/attachmenttable.csv", 0, e, 2 );
            attachment_name = TableLookupIString( "gamedata/weapons/common/attachmenttable.csv", 0, e, 3 );
            attachment_id = tableLookup( "gamedata/weapons/common/attachmenttable.csv", 0, e, 4 );

            if( attachment_categ == attachment_types[i] )
            {
                attachment = spawnStruct();
                attachment.name = attachment_name;
                attachment.id = attachment_id;

                level.attachments[i][level.attachments[i].size] = attachment;
            }
        }
    }

    level.music_tracks = [];
    level.music_names = [];
    for(e=0;e<98;e++)
    {
        track_id = tableLookup( "gamedata/tables/common/music_player.csv", 0, e, 1 );
        track_name = TableLookup( "gamedata/tables/common/music_player.csv", 0, e, 2 );
        level.music_tracks[e] = track_id;
        level.music_names[e] = track_name;
    }

    level.gobble_gums = getArrayKeys(level.bgb);
    level.gobble_gums_name = [];
    for(e=0;e<level.gobble_gums.size;e++)
        level.gobble_gums_name[e] = constructString( replaceChar( getSubStr(level.gobble_gums[e], 7), "_", " ") );
}

load_presets()
{
    self.presets = [];
    
    self.presets["X"] = 145;
    self.presets["Y"] = -114;
    
    self.presets["OUTLINE"] = get_preset("OUTLINE");
    self.presets["TITLE_OPT_BG"] = get_preset("TITLE_OPT_BG");
    self.presets["SCROLL_STITLE_BG"] = get_preset("SCROLL_STITLE_BG");
    self.presets["TEXT"] = get_preset("TEXT");
}

get_preset( preset )
{
    if( preset == "OUTLINE" )
        return (0,0,0);
    if( preset == "TITLE_OPT_BG" )
        return rgb(19,18,20);
    if( preset == "SCROLL_STITLE_BG" )
        return rgb(62,58,63); //"rainbow";
    if( preset == "TEXT" )
        return (1,1,1);
    if( preset == "X" )
        return 0;
    if( preset == "Y" )
        return 0;    
}
