menuOptions()
{
    player = self.selected_player;        
    menu = self getCurrentMenu();

    map = getMapName();

    perk_keys = getPerks();
    powerups  = getArrayKeys(level.zombie_include_powerups);
    powerups[powerups.size] = "Spawn All";

    powerup_names = [];
    for(e=0;e<powerups.size;e++)
        powerup_names[e] = constructString( replaceChar(powerUps[e], "_", " ") );

    player_names = [];
    foreach( players in level.players )
        player_names[player_names.size] = players.name;

    attachment_categories = ["Rig", "Optic", "Mod"];
    str_names = ["Boxer", "Detective", "Femme", "Magician", "PAP"];    

    switch( menu )
    {
        case "main":
        {
            self addMenu( "main", "Default Submenus" );
                self addOpt("spawn_mechz", ::spawn_mechz);
                

                self addOpt( "Basic Options", ::newMenu, "basicOpts" );
                self addOpt( "Fun Options", ::newMenu, "funOpts" );
                self addOpt( "Advanced Options", ::newMenu, "advancedOpts" );
                self addOpt( "Entity Options", ::newMenu, "entityOpts" );
                self addOpt( "Spawnable Options", ::newMenu, "spawnables" );
                self addopt( "Teleport Options", ::newmenu, "teleportOpts" );
                self addOpt( "Weaponry Options", ::newMenu, "weaponryOpts" );

                self addOpt( "Bullet Options", ::newMenu, "bulletOpts" );
                self addOpt( "C.Bullet Options", ::newMenu, "cBulletOpts");

                self addOpt( "Aimbot Options", ::newMenu, "aimbotOpts" );
                self addOpt( getMapName() + " Options", ::newMenu, "mapOpts" );
                self addOpt( "Server Options", ::newMenu, "serverOpts" );
                self addOpt( "Server Tweakables", ::newMenu, "serverTweaks" );
                self addOpt( "Account Options", ::newMenu, "accOpts" );
                self addOpt( "Menu Customization", ::newMenu, "customization" );     
                self addOpt( "Clients Menu", ::newMenu, "clients" );
        }
        /* BASIC OPTIONS */
        case "basicOpts":
        {
            self addMenu( "basicOpts", "Basic Options" );  
                self addToggle( "Godmode", player.godmode, ::godmode );
                self addToggle( "Demi-Godmode", player.demiGodmode, ::demiGodmode );
                self addToggle( "Noclip Bind [{+frag}]", player.noclipBind, ::noClipExt );
                self addToggle( "UFO Mode", player.ufo_mode, ::ufomode );
                self addToggle( "Third Person", player.thirdPerson, ::thirdperson );
                self addToggle( "Invisibility", player.invisibility, ::invisibility );
                self addSliderString( "Infinite Ammo", "Continuous;Reload", undefined, ::infiniteAmmo );
                self addToggle( "Infinite Equipment", player.infEquip, ::infiniteEquip );
                
                self addOpt( "Edit Score", ::newMenu, "scoreOpts" );
                self addOpt( "Edit Perks", ::newmenu, "editPerks" );
                self addOpt( "Edit Visions", ::newMenu, "visionOpts" );
                
                self addSliderString( "Gobble Gums", level.gobble_gums, level.gobble_gums_name, ::give_gobble_gum );
                self addSliderString( "Music Player", level.music_tracks, level.music_names, ::music_player );
                self addSliderString( "Change Appearances", "0;1;2;3;4;5;6;7;8", "Dempsey;Nikolai;Richtofen;Takeo;Shadow of Evil Beast;Floyd Campbell;Jack Vincent;Jessica Rose;Nero Blackstone", ::changeAppearance, true );
                self addToggle( "Cycle Appearances", player.cycleAppearance, ::cycleAppearance );
                self addSliderString( "Clone", "Clone;Dead;Statue", undefined, ::clone );
                self addSliderValue( "Player Speed", 1, .5, 5, .5, ::set_movement_speed );
                self addToggle( "Auto Revive", player.auto_revive, ::auto_revive );
                self addToggle( "Commit Suicide", !_isAlive( player ), ::commitSuicide );
                self addToggle( "Player Respawn", _isAlive( player ), ::respawn_player );
                self addToggle( "Health Bar", player.health_bar , ::do_health_info );
                self addToggle( "Explosive Damage", !isDefined(player.noExplosiveDamage), ::no_explosive_damage );
        }
        case "scoreOpts":
        {
            self addMenu( "scoreOpts", "Score Options" );
                self addSliderValue( "Add Points", 1000, 1000, 10000, 1000, ::editPoints );
                self addSliderValue( "Remove Points", 1000, 1000, 20000, 1000, ::editPoints, true );
                self addToggle( "Max Points", player.score >= 4190000, ::editPoints, 4190000 );
                self addToggle( "Reset Points", player.score == 0, ::editPoints, player.score, true );
                self addToggle( "Money Drop", player.money_drop, ::money_drop );
                self addToggle( "Money Gun", player.money_gun, ::money_gun );
        }
        case "visionOpts":
        {
            self addMenu( "visionOpts", "Visions" );
                if(!IsDefined( player.current_vision ))
                    player.current_vision = "none";
                    
                foreach( type, v_array in level.vsmgr )
                {
                    foreach( v_name, v_struct in level.vsmgr[ type ].info )
                    {
                        vision = level.vsmgr[ type ].info[ v_name ];
                        if( vision.State.should_activate_per_player )
                        {
                            o_name = constructString( replaceChar(vision.name, "_", " ") ); 
                            if( IsSubStr(o_name, "Zm") )
                                o_name = GetSubStr( o_name, 3 );
                            if( IsSubStr(o_name, "Bgb") )
                                o_name = GetSubStr( o_name, 4 );
                            self addToggle( o_name, player.current_vision == vision.name, ::set_vision, vision.type, vision.name );
                        }
                    }
                }
        }
        /* PERK OPTIONS */
        case "editPerks":
        {
            self addmenu( "editPerks", "Edit Perks" );
            self addToggle( "All Perks", player hasAllPerks(), ::setAllPerks );
            
            for(e=0;e<perk_keys.size;e++)
            {
                perk_id = perk_keys[e];
                self addToggle( getPerkName( perk_id ), player hasPerk( perk_id ), ::_setPerkFunction, perk_id );   
            }
        }
        /* FUN OPTIONS */
        case "funOpts":
        {
            self addMenu( "funOpts", "Fun Options" );    
                self addToggle( "Zombies Ignore", player.ignoreme, ::noTarget );
                self addToggle( "Explosive Melee", player.explosive_melee, ::explosive_melee );
                self addToggle( "Shield Protector", player.shieldProtector, ::shieldProtector );
                if(isDefined( GetWeapon( "riotshield" ).worldmodel ))
                    self addToggle( "Riot Smash", player.riotSmash, ::riotSmash );
                self addToggle( "Cluster Grenades", player.cluster, ::clusterGrenade );
                self addToggle( "Gravity Gun", player.gravityGun, ::gravitygun );
                self addToggle( "Advanced Forge", player.forge_mode, ::adv_forge_mode );
                self addToggle( "Light Protector", player.light_protector_active, ::light_protector );

                self addSliderValue( "Modded Spread", 0, 0, 9, 1, ::moddedSpread ); 
                self addSliderString( "Spawn Powerup", powerups, powerup_names, ::spawnPowerup );
                self addToggle( "Shoot Powerups", player.shoot_powerups, ::toggle_shoot_powerups );
                self addToggle( "Sky Trip", player.skytrip, ::skyTrip );
                self addToggle( "Kill Text", player.killtxt, ::toggleKillText ); 
                self addToggle( "Auto Bunny Hop", player.bunny_hop, ::auto_bunny_hop );
                self addToggle( "Frog Jump", player.frog_jump, ::frog_jump );
                
                //self addToggle( "Buckshot Mod", player.buckshot_missile, ::toggleBuckshot );
                
                self addToggle( "Auto Detonate Projectiles", player.auto_detonate_projectiles, ::auto_detonate_projectiles );
                self addToggle( "Auto Detonate Grenades", player.auto_detonate_grenades, ::auto_detonate_grenades );
                
                self addSliderValue( "Edit Jump Height", 0, 0, 9, 1, ::superJump );
                self addSliderValue( "Edit Multi-Jump", 0, 0, 9, 1, ::multiJump );

                self addToggle( "Exo Suits", player.exo_suits, ::exo_suits ); 
                self addToggle( "Moon Gravity", player.moon_gravity, ::moon_gravity );
                self addToggle( "Zombie Teleport Grenades", player.zombie_tele_grenade, ::teleport_zombies_grenade );

                if( map == "Shadows Of Evil" || map == "Origins" )
                    self addSliderString( "Jumpscare", player_names, undefined, ::do_jumpscare, map );

                self addToggle( "Electric Cherry v1", isDefined( player.electric_cherry ) && player.electric_cherry == "v1", ::toggle_electric_cherry, "v1" );
                self addToggle( "Electric Cherry v2", isDefined( player.electric_cherry ) && player.electric_cherry == "v2", ::toggle_electric_cherry, "v2" );
                
                self addOpt( "Custom Zombie Ragdoll", ::newMenu, "customRagdoll" );
                self addOpt( "Custom Damge Knockback", ::newMenu, "customKnockback" );
                
                self addToggle( "Ricochet Bullets", player.ricochetBullet, ::toggleRicochetBullets );
                self addToggle( "Cod Jumper", player.codJumper, ::codJumper );
                self addToggle( "Extra Gore", player.extra_gore, ::extra_gore );
                self addToggle( "Spectate Grenades", player.spec_nade, ::spec_nade );
                
                self addToggle( "Auto Revive Gun", player.auto_revive_gun, ::auto_revive_gun );
        }
        case "customRagdoll":
        {
            self addMenu( "customRagdoll", "Custom Zombie Ragdoll" );
                self addToggle( "Custom Zombie Ragdoll", player.custom_ragdoll, ::zombie_custom_ragdoll );
                self addSliderValue( "Ragdoll Force", 200, 0, 400, 20, ::set_ragdoll_force );
                self addSliderValue( "Ragdoll Height", 20, 0, 200, 20, ::set_ragdoll_height );
        }
        case "customKnockback":
        {
            self addMenu( "customKnockback", "Custom Zombie Knockback" );
                self addToggle( "Custom Damage Knockback", player.knockback_zombies, ::player_knockback_zombies );
                self addSliderValue( "Knockback Force", 400, 100, 1000, 20, ::set_knockback_force );
                self addSliderValue( "Knockback Height", 100, 100, 1000, 20, ::set_knockback_height );
        }   
         
        /* ADVANCED OPTIONS */
        case "advancedOpts": 
        {
            self addMenu( "advancedOpts", "Advanced Options" );
                self addToggle( "Body Guard Zombie", player.body_guard_active, ::toggle_body_guard ); 
                self addToggle( "Perk Circle", level.perk_circle, ::toggle_perk_circle );
                self addToggle( "Gumball Circle", level.bgb_circle, ::toggle_bgb_circle );
                if( map != "Shadows Of Evil" && map != "Verruckt" )
                    self addToggle( "Teleport Pack-A-Punch", level.custom_pap, ::teleport_pap );
                self addSliderString( "Zombie Charms", array(0,1,2,3,4), array("Default", "Orange", "Green", "Purple", "Blue"), ::do_zombie_colour );    
                self addToggle( "Napalm Zombies", isDefined(level.napalm_zombies), ::toggle_napalm_zombies );

                valid_maps = ["Revelations", "Gorod Krovi", "Der Eisendrache", "Origins"];
                if( isInArray(valid_maps, map) )
                    self addToggle( "Sparky Zombies", isDefined(level.sparky_zombies), ::toggle_sparky_zombies );
                
                //if( BulletTracePassed( player.origin, player.origin + (0,0,9999), false, player ) ) 
                self addToggle( "Circling AC130", player.isInAc130, ::Ac130 );
                self addToggle( "Walking AC130", player.isInAc130, ::Ac130, true );
                
                self addToggle( "Valkyrie Missile", player.isInValkyie, ::valkyrieMissile );
                
                self addToggle( "Missile Barrage", player.isMissleBarrage, ::missile_barrage );
                self addToggle( "Controllable Zombie", player.isControllableZombie, ::spawn_controllable_zombie );
                self addToggle( "Gravity Missiles", player.gravity_missile, ::gravity_missile );
                self addToggle( "Powerup Magnet", player.powerup_magnet, ::powerup_magnet );
        }
        /* ENTITY OPTIONS */
        case "entityOpts":
        {
            self addmenu( "entityOpts", "Entity Options" );
                self addOpt( "Spawn Script Model", ::newMenu, "SCRIPT_MODELS" );
                self addOpt( "Place Script Model", ::placeModel );
                self addOpt( "Copy Script Model", ::copyModel );
                self addOpt( "Rotate Script Model", ::newMenu, "ROTATE_MODELS" );
                self addOpt( "Scale Script Model", ::newMenu, "SCALE_MODELS" );
                self addOpt( "Delete Script Model", ::deleteModel );
                self addOpt( "Undo Last Spawn", ::modelUndo );
                self addOpt( "Entity Distance", ::newMenu, "MODEL_DISTANCE" );
                self addToggle( "Ignore Collisions", player.ignoreCollisions, ::ignoreCollisions );
                self addopt( "Delete All Spawned", ::deleteAllSpawned );
        }
        case "ROTATE_MODELS":       
        {
            self addmenu( "ROTATE_MODELS", "Rotate Script Model" );
                self addOpt( "Reset Angles", ::resetmodelangles, 0, 0, 0 );
                self addOpt( "Rotate Pitch +", ::rotatemodel, 0, 1 );
                self addOpt( "Rotate Pitch -", ::rotatemodel, 0, -1 );
                self addOpt( "Rotate Yaw +", ::rotatemodel, 1, 1 );
                self addOpt( "Rotate Yaw -", ::rotatemodel, 1, -1 );
                self addOpt( "Rotate Roll +", ::rotatemodel, 2, 1 );
                self addOpt( "Rotate Roll -", ::rotatemodel, 2, -1 );
        }  
        case "SCALE_MODELS":       
        {
            self addmenu( "SCALE_MODELS", "Scale Script Model" );
            self addToggle( "Reset Scaling", (player.modelScale == 1), ::modelScale );        
            self addSliderValue( "Set Scaling", 1, 1, 9, 1, ::modelScale );
        } 
        case "SCRIPT_MODELS": 
        {    
            self addmenu( "SCRIPT_MODELS", "Spawn Script Model" );
            spawned_ents = [];
            foreach( ent in GetEntArray() )
            {
                if( isDefined( ent.model ) && ent.model != "" && !isInArray( spawned_ents, ent.model ) )
                {
                    spawned_ents[ spawned_ents.size ] = ent.model;
                    self addOpt( ent.model, ::spawnModel, ent.model ); 
                }
            }
        }       
        case "MODEL_DISTANCE":
        {
            self addmenu( "MODEL_DISTANCE", "Entity Distance" );
                self addToggle( "Reset Distance", (player.modelDistance == 180), ::modelDistance );        
                self addSliderValue( "Inc Distance", 10, 0, 100, 10, ::modelDistance );
                self addSliderValue( "Dec Distance", 10, 0, 100, 10, ::modelDistance, true );
        }
        /* SPAWNABLE OPTIONS */ 
        case "spawnables":
        {
            self addMenu( "spawnables", "Spawnables" );
                self addOpt( "Spawnable Rides", ::newMenu, "rides" );
                self addOpt( "Spawnable Effects", ::newMenu, "effects" );
                self addOpt( "Other Spawnables", ::newMenu, "otherSpawnables" );
        }   
        case "rides":
        {
            self addMenu( "rides", "Spawnable Rides" );
                self addToggle( "The Claw", level.claw_spawned, ::toggle_claw_spawn );
        }
        case "otherSpawnables":
        {   
            self addMenu( "otherSpawnables", "Other Spawnables" );
                //self addOpt( "Basic Bunker", ::newMenu, "basicBunker" );
                if(map == "The Giant")
                    self addOpt( "Fortress Options", ::newMenu, "fortress" );

                //self addToggle( "Trade Weapon Table", self.trade_table, ::trade_weap_table );
                self addSliderValue( "Mexican Wave", 3, 3, 15, 1, ::spawn_mexican_wave ); 
                /*self addSliderString( "Spawn Sphere", "medium;large", "Medium;Large", ::customizeSphere );
                self addToggle( "Spawn Blackhole", level.blackhole, ::spawn_blackhole );*/ 
                self addSliderString( "3D FX Text", "powerup_on_caution;powerup_on;powerup_on_solo", "Yellow;Green;Blue", ::spawn_3D_fx );
                self addSliderValue( "Spiral Staircase", 3, 0, 30, 1, ::spiralStaircase );
                self addOpt( "Ziplines", ::newMenu, "ziplines" );
        } 
        case "fortress":
        {
            self addMenu( "fortress", "Fortress Options");
                self addToggle( "Spawn Fortress", isDefined( level.fortress_built ), ::toggle_fortress );
                self addToggle( "Open All Windows", isDefined(level.fortress_windows) && level.fortress_windows, ::open_fortress_windows );
                self addOpt( "Teleport To Fortress", ::teleport_to_fortress );
        }
        case "ziplines":
        {
            self addMenu( "ziplines", "Zipline Spawns" );
                self addToggle( "Spawn Zipline 1", isDefined( level.ziplines[0] ), ::create_zipline, 0 );
                self addToggle( "Spawn Zipline 2", isDefined( level.ziplines[1] ), ::create_zipline, 1 );
        }
        case "effects":
        {
            self addMenu( "effects", "Spawnable Effects" );
                self addOpt( "Effects List", ::newMenu, "effectList" );
                self addSliderValue( "Effects Distance", 100, 50, 1000, 50, ::fx_distance );
                self addToggle( "Reset Effect Distance", (player.fxDistance == 100), ::fx_distance, 100 );   
                self addToggle( "Delete All Effects", level.SpawnedFx.size > 0, ::spawn_Fx, undefined, true );  
        }
        case "effectList":
        {    
            effects = getArrayKeys(level._effect);    
            self addMenu("effectList", "Effects List");
            for(e=0;e<effects.size;e++)
            {
                subStr = GetSubStr(effects[e], 0, 3);
                if( subStr != "fx_" && subStr != "ste" )
                    self addOpt(effects[e], ::spawn_Fx, effects[e]);    
            }
        } 
        /* TELEPORT OPTIONS */
        case "teleportOpts":
        {
            self addmenu( "teleportOpts", "Teleport Options" ); 
                self addopt( "Teleport Options", ::newmenu, "teleOpts" );
                self addopt( "Offical Spawnpoints", ::newmenu, "spawnpoints" );
                if( map == "Kino Der Toten" )
                    self addOpt( "Kino Der Toten Teleports", ::newMenu, "kinoTeleports");
        }   
        case "kinoTeleports":
        {
            self addMenu( "kinoTeleports", "Kino Der Toten Teleports" );
            
            strings = ["ee_teleport_player", "projroom_teleport_player", "theater_teleport_player"];
            for(e=0;e<strings.size;e++)
            {
                foreach( i, loc in get_array_spots( strings[e] ) )
                    self addOpt( constructString( replaceChar( strings[e], "_", " " ) ) + " " + (i + 1), ::advancedtele, loc.origin, loc.angles );
            }
        }
        case "teleOpts":
        {
            self addmenu( "teleOpts", "Teleport Options" );
                self addOpt( "Self Tele Options", ::newMenu, "selfTeleOpts" );
                self addOpt( "Team Tele Options", ::newMenu, "teamTeleOpts" );
        } 
        case "selfTeleOpts":  
        { 
            self addMenu( "selfTeleOpts", "Self Tele Opts" );
                self addToggle( "Cinematic Teleport", player.cinematicTele, ::cinematictele );
                self addToggle( "Save Position", (isDefined(player.posSaved)), ::savepos );
                self addToggle( "Load Position", (!isDefined(player.posSaved)), ::loadpos );
                self addToggle( "Save And Load Bind", player.saveLoad, ::saveloadbind );
                self addSliderString( "Tele To Crosshair", returnlist( 100, 2000, 100 ) + ";Max", undefined, ::telecrosshair );
        }  
        case "teamTeleOpts":   
        {
            self addMenu( "teamTeleOpts", "Team Tele Opts" );   
                self addSliderString( "Teleport To", "Closest;Random", undefined, ::teleRandomPers );
                self addSliderString( "Teleport To Me", "Closest;Everyone", undefined, ::allToMe );
                self addSliderString( "Tele To Crosshair", "Closest;Everyone", undefined, ::allToMe, 1 );
        }
        case "spawnpoints":   
        {
            self addmenu( "spawnpoints", "Spawnpoints" );
                self addopt( "Random Spawn", ::teleporttorandomspawn );

            points = level.spawnPoints;
            for(e=0;e<points.size;e++)
            {
                string = getSubStr( zm_zonemgr::get_zone_from_position( points[e].origin, 1 ), 5 );
                if(isdefined( string ))
                    self addopt( constructString( replaceChar( string, "_", " " ) ), ::advancedtele, points[e].origin, points[e].angles );
            }
        }   
        /* WEAPONRY OPTIONS */ 
        case "weaponryOpts":   
        {
            self addMenu( "weaponryOpts", "Weaponry Options"); 
                self addOpt( "Weapons", ::newMenu, "giveWeaps" );
                self addOpt( "Attachments", ::newMenu, "giveAttach" );
                self addSliderValue( "Set Weapon Limit", 2, 2, 16, 1, ::setWeaponLimit );
                self addSliderValue( "Set Camo", 0, 0, 138, 1, ::setCamo, undefined, true );
                self addSliderString( "P.A.P Ability", "zm_aat_blast_furnace;zm_aat_dead_wire;zm_aat_fire_works;zm_aat_thunder_wall;zm_aat_turned", "Blast Furnace;Dead Wire;Fireworks;Thunder Wall;Turned", ::acquireaat );
                self addToggle( "Instant Give Weapon", player.instantWeap, ::instantgiveweapon );
                self addToggle( "Upgrade Weapon", player.upgrade_weapon, ::upgradeWeapons );
                self addToggle( "Drop Weapon", player.dropWeap, ::dropweapons );
                self addToggle( "Weapon Camo Loop", player.camoLoop, ::weaponCamoLoop );
                self addOpt( "Upgrade Current Weapon", ::upgradeCur );

                self addSliderString( "Drop Categories", array(0,1,2,3,4,5,6,7), level.weapon_categories, ::drop_all_weapons );
                self addOpt( "Take Current Weapon", ::takeCur );
                self addOpt( "Drop Current Weapon", ::dropcur );
                self addOpt( "Drop All Weapons", ::allweap, "drop" );
                self addOpt( "Take All Weapons", ::allweap, "take" );
                self addOpt( "Weapon Max Ammo", ::weapmax );
                self addopt( "Reset Weapon", ::resetweap );
        }
        case "giveWeaps":   
        {
            self addMenu( "giveWeaps", "Weapons");
            for(e=0;e<level.weapon_categories.size;e++)
                self addOpt( level.weapon_categories[e], ::newMenu, level.weapon_categories[e] );
        } 
        case "giveAttach": 
        {    
            self addMenu( "giveAttach", "Attachments" );
            for(e=0;e<attachment_categories.size;e++)
                self addOpt( attachment_categories[e], ::newMenu, attachment_categories[e] );
        }  
        /* CUSTOM BULLET OPTIONS */
        case "bulletOpts":
        {
            self addMenu( "bulletOpts", "Bullet Options" );
            
            e_weapons = EnumerateWeapons( "weapon" );
            b_weapons = ["_ricochet", "syrette", "special_crossbow", "buildable_"];
            foreach( item in e_weapons )
            {
                string = MakeLocalizedString( item.displayname );
                if( string != "" )
                {
                    foreach( bad_weapon in b_weapons )
                    {
                        if( IsSubStr( toLower( item.name ), bad_weapon ) )
                            continue 2;
                        if( IsSubStr( toLower( item.name ), "idgun" ) && !IsSubStr( toLower( item.name ), "upgraded" ))
                            continue 2;
                    }

                    // WEAPON NAME FIX [ USING STRING MAKES IT EASIER TO FIX ]
                    if( string == "ZMWEAPON_RAYGUN_MARK3" )                          { string = "Ray Gun Mark 3";        }
                    if( string == "WEAPON_SPIKE_CHARGE" )                            { string = "Charge Spike Harpoon";  }
                    if( toLower( item.name ) == "sticky_grenade_widows_wine" )       { string = "Widows Wine Grenade";   }
                    if( toLower( item.name ) == "spike_charge_siegebot" )            { string = "Spike Charge Siegebot"; }
                    if( toLower( item.name ) == "hero_gravityspikes" )               { string = "Spike Charge";          }
                    if( toLower( item.name ) == "claymore" )                         { string = "Claymore";              }

                    if( item.type == "projectile" )
                        self addToggle( string, player.gCustom_bullet == item.name, ::do_modded_bullet, item.name );
                    else if( item.type == "grenade" )
                        self addToggle( string, player.gCustom_bullet == item.name, ::do_modded_bullet, item.name, true );
                }
            }
        }
        /* CUSTOM BULLET OPTIONS */
        case "cBulletOpts":
        {
            effects     = [];
            effect_ids  = [];

            models      = "none;p7_zm_power_up_insta_kill;p7_zm_power_up_nuke;p7_zm_teddybear";
            real_models = "NONE;Skull;Nuke;Teddy Bear";
            sounds      = "zmb_vocals_zombie_death_whimsy;zmb_cha_ching;zmb_laugh_child;zmb_spawn_powerup;wpn_grenade_explode";                                                                                 
            real_sounds = "Funny Sound;Cah-Ching;Samantha Laugh;Power Up Spawn;Grenade Exp";
            list        = array("chest_light", "zombie_guts_explosion", "powerup_on", "powerup_off", "powerup_grabbed", "powerup_on_solo", "powerup_grabbed_solo", "powerup_on_caution", "powerup_grabbed_caution", "samantha_steal");
           
            for(e=0;e<list.size;e++)
            {
                if(!isDefined( level._effect[list[e]] ))
                    continue;
                effects[e] = constructString( replaceChar(list[e], "_", " ") );
                effect_ids[e] = level._effect[list[e]];
            }

            self addMenu( "cBulletOpts", "Bullet Options" );
            self addToggle( "Custom Bullets", player.custom_bullet, ::do_custom_bullet );
            self addSliderString( "Bullet Model", models, real_models, ::define_customs, 0 );
            self addSliderValue( "Bullet Speed", 1, 1, 9, 1, ::define_customs, 1 );
            self addSliderString( "Impact FX", effect_ids, effects, ::define_customs, 2 );
            self addSliderValue( "Bullet Timeout", 0.5, 0.5, 5, 0.5, ::define_customs, 3 );
            self addSliderString( "Trail FX", effect_ids, effects, ::define_customs, 4 );
            self addSliderValue( "Trail Wait", 0.05, 0.05, 0.50, 0.05, ::define_customs, 5 );
            self addSliderString( "Firing Sound", sounds, real_sounds, ::define_customs, 6 );
            self addSliderString( "Impact Sound", sounds, real_sounds, ::define_customs, 7 );
            self addSliderValue( "EQ Scale", 1, 0, 9, 1, ::define_customs, 8 );
            self addSliderValue( "EQ Time", 1, 0, 9, 1, ::define_customs, 9 );
            self addSliderValue( "EQ Radius", 50, 0, 600, 50, ::define_customs, 10 );
            self addSliderValue( "Damage Radius", 50, 0, 500, 50, ::define_customs, 11 );
            self addSliderValue( "Max Damage", 50, 0, 500, 50, ::define_customs, 12 );
            self addSliderValue( "Min Damage", 50, 0, 500, 50, ::define_customs, 13 );
        }
        /* AIMBOT OPTIONS */
        case "aimbotOpts":
        {
            self addMenu( "aimbotOpts", "Aimbot Options" );
                self addOpt( "Preset Aimbots", ::newMenu, "presetAimbots" );
            
                self addToggle( "Aimbot", player.aimbotT, ::toggleAimbot);
                self addToggle( "Ground Check", player.aimbot["groundCheck"], ::aimbotChecks, "groundCheck", 2 );
                self addToggle( "Visible Check", player.aimbot["visibleCheck"], ::aimbotChecks, "visibleCheck", 3 );
                self addToggle( "Crosshair Check", player.aimbot["realisticCheck"], ::aimbotChecks, "realisticCheck", 4 );
                self addToggle( "Lock On Check", player.aimbot["lockOnCheck"], ::aimbotChecks, "lockOnCheck", 5 );
                self addToggle( "Auto Shoot Check", player.aimbot["autoShootCheck"], ::aimbotChecks, "autoShootCheck", 6 );
                self addToggle( "Unfair Mode", player.aimbot["unfairCheck"], ::aimbotChecks, "unfairCheck", 7 );
                self addSliderValue( "Crosshair Size", 5, 10, 100, 5, ::realisticRange );
                self addToggle( "Ads Check", player.aimbot["adsCheck"], ::aimbotChecks, "adsCheck", 9 );
        }  
        case "presetAimbots":
        {
            self addMenu( "presetAimbots", "Aimbot Options" );
            self addToggle( "Smooth Aimbot", player.smoothaim, ::toggle_smooth_aim ); 
            self addToggle( "Projectile Aimbot", player.projectileAim, ::toggle_projectile_aim ); 
        }
        /* <MAP> OPTIONS */  
        case "mapOpts":
        {
            self addMenu( "mapOpts", map + " Options" );

            if( !level flag::get("power_on") || !level flag::get( "all_power_on" ) && getMapName() == "Revelations" )
                self addToggle( "Activate Power", false, ::_enable_Power );
            if(!isDefined(level.all_parts_required) && isDefined( level.zombie_include_craftables ) && level.zombie_include_craftables.size > 1)
                self addToggle( "Grab All Parts", level.all_parts_required, ::grab_all_parts );

            if(map == "Origins")
            {
                self addToggle( "Capture All Generators", level clientfield::get("zone_capture_hud_all_generators_captured"), ::set_captured_zones );
                self addSliderString( "Pickup Crystal", "Fire;Air;Lightning;Water", undefined, ::pickup_crystal );
            }

            if( !isDefined( level.all_doors_open ) && !moon_doors_supported() )
                self addToggle( "Open All Doors", level.all_doors_open, ::open_all_doors );
            if( moon_doors_supported() )
            {
                self addToggle( "Open All Doors", level.all_doors_open, ::toggle_door_state );
                self addToggle( "All Moon Doors", level.moon_doors, ::toggle_moon_doors );
            }

            self addOpt( "Spawner Options", ::newMenu, "spawnerOpts" );
            self addOpt( "Mystery Box Options", ::newMenu, "boxOpts" );
            self addOpt( "Power Up Options", ::newMenu, "powerupOpts" );
            
            self addToggle( "Free Wallbuys", level.free_wallbuys, ::free_wallbuys );
            self addToggle( "Free Perk Machines", level.free_perkmachines, ::free_perkmachines );

            if(map == "Shadows Of Evil")
            {
                if( !isDefined( level.all_smashables_open ) )
                    self addToggle( "Open All Smashables", level.all_smashables_open, ::open_all_smashables );

                if( !isDefined( level.all_electrics_open ) )
                    self addToggle( "Turn On All Electrics", level.all_electrics_open, ::shock_all_electrics );
                
                self addOpt( "Quest Pickups", ::newMenu, "questGrabs" );

                if( !level flag::get("ritual_pap_complete") )
                {
                    self addSliderString( "Complete Ritual", str_names, undefined, ::complete_ritual );
                    self addToggle( "Complete All Rituals", level flag::get("ritual_pap_complete"), ::complete_all_rituals );
                }

                if( level clientfield::get("keeper_quest_state_" + player.characterindex) != 8 )
                    self addToggle( (player.var_15954023.var_b8ad68a0 == 0 ? "Complete" : "Upgrade") + " Sword Quest", player.complete_sword_quest, ::complete_sword_quest );

                self addSliderString( "Give Sword", "glaive_apothicon;glaive_keeper", "Apothicon;Keeper", ::give_special_sword );

                if(!isDefined( level.ee_complete ))
                    self addToggle( "Complete Easter Egg", level.ee_complete, ::do_soe_ee );
                self addSliderString( "EE Complete Effects", "Enable;Disable", undefined, ::EE_Complete_Effects );
            }
        }
        /* QUEST GRAB OPTIONS */
        case "questGrabs": 
        {
            self addMenu( "questGrabs", "Quest Pickups" );

            self addToggle( "Grab Summoning Key", !level.var_c913a45f && isDefined( level.var_c913a45f ), ::grab_quest_key );
            self addToggle( "Grab Fumigator", player.var_abe77dc0, ::grab_fumigator );

            foreach( index, string in Array("Championship Belt", "Cops Badge", "Hair Piece", "Golden Fountain Pen") )
                self addToggle( string, level flag::get("memento_" + toLower( str_names[index] ) + "_found"), ::grab_ritual_part, toLower( str_names[index] ) );
        }
        /* SPAWNER OPTIONS */
        case "spawnerOpts":
        {
            self addMenu( "spawnerOpts", "Spawner Options" );

            /* disable special rounds */
            if( isDefined( level.next_wasp_round ))     self addToggle( "Disable Wasp Round",      level.next_wasp_round    == 999, ::disable_special_round, "wasp" );
            if( isDefined( level.n_next_raps_round ))   self addToggle( "Disable Raps Round",      level.n_next_raps_round  == 999, ::disable_special_round, "raps" );
            if( isDefined( level.next_dog_round ))      self addToggle( "Disable Dog Round",       level.next_dog_round     == 999, ::disable_special_round, "dog" );
            if( isDefined( level.next_monkey_round ))   self addToggle( "Disable Monkey Round",    level.next_monkey_round  == 999, ::disable_special_round, "monkey" );
            if( isDefined( level.next_thief_round ))    self addToggle( "Disable Thief Round",     level.next_thief_round   == 999, ::disable_special_round, "thief" );
            if( isDefined( level.next_mechz_round ))    self addToggle( "Disable Mechz Round",     level.next_mechz_round   == 999, ::disable_special_round, "mechz" );
            if( isDefined( level.next_astro_round ))    self addToggle( "Disable Astro Round",     level.next_astro_round   == 999, ::disable_special_round, "astro" );
            if( isDefined( level.var_a78effc7 ))        self addToggle( "Disable Sentinel Round",  level.var_a78effc7       == 999, ::disable_special_round, "sentinel" );
            if( isDefined( level.var_51a5abd0 ))        self addToggle( "Disable Manglers Round",  level.var_51a5abd0       == 999, ::disable_special_round, "mangler" );

            self addSliderValue( "Spawn Zombies", 1, 1, 10, 1, ::spawn_zombies );
            valid_maps = ["Shadows Of Evil", "Revelations"];
            if( isInArray(valid_maps, map) )
            {
                self addSliderValue( "Spawn Margwas", 1, 1, 10, 1, ::spawn_margwas );
                self addSliderValue( "Spawn Wasps", 1, 1, 10, 1, ::special_wasp_spawn );
            }

            valid_maps = ["Der Eisendrache", "Revelations", "Origins"];
            if( isInArray(valid_maps, map) )
            {
                self addSliderValue( "Spawn Mechz", 1, 1, 10, 1, ::spawn_mechz );    
            }

            valid_maps = ["Shadows Of Evil", "Revelations", "Gorod Krovi"];
            if( isInArray(valid_maps, map) )
                self addSliderValue( "Spawn Raps", 1, 1, 10, 1, ::spawn_raps );

            valid_maps = ["Shi No Numa", "The Giant", "Kino Der Toten", "Moon", "Der Eisendrache"];
            if( isInArray(valid_maps, map) )
                self addSliderValue( "Spawn Hellhounds", 1, 1, 10, 1, ::special_dog_spawn );

            if( map == "Gorod Krovi" )
            {
                self addSliderValue( "Spawn Sentinel Drones", 1, 1, 10, 1, ::special_sentinel_spawn );
                self addSliderValue( "Spawn Manglers", 1, 1, 10, 1, ::special_mangler_spawn );
            }
        }
        /* BOX OPTIONS */
        case "boxOpts":
        {
            self addMenu( "boxOpts", "Mystery Box Options" );
            self addOpt( "Edit Box Weapons", ::newMenu, "boxWeapons" );
            
            self addSliderValue( "Mystery Box Price", 950, 0, 2500, 10, ::mystery_box_price );
            
            self addToggle( "PAP Mystery Box Weapons", level.mystery_box_pap, ::mystery_box_pap );
            self addToggle( "Show All Mystery Boxes", level.show_all_boxes, ::toggle_all_boxes );
            self addToggle( "Teleport Mystery Box", level.custom_chest, ::teleport_box );
            self addToggle( "Move Mystery Box", level flag::get("moving_chest_now"), ::move_magic_box );
            self addToggle( "Disable Teddybear", GetDvarString("magic_chest_movable") == "0", ::disable_joker );
        }
        /* BOX WEAPONS */
        case "boxWeapons":
        {
            self addMenu( "boxWeapons", "Edit Box Weapons" );
            for(e=0;e<level.weapon_categories.size;e++)
                self addOpt( level.weapon_categories[e], ::newMenu, level.weapon_categories[e] );
        }
        /* POWER UP OPTIONS */    
        case "powerupOpts":
        {
            self addMenu( "powerupOpts", "Power Up Options" );
            self addToggle( "Increased Powerup Droprate", level.zombie_drop_powerup, ::zombies_drop_powerups );
            for(index=0;index<powerups.size-1;index++)
            {
                powerup = level.zombie_powerups[ powerups[index] ].func_should_drop_with_regular_powerups;
                self addToggle( "Enable " + powerup_names[index], [[ powerup ]](), ::disable_powerup, powerups[index] );
            }
        }
        /* SERVER OPTIONS */    
        case "serverOpts":  
        { 
            self addMenu( "serverOpts", "Server Options" );
            self addOpt( "End Game [NUKE!]", ::_nuke_game );
            self addOpt( "Restart Game", ::notify_server_commands, "restart_level_zm" );
            
            if(player isHost()) 
                self addToggle( "Force Host", level.forcehost, ::forceHost );
                
            self addOpt( "Dvar Options", ::newMenu, "dvarOpts" );    
                
            self addToggle( "Disable Zombie Spawns", GetDvarInt("ai_disableSpawn"), ::disable_zombie_spawns );
            self addOpt( "Kill Zombie Wave", ::killAllZombies );
            self addSliderString( "Edit Zombie Barriers", "Repair;Destroy", undefined, ::edit_all_windows );
            self addOpt( "Server Sound Options", ::newMenu, "soundOpts" );

            self addSliderValue( "Set Round", 1, 1, 255, 1, ::_zombie_goto_round );
            self addSliderValue( "All Player Speed", 1, .5, 5, .5, ::edit_all_speed );
            self addSliderValue( "All Jump Height", 0, 0, 9, 1, ::edit_jump_height_all );
            self addToggle( "Freeze Zombies", level.zombies_frozen, ::freeze_zombies );
            self addOpt( "Zombie Gib Options", ::newMenu, "gibZombies" );
            self addSliderString( "Zombie Cycle", "restore;walk;run;sprint;super_sprint", "Restore;Walk;Run;Sprint;Super Sprint", ::set_zombie_cycle );
            self addSliderValue( "Zombie Anim Speed", 1, .5, 2, .1, ::set_zombie_anim_scale );
            self addToggle( "Zombie Eyes", !isDefined(level.remove_zombie_eyes), ::toggle_zombie_eyes );    
            self addOpt( "Bot Options", ::newMenu, "botOpts" );

            self addOpt( "Server Messages", ::newMenu, "doMessages" );
        }
        case "doMessages": 
        {
            //TODO
            self addMenu( "doMessages", "Message Options" );
                self addOpt( "Custom Message", ::queueNotifyMessage ); 
                self addOpt( level.menuName, ::queueNotifyMessage, level.menuName );
                self addOpt( level.players[0] getname() + " is your host today.", ::queueNotifyMessage, level.players[0] getname() + " is your host today." );
                self addOpt( "Hope you're enjoying the lobby.", ::queueNotifyMessage, "Hope you're enjoying the lobby." );
        }
        case "dvarOpts":
        {
            self addMenu( "dvarOpts", "Dvar Options" );
                self addSliderValue("Set Timescale", GetDvarInt("timescale"), .2, 4, .2, ::_setDvar_wrapper, "timescale" );
                self addSliderValue("Set Player Speed", GetDvarInt("g_speed"), 100, 800, 20, ::_setDvar_wrapper, "g_speed" );
                self addSliderValue("Set Player Gravity", GetDvarInt("bg_gravity"), 10, 900, 20, ::_setDvar_wrapper, "bg_gravity" ); 
                self addSliderValue("Set Bleedout Time", GetDvarInt("player_lastStandBleedoutTime"), 0, 120, 5, ::_setDvar_wrapper, "player_lastStandBleedoutTime" );
                self addSliderValue("Set Revive Radius", GetDvarInt("revive_trigger_radius"), 0, 200, 20, ::_setDvar_wrapper, "revive_trigger_radius" );
        }
        case "gibZombies": 
        {
            self addMenu( "gibZombies", "Zombie Gib Options" );
            bodyparts = ["right_arm", "left_arm", "right_leg", "left_leg"];
            foreach( part in bodyparts )
            self addOpt( "Gib " + constructString( replaceChar(part, "_", " ") ), ::_zombie_wrapper_function, ::gibZombie, part );
            
            self addOpt( "Gib Head", ::_zombie_head_gib );
            self addOpt( "Gib Both Legs", ::_makeZombieCrawler );
            self addOpt( "Gib Random Body Part", ::_gib_random_parts );
        }
        /* SOUND OPTIONS */
        case "soundOpts":
        {
            self addMenu( "soundOpts", "Sound Options" );
            self addOpt( "Sound Tracks", ::newMenu, "soundTracks" );
            self addOpt( "Ambient Sounds", ::newMenu, "ambientSounds" );
            if(isdefined(level.sndPlayerVox) && level.sndPlayerVox.size > 0)
                self addOpt( "Audio Quotes", ::newMenu, "audioQuotes" );
        }
        case "soundTracks":
        {
            self addMenu("soundTracks", "Sound Tracks");
            self addOpt("Lobby Tracks", ::newMenu, "lobbyTracks");
            self addOpt("Campaign Tracks", ::newMenu, "campaignTracks");
            self addOpt("Zombie Tracks", ::newMenu, "zombiesTracks");
            self addOpt("Multiplayer Tracks", ::newMenu, "multiplayerTracks");
            
            self addOpt("Perk Machine Tracks", ::newMenu, "perkTracks");
        } 
        case "perkTracks":
        {
            self addMenu("perkTracks", "Perk Machine Tracks");
        
            machines = removeDuplicateEntArray( "zombie_vending" ); 
            for(e=0;e<machines.size;e++)
            {   
                key = machines[e];
                perk = getSubStr( key.script_sound, 10, 14 );
                self addOpt( getPerkName( perk, 1 ) + " Jingle", ::server_musicPlayer, key.script_sound, true );
                self addOpt( getPerkName( perk, 1 ) + " Quote", ::server_musicPlayer, key.script_label, true ); 
            }
        }
        case "ambientSounds":
        {
            self addMenu( "ambientSounds", "Ambient Sounds" );
            foreach( sound in getArrayKeys( level.zombie_sounds ) )
                self addOpt( constructString( replaceChar(sound, "_", " ") ), ::play_zombie_sound, sound );
        }

        /* BOT OPTIONS */
        case "botOpts":
        {
            self addMenu( "botOpts", "Bot Options" );
                self addSliderValue( "Spawn Bots", 1, 1, 3, 1, ::_bot_spawn );
                self addOpt( "Remove All Bots", ::zbot_remove );
                self addOpt( "Give All Random Weapon", ::zbot_give_weapon );
        }
        /* SERVER TWEAKABLES */
        case "serverTweaks":  
        { 
            self addMenu( "serverTweaks", "Server Tweaks" );
                self addSliderString( "Ranked Match", "1;0", "Enable;Disable", ::server_settings, "rankEnabled" );
                self addSliderString( "Friendly Fire", "1;0", "Enable;Disable", ::server_settings, "friendlyfiretype" );
                self addSliderString( "Headshots Only", "1;0", "Enable;Disable", ::server_settings, "onlyheadshots" );
                self addSliderString( "Hitmarkers", "1;0", "Enable;Disable", ::server_settings, "allowhitmarkers" );
                self addSliderString( "Perks Enabled", "1;0", "Enable;Disable", ::server_settings, "perksEnabled" );
                self addSliderString( "Disable Attachments", "1;0", "Enable;Disable", ::server_settings, "disableAttachments" );
                self addSliderString( "Max Health", "10;50;100;150;200;300;400;500", "10;50;Default;150;200;300;400;500", ::server_settings, "playerMaxHealth" );
                self addSliderString( "Heath Regentime", "1;3;5;7;10;12;15", "1;3;Default;7;10;12;15", ::server_settings, "playerHealthRegenTime" );
                self addSliderString( "Force Respawn", "1;0", "Enable;Disable", ::server_settings, "playerForceRespawn" );
                self addSliderValue( "Ammo Clip Multiplier", 1, 1, 10, 1, ::set_clip_muliplier );
                self addSliderValue( "Perk Purchase Limit", 1, 1, level._custom_perks.size, 1, ::set_perk_limit );
        }
        /* ACCOUNT OPTIONS */
        case "accOpts":
        {
            self addMenu( "accOpts", "Account Options" );
                self addOpt("Account Stats", ::newMenu, "accountStats" );
                self addOpt("Account Unlocks", ::newMenu, "accountUnlocks" );
                
                self addOpt("Account Name Colour", ::newMenu, "colouredName" );
                self addOpt("Account Clantag", ::newMenu, "accountClantag" );
        }
        case "accountStats":  
        {
            self addMenu( "accountStats", "Account Stats" );
                self addToggle( "Set Max Level", player getCurrentRank() == ((player.pers["plevel"] > 10 ) ? 1000 : 35), ::addPlayerXP, ((player.pers["plevel"] > 10) ? 1000 : 35) );
                self addSliderValue( "Set Prestige", player.pers["plevel"], 0, 10, 1, ::_setPlayerData, "plevel");
                self addSliderValue( "Set Level", player getCurrentRank(), ((player.pers["plevel"] > 10) ? 36 : 1), ((player.pers["plevel"] > 10) ? 1000 : 35), 1, ::addPlayerXP); 
                self addSliderValue( "Give Liquids", 500, 500, 2000, 250, ::giveLiquid );
                general = ["kills", "melee_kills", "grenade_kills", "suicides", "downs", "deaths", "revives", "headshots", "hits", "misses", "use_magicbox", "grabbed_from_magicbox", "use_pap", "wallbuy_weapons_purchased", "ammo_purchased", "upgraded_ammo_purchased", "power_turnedon", "power_turnedoff", "planted_buildables_pickedup", "buildables_built", "total_games_played", "time_played_total", "total_rounds_survived", "weighted_rounds_played", "cheat_too_many_weapons", "cheat_out_of_playable", "cheat_too_friendly", "cheat_total", "total_points", "total_shots", "rounds" ];
                for(e=0;e<general.size;e++)
                    self addSliderValue("Set " + constructString( replaceChar(general[e], "_", " ") ), 0, 0, 100000, 2500, ::_setPlayerData, general[e]);
        }
        case "accountUnlocks":  
        {
            self addMenu( "accountUnlocks", "Account Unlocks" );
                if( self IsHost() )
                    self addToggle( "Media Stealing", getDvarInt("fileshareAllowDownloadingOthersFiles"), ::steal_media_items );
                self addToggle( "Unlock All", player.unlock_all, ::do_all_challenges );
                self addToggle( "Max Weapon Level", player.max_weapons, ::max_weapon_level );
                self addToggle( "Unlock Achievements", player.unlock_achievements, ::unlockAchievements );
                self addToggle( "Unlock All EE's", player GetDStat("PlayerStatsList", "DARKOPS_GENESIS_SUPER_EE", "StatValue"), ::set_all_EE );
                self addToggle( "Remove Current Gobble Gums", player.bgb_removed, ::bgb_remove );
        }
        case "colouredName":
        {
            self addMenu( "colouredName", "Account Name Colour" );
                self addOpt( "None", ::setClantag, "", "None" );
                self addOpt( "Black", ::setClantag, "^0", "Black" );
                self addOpt( "Red", ::setClantag, "^1", "Red" );
                self addOpt( "Green", ::setClantag, "^2", "Green" );
                self addOpt( "Yellow", ::setClantag, "^3", "Yellow" );
                self addOpt( "Blue", ::setClantag, "^4", "Blue" );
                self addOpt( "Cyan", ::setClantag, "^5", "Cyan" );
                self addOpt( "Magenta", ::setClantag, "^6", "Megenta" );
        }
        case "accountClantag":
        {
            self addMenu( "accountClantag", "Account Clantag" );
                self addOpt( "Custom Clantag", ::setClantag );
                self addOpt( "Reset Clantag", ::setClantag, "", "None" );
                self addOpt( "3arc", ::setClantag, "3arc" );
                self addOpt( "UNBOUND{IL}", ::setClantag, "{IL}" );
                self addOpt( "UNBOUND{IW}", ::setClantag, "{IW}" );
                self addOpt( "UNBOUND{@@}", ::setClantag, "{@@}" );
                self addOpt( "UNBOUND{$$}", ::setClantag, "{$$}" );
                self addOpt( "H@CK", ::setClantag, "H@CK" );
                self addOpt( "A$$",  ::setClantag, "A$$"  );
                self addOpt( "Sexy", ::setClantag, "Sexy" );
                self addOpt( "Twat", ::setClantag, "Twat" );
        }
        /* CUSTOMIZATION OPTIONS */
        case "customization":  
        {
            self addMenu( "customization", "Menu Customization" );
            self addOpt( "Menu Colours", ::newMenu, "menuColours" );
            self addOpt( "Menu Position", ::menuPosEditor );
        }
    }   

    /* MUSIC PLAYER */
    musicCategorys = array("Lobby", "Campaign", "Zombies", "Multiplayer");
    foreach(musicCategory in musicCategorys)
    {
        self addMenu( toLower(musicCategory) + "Tracks", musicCategory + " Tracks" );
        for(e=0;e<=98;e++)
        {
            music_id = TableLookup("gamedata/tables/common/music_player.csv", 0, e, 1);
            music_name = TableLookup("gamedata/tables/common/music_player.csv", 0, e, 2);
            music_cat = strTok( TableLookup("gamedata/tables/common/music_player.csv", 0, e, 5), ";" );

            foreach(category in music_cat)
            {
                if(category == toLower(musicCategory))
                {
                    music_id = GetSubStr(music_id, 4, music_id.size - 6);
                    self addOpt( music_name, ::server_musicPlayer, music_id );
                }
            }
        }
    }
    
    /* AUDIO QUOTES */
    self addMenu( "audioQuotes", "Audio Quotes" );
    foreach( category, vox in level.sndPlayerVox )
        self addOpt( constructString( replaceChar(category, "_", " ") ), ::newMenu, category );
        
    foreach( category, vox in level.sndPlayerVox )
    {
        self addMenu( category, constructString( replaceChar(category, "_", " ") ) );
        foreach( subcategory, vox in level.sndPlayerVox[ category ] )
            self addOpt( constructString( replaceChar(subcategory, "_", " ") ), ::create_and_play_dialog, category, subcategory );
    }

    /* WEAPONS */
    for(e=0;e<level.weapon_categories.size;e++)
    {
        if(menu != level.weapon_categories[e])
            continue;
        if( isInArray(self.previousMenu, "boxWeapons") )
            edit_box_weapons = true;
        
        self addmenu(menu, level.weapon_categories[e]);
        foreach(weap in level.weapons[e])
        {
            if( isDefined( edit_box_weapons ) && edit_box_weapons )
                self addToggle( weap.name + " In Box", isInArray( level.box_weapons, weap.id ), ::edit_box_weapons, weap.id );
            else self addOpt( weap.name, ::giveWeap, weap.id ); 
        }
        if( menu == "Extras" )
        {
            extras  = ["zombie_beast_grapple_dwr", "defaultweapon", "minigun", "tesla_gun"];
            strings = ["Beast Hands", "Default Weapon"];
            foreach(index, extra in extras)
            {
                if( MakeLocalizedString( getWeapon( extra ).displayname ) != "" )
                {
                    if(index < 2) string = strings[index];
                    else string = MakeLocalizedString( getWeapon( extra ).displayname );

                    if( isDefined( edit_box_weapons ) && edit_box_weapons )
                        self addToggle( string + " In Box", isInArray( level.box_weapons, getWeapon( extra ).name ), ::edit_box_weapons, getWeapon( extra ).name );
                    else self addOpt( string, ::giveWeap, getWeapon( extra ).name );
                }
            }
        }
    }

    /* ATTACHMENTS */
    for(e=0;e<attachment_categories.size;e++)
    {
        if(menu != attachment_categories[e])
            continue;

        weapon = player getCurrentWeapon();
        self addmenu(menu, attachment_categories[e]);
        foreach(attachment in level.attachments[e])
            if( isInArray( weapon.supportedAttachments, attachment.id ) )
                self addToggle( attachment.name, WeaponHasAttachment( player getCurrentWeapon(), attachment.id ), ::giveAttachment, attachment.id ); 
        if( self.eMenu.size == 0 )
            self addOpt("No Supported " + attachment_categories[e] + "'s" ); 

        if( self getCursor() > self.eMenu.size - 1 )
        {
            self setCursor( self.eMenu.size - 1 );
            self updateScrollbar();
        }
    }

    /* CUSTOMIZATION */
    sections = strTok( "Outline;Title & Options BG;Scroll & Subtitle BG;Text",";" );
    huds     = strTok( "OUTLINE;TITLE_OPT_BG;SCROLL_STITLE_BG;TEXT", ";" );
    
    self addMenu( "menuColours", "Menu Colours" );
    for(e=0;e<sections.size;e++)
        self addOpt(sections[e], ::newMenu, sections[e]);
    
    for(e=0;e<sections.size;e++)
    {
        if(menu != sections[e])
            continue;

        self addMenu(menu, sections[e]);
        self addSliderValue( "Red Slider", player.presets[ huds[e] ][0] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "R" );
        self addSliderValue( "Green Slider", player.presets[ huds[e] ][1] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "G" );
        self addSliderValue( "Blue Slider", player.presets[ huds[e] ][2] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "B" );
        self addToggle("Smooth Rainbow", (player.presets[ huds[e] ] == "rainbow"), ::RGB_Edit, "rainbow", huds[e], "/" );
    }    

    self clientOptions();   
}

clientOptions()
{
    self addmenu( "clients", "Clients Menu" );
    foreach( player in level.players )
        self addopt(player getname(), ::newmenu, "client_" + player getentitynumber());
            
    foreach(player in level.players)
    {
        self addmenu("client_" + player getentitynumber(), player getName());
        for(e=0;e<level.status.size-1;e++)
            self addOpt("Give " + level.status[e], ::initializeSetup, e, player);
    }
}

menuMonitor()
{
    self endon("disconnect");
    self endon("end_menu");

    savedWeapon = "none";
    while( self.access != 0 )
    {
        if(!self.menu["isLocked"])
        {
            if(!self.menu["isOpen"])
            {
                if( self meleeButtonPressed() && self adsButtonPressed() )
                {
                    self menuOpen();
                    wait .2;
                }               
            }
            else 
            {
                if( self attackButtonPressed() || self adsButtonPressed() )
                {
                    self.menu[ self getCurrentMenu() + "_cursor" ] += self attackButtonPressed();
                    self.menu[ self getCurrentMenu() + "_cursor" ] -= self adsButtonPressed();
                    self scrollingSystem();
                    wait .2;
                }
                else if( self actionslotthreebuttonpressed() || self actionslotfourbuttonpressed() )
                {
                    if(isDefined(self.eMenu[ self getCursor() ].val) || IsDefined( self.eMenu[ self getCursor() ].ID_list ))
                    {
                        if( self actionslotthreebuttonpressed() )   self updateSlider( "L2" );
                        if( self actionslotfourbuttonpressed() )    self updateSlider( "R2" );
                        wait .1;
                    }
                }
                else if( self actionslottwobuttonpressed() && self.eMenu[ self getCursor() ].func != ::newMenu && self IsHost() && self.selected_player == self && level.players.size > 1 )
                {
                    self thread selectPlayer();
                    wait .2;
                }
                else if( self useButtonPressed() )
                {
                    player = self.selected_player;
                    menu = self.eMenu[self getCursor()];

                    if( player != self && self isHost() )
                    {
                        player.was_edited = true;
                        self iPrintLnBold( menu.opt + " Has Been Activated." );
                    }
                    
                    if( self.eMenu[ self getCursor() ].func == ::newMenu && self != player )
                        self iPrintLnBold( "Error: Cannot Access Menus While In A Selected Player." );
                    else if(isDefined(self.sliders[ self getCurrentMenu() + "_" + self getCursor() ]))
                    {
                        slider = self.sliders[ self getCurrentMenu() + "_" + self getCursor() ];
                        slider = (IsDefined( menu.ID_list ) ? menu.ID_list[slider] : slider);
                        player thread doOption( menu.func, slider, menu.p1, menu.p2, menu.p3, menu.p4, menu.p5 );
                    }
                    else 
                        player thread doOption( menu.func, menu.p1, menu.p2, menu.p3, menu.p4, menu.p5 );

                    wait .05;
                    if(IsDefined( menu.toggle ))
                        self setMenuText();
                    if( player != self )
                        self.menu["OPT"]["MENU_TITLE"] setText( self.menuTitle + " ("+ player getName() +")");    
                    wait .15;
                    if( isDefined(player.was_edited) && self isHost() )
                        player.was_edited = undefined;
                }
                else if( self meleeButtonPressed() )
                {
                    if( self.selected_player != self )
                    {
                        self.selected_player = self;
                        self setMenuText();
                        self refreshTitle();
                    }
                    else if( self getCurrentMenu() == "main" )
                        self menuClose();
                    else 
                        self newMenu();
                    wait .2;
                }

                if( self IsSwitchingWeapons() && isInArray( strTok("Rig,Optic,Mod", ","), self getCurrentMenu() ) && savedWeapon != self getCurrentWeapon() )
                {
                    savedWeapon = self getCurrentWeapon();
                    self setMenuText();
                }
            }
        }
        wait .05;
    }
}

menuOpen()
{
    self.menu["isOpen"] = true;

    if(isdefined(self.health_bar))
    {
        self destroy_health_info();
        waittillframeend;
    }

    self menuOptions();
    self drawMenu();
    self drawText();
    self setMenuText(); 
    self updateScrollbar();
}

menuClose()
{
    self destroyAll(self.menu["UI"]); 
    self destroyAll(self.menu["OPT"]);
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);

    if(isdefined(self.health_bar))
    {
        waittillframeend;
        self thread draw_health_info();
    }
    self.menu["isOpen"] = false;
}

drawMenu()
{
    if(!isDefined(self.menu["UI"]))
        self.menu["UI"] = [];
    if(!isDefined(self.menu["UI_TOG"]))
        self.menu["UI_TOG"] = [];    
    if(!isDefined(self.menu["UI_SLIDE"]))
        self.menu["UI_SLIDE"] = [];
    if(!isDefined(self.menu["UI_STRING"]))
        self.menu["UI_STRING"] = [];    
        
    self.menu["UI"]["TITLE_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 260, 23, self.presets["TITLE_OPT_BG"], "white", 1, 1);
    self.menu["UI"]["SUBT_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 83, 260, 23, self.presets["SCROLL_STITLE_BG"], "white", 1, 1);
    
    self.menu["UI"]["OPT_BG"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"], self.presets["Y"] - 70, 260, 182, self.presets["TITLE_OPT_BG"], "white", 1, 1);    
    self.menu["UI"]["OUTLINE"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"] - 1.6, self.presets["Y"] - 121.5, 263, 234, self.presets["OUTLINE"], "white", 0, 1);
    self.menu["UI"]["SCROLLER"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 250, 20, self.presets["SCROLL_STITLE_BG"], "white", 2, 1);
    
    self.menu["UI"]["SIDE_SCR_BG"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 260, self.presets["Y"] - 70, 9, 182, self.presets["SCROLL_STITLE_BG"], "white", 2, 1);
    
    self.menu["UI"]["SIDE_SCR"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 257, self.presets["Y"] - 62, 4, 40, self.presets["TITLE_OPT_BG"], "white", 3, 1);
    self resizeMenu();
}

drawText()
{
    if(!isDefined(self.menu["OPT"]))
        self.menu["OPT"] = [];
    
    self.menu["OPT"]["MENU_NAME"] = self createText("hudsmall", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 108, 3, 1, level.menuName, self.presets["TEXT"]);  
    self.menu["OPT"]["MENU_TITLE"] = self createText("objective", 1.1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 83, 3, 1, self.menuTitle, self.presets["TEXT"]);

    for(e=0;e<10;e++)
        self.menu["OPT"][e] = self createText("objective", 1, "LEFT", "CENTER", self.presets["X"] + 5, self.presets["Y"] - 60 + (e*18), 3, 1, "", self.presets["TEXT"]);
}

refreshTitle()
{
    self.menu["OPT"]["MENU_TITLE"] setText(self.menuTitle);
}
    
scrollingSystem()
{
    if(self getCursor() >= self.eMenu.size || self getCursor() < 0 || self getCursor() == 9)
    {
        if(self getCursor() <= 0)
            self.menu[ self getCurrentMenu() + "_cursor" ] = self.eMenu.size -1;
        else if(self getCursor() >= self.eMenu.size)
            self.menu[ self getCurrentMenu() + "_cursor" ] = 0;
    }
    
    self setMenuText();
    self updateScrollbar();
}

updateScrollbar()
{
    curs = (self getCursor() >= 10) ? 9 : self getCursor();  
    self.menu["UI"]["SCROLLER"].y = (self.menu["OPT"][curs].y);
    
    size       = (self.eMenu.size >= 10) ? 10 : self.eMenu.size;
    height     = int(18*size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    position_Y = (self.eMenu.size-1) / ((height - 15) - math);
    
    if( self.eMenu.size > 10 )
        self.menu["UI"]["SIDE_SCR"].y = self.presets["Y"] - 62 + (self getCursor() / position_Y); 
    else self.menu["UI"]["SIDE_SCR"].y = self.presets["Y"] - 62;  
} 

setMenuText()
{
    self endon("disconnect");
    self menuOptions(); // updates toggles etc.
    self resizeMenu();

    ary = (self getCursor() >= 10) ? (self getCursor() - 9) : 0;  
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);
    
    for(e=0;e<10;e++)
    {
        self.menu["OPT"][e].x = self.presets["X"] + 5; 
        
        if(isDefined(self.eMenu[ ary + e ].opt))
            self.menu["OPT"][e] setText( self.eMenu[ ary + e ].opt );
        else 
            self.menu["OPT"][e] setText("");
            
        if(IsDefined( self.eMenu[ ary + e ].toggle ))
        {
            self.menu["OPT"][e].x += 20; 
            self.menu["UI_TOG"][e] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x - 20, self.menu["OPT"][e].y, 14, 14, (0,0,0), "white", 4, 1); //BG
            self.menu["UI_TOG"][e + 10] = self createRectangle("CENTER", "CENTER", self.menu["UI_TOG"][e].x + 7, self.menu["UI_TOG"][e].y, 12, 12, (self.eMenu[ ary + e ].toggle) ? self.presets["SCROLL_STITLE_BG"] : self.presets["TITLE_OPT_BG"], "white", 5, 1); //INNER
        }
        if(IsDefined( self.eMenu[ ary + e ].val ))
        {
            self.menu["UI_SLIDE"][e] = self createRectangle("RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 108, 14, (0,0,0), "white", 4, 1); //BG
            self.menu["UI_SLIDE"][e + 10] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["UI_SLIDE"][e].y, 12, 12, self.presets["SCROLL_STITLE_BG"], "white", 5, 1); //INNER
            if( self getCursor() == ( ary + e ) )
                self.menu["UI_SLIDE"]["VAL"] = self createText("objective", 1, "RIGHT", "CENTER", self.menu["OPT"][e].x + 126, self.menu["OPT"][e].y, 5, 1, self.sliders[ self getCurrentMenu() + "_" + self getCursor() ] + "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
        if( IsDefined( self.eMenu[ (ary + e) ].ID_list ) )
        {
            if(!isDefined( self.sliders[ self getCurrentMenu() + "_" + (ary + e)] ))
                self.sliders[ self getCurrentMenu() + "_" + (ary + e) ] = 0;
                
            self.menu["UI_SLIDE"]["STRING_"+e] = self createText("objective", 1, "RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 6, 1, "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
        if( self.eMenu[ ary + e ].func == ::newMenu && IsDefined( self.eMenu[ ary + e ].func ) )
            self.menu["UI_SLIDE"]["SUBMENU"+e] = self createText("default", 1, "RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 6, 1, ">", self.presets["TEXT"]);
    }
}
    
resizeMenu()
{
    size   = (self.eMenu.size >= 10) ? 10 : self.eMenu.size;
    height = int(18*size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    
    self.menu["UI"]["SIDE_SCR"] SetShader( "white", 4, int(math));
    self.menu["UI"]["SIDE_SCR_BG"] SetShader( "white", 9, height + 2);
    self.menu["UI"]["OPT_BG"] SetShader( "white", 260, height + 2 );
    self.menu["UI"]["OUTLINE"] SetShader( "white", 263, height + 54 );
}