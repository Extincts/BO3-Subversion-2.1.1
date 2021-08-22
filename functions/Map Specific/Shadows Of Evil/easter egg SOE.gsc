cinematic_showcase( entity, xRange, yRange, time, zHeight = 0 )
{
    if( isDefined( level.zCinematicCamera ) )
        level.zCinematicCamera delete();
    if( isDefined( level.zCinematicPivot ) )
        level.zCinematicPivot delete();
    if( isDefined( level.zCinematicScreen ) )
        level.zCinematicScreen delete();
    if( !isDefined( entity ) )
    {
        self cameraActivate( false );
        return;
    }
    angles = vectorToAngles(entity.origin - (entity.origin + (xRange, yRange, zHeight)));
    level.zCinematicScreen = self createRectangle("CENTER", "CENTER", 0, 0, 999, 999, (0,0,0), "white", 99, 0);
    level.zCinematicCamera = modelSpawner(entity.origin + (xRange, yRange, zHeight), "tag_origin", angles);
    level.zCinematicPivot  = modelSpawner(entity.origin, "tag_origin", entity.angles );

    level.zCinematicScreen fadeovertime(.5);
    level.zCinematicScreen.alpha = 1;
    level.zCinematicCamera linkTo( level.zCinematicPivot );
    level.zCinematicPivot rotateYaw(360, time, .4, .2 );

    wait .3;
    self cameraSetPosition( level.zCinematicCamera );
    self cameraSetLookAt();
    self cameraActivate( true );

    wait .3;
    level.zCinematicScreen fadeovertime(.5);
    level.zCinematicScreen.alpha = 0;
}

give_special_sword( glaive_type )
{
    weapon_string = glaive_type + "_" + self.characterindex;
    weapon = GetWeapon(weapon_string);
        
    self notify(#"hash_b29853d8");

    prev_weapon = self GetCurrentWeapon();
    self zm_weapons::weapon_give(weapon, 0, 0, 1);
    self.current_sword = self.current_hero_weapon;
    self.sword_power = 1;
    self GadgetPowerSet(0, 100);
    self SwitchToWeapon(weapon);
    self waittill("weapon_change_complete");

    self SetLowReady(1);
    self SwitchToWeapon(prev_weapon);
    self util::waittill_any_timeout(1, "weapon_change_complete", "disconnect");
    self SetLowReady(0);
    self.sword_power = 1;
    self clientfield::set_player_uimodel("zmhud.swordEnergy", self.sword_power);
    self GadgetPowerSet(0, 100);
    self clientfield::increment_uimodel("zmhud.swordChargeUpdate");
}

complete_sword_quest( upgrade )
{
    if( isDefined( self.complete_sword_quest ) || level clientfield::get("keeper_quest_state_" + self.characterindex) == 8 )
        return;

    if( self.var_15954023.var_b8ad68a0 != 0 )
    {
        self thread upgrade_sword_quest();
        return;
    }

    level flag::set("keeper_sword_locker");
    self.complete_sword_quest = true;
    activate_trigger( level.var_15954023.var_2855c5c[ self.var_15954023.var_f01fc13c ].trigger );

    wait 2;
    //self clientfield::set_player_uimodel("zmInventory.player_sword_quest_egg_state", 1 + i);
    self.var_15954023.var_b8ad68a0 = 1;
    activate_trigger( level.var_15954023.var_2855c5c[ self.var_15954023.var_f01fc13c ].trigger );

    if( isDefined( upgrade ) )
        self thread upgrade_sword_quest();
    self refreshMenuToggles();

    self.complete_sword_quest = undefined;
}

upgrade_sword_quest()
{
    self.complete_sword_quest = true;
    //pickup egg 
    level clientfield::set("keeper_quest_state_" + self.characterindex, 2);
    self clientfield::set_player_uimodel("zmInventory.player_sword_quest_completed_level_1", 1);
    self clientfield::set_player_uimodel("zmInventory.player_sword_quest_egg_state", 1);
    self thread shadowsuishow("zmInventory.widget_egg", 3.5);
    self thread show_infotext_for_duration("ZM_ZOD_UI_LVL2_EGG_PICKUP", 3.5);

    wait 1;
    //complete circles
    placements = struct::get_array("sword_quest_magic_circle_place", "targetname")[1].unitrigger_stub;
    self activate_trigger( placements );

    for(i=0;i<4;i++)
        self.var_fdda19d8.var_db999762[i] = 1;
    
    wait 2;
    margwa = GetAIArchetypeArray("margwa", level.zombie_team);
    for(e=0;e<margwa.size;e++)
        margwa[e] kill();
    
    self flag::clear("magic_circle_wait_for_round_completed");  

    level clientfield::set("keeper_quest_state_" + self.characterindex, 8);
    self thread show_infotext_for_duration("ZM_ZOD_UI_LVL2_SWORD_PICKUP", 3.5);
    wait 1;
    self give_special_sword("glaive_keeper");

    self refreshMenuToggles();
    self.complete_sword_quest = undefined;
}

activate_ee_book()
{
    ent = GetEnt("ee_book", "targetname").unitrigger_stub;
    self cinematic_showcase( ent, 240, 0, 600 );
    self activate_trigger( "ee_book" );
}

complete_super_worm()
{
    while(!level flag::get("ee_superworm_present"))
        wait 1;

    level.o_zod_train.var_65323906 = 1;
    level.o_zod_train.var_d621a979 notify( "trigger" );

    districts = Array("ee_district_rail_electrified_1", "ee_district_rail_electrified_2", "ee_district_rail_electrified_3", "ee_final_boss_keeper_electricity_0", "ee_final_boss_keeper_electricity_1", "ee_final_boss_keeper_electricity_2");
    foreach(district in districts)
    {
        trigger = GetEnt(district, "targetname");
        trigger.origin = self.origin;
        wait .1;
        trigger notify("trigger", self );
    }

    while(level flag::get("ee_superworm_present"))
        wait 1;

    for(i=0;i<3;i++)
        level.var_76c101df[i] notify("damage", 100, self, (0,0,0), (0,0,0), "MOD_BULLET", "tag_origin", "", "", GetWeapon("zombie_beast_lightning_dwl"));
}

complete_boss_fight()
{
    level.var_421ff75e = 1;
    foreach( player in level.players )
    {
        for(e=0;e<4;e++)
        {
            if(e == player.characterindex)
            {
                player setOrigin( level.var_f86952c7["boss_1_" + character_index( e )].origin );
                player thread cinematic_showcase( level.var_f86952c7["boss_1_femme"], 300, 0, 180 );
                wait .1;
                player activate_trigger( level.var_f86952c7["boss_1_" + character_index( e ) ] );
            }
        }
    }
    level flag::wait_till( "ee_boss_started" );
    while( !level flag::get("ee_boss_defeated") )
    {
        wait .9;
        if(level flag::get("ee_boss_vulnerable"))
        {
            level.var_1a2a51eb.var_93dad597 notify("damage", level.var_1a2a51eb.var_93dad597.health - 1, self, (0,0,0), (0,0,0), "MOD_BULLET", "tag_origin", "", "", GetWeapon("ray_gun_upgraded"));
            self activate_trigger( level.var_f86952c7["boss_1_victory"] );
        }
    }
    wait 10;
    foreach( player in level.players )
        player cinematic_showcase();
}

complete_totem_placements( index ) // 0 - 4
{
    stub = GetEnt("keeper_resurrection_" + character_index( index ), "targetname");
    self cinematic_showcase( stub, 240, 0, 15 );

    self setOrigin( stub.origin );

    level clientfield::set("ee_totem_state", 3);
    level clientfield::set("ee_keeper_" + character_index( index ) + "_state", 1);
    level clientfield::set("ee_quest_state", 0);
    
    self.var_11104075 = spawn("script_model", self.origin);
    self.var_11104075 SetModel("t7_zm_zod_keepers_totem");
    self.var_11104075 LinkTo(self, "tag_stowed_back", (0, 12, -32));
    self.var_11104075 clientfield::set("totem_state_fx", 1);

    wait .05;
    stub notify( "trigger", self );
}

character_index( index )
{
    return Array("boxer", "detective", "femme", "magician")[index];
}

do_soe_ee()
{
    foreach( player in level.players )
    {
        player thread refreshMenu();
        player enableInvulnerability();
    }

    open_all_doors();
    shock_all_electrics();
    open_all_smashables();
    grab_all_parts();
    complete_all_rituals();
    
    foreach( player in level.players )
    {
        player.ignoreme = true;
        player hide();
        player thread complete_sword_quest( true );
    }
    wait 17;
    activate_ee_book();
    
    while(!isDefined( level.var_f86952c7["totem_landed"] ))
        wait .1;

    for(i = 0; i < 4; i++)
    {
        self complete_totem_placements( i );
        wait 6;
    }

    wait 6;
    complete_boss_fight();
    complete_super_worm();

    level.ee_complete = true;
    foreach( player in level.players )
    {
        if( !isDefined( player.invisibility ) )
            player show();
        if( !isDefined( player.godmode ) )
            player disableInvulnerability();
        if( player.ignorme_count != 0 )
            player.ignoreme = false;    
        player notify( "reopen_menu" ); 
    }
}
