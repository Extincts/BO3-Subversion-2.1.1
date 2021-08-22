_zombie_goto_round( target_round )
{
    level notify("restart_round");

    target_round -= 1;
    if(target_round < 1)
        target_round = 1;
        
    level.zombie_total = 0;
    zombie_utility::ai_calculate_health(target_round);
    world.var_48b0db18 = target_round ^ 115;
    level killAllZombies();
}

killAllZombies()
{
    level notify("restart_round");
    zombies = getAIArray();

    if(isdefined(zombies))
    {
        for(i = 0; i < zombies.size; i++)
            zombies[i] DoDamage(zombies[i].health + 1, zombies[i].origin);
    }
}

spawn_zombies( amount )
{
    for(e=0;e<amount;e++)
    {
        spawner = Array::random(level.zombie_spawners);
        zombie = zombie_utility::spawn_zombie(spawner, spawner.targetname);
    }
}

edit_all_windows( result )
{
    if(result == "Destroy")
        self thread zm_blockers::open_all_zbarriers();
    else    
    {
        foreach(barrier in level.exterior_goals)
            for(x = 0; x < barrier.zbarrier GetNumZBarrierPieces(); x++)
                barrier thread zm_blockers::replace_chunk(barrier, x, "specialty_fastreload", math::cointoss(), 1);
    }
}

server_settings( value, category )
{
    value = int( value );
    SetGametypeSetting( category, value );
    switch( category )
    {
        case "onlyheadshots":
            level.headshots_only = value;   
        case "allowhitmarkers":
            level.allowHitMarkers = value;  
        case "perksEnabled":
            level.perksEnabled = value; 
        case "disableAttachments":
            level.disableAttachments = value;
        case "playerMaxHealth":
            level.playerMaxHealth = value;
        case "playerHealthRegenTime":
            level.playerHealthRegenTime = value;
        case "rankEnabled":
            level.rankEnabled = value;
        case "friendlyfiretype": 
        {
            level.friendlyfire = value; 
            foreach( player in level.players )
                player thread _friendly_fire();
        }
        case "playerForceRespawn": 
            level.playerForceRespawn = value;       
    }
}

_actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal)
{
    zm::actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal);
    if( !isAlive( self ) )
    {
        attacker notify( "zombie_killed", meansOfDeath );

        //HEIGHT = 30, FORCE = 200 
        if( isDefined( attacker.custom_ragdoll ) )
        {
            forward               = AnglesToForward( ( 0, attacker.angles[1], 0 ) );
            my_velocity           = VectorScale(forward, attacker.ragdoll_force);
            my_velocity_with_lift = (my_velocity[0], my_velocity[1], attacker.ragdoll_height);
        
            self StartRagdoll(1);
            self LaunchRagdoll( my_velocity_with_lift, self.origin );
        }

        if(isDefined( level.gungame_active ) && isDefined( attacker.gungame_kills ))
            attacker.gungame_kills++;
    }
    
    if(IsDefined( attacker.extra_gore ))
    {
        self gibZombie( sHitLoc ); 
        fx = SpawnFX( level._effect[ "bloodspurt" ], vPoint, vDir );
        TriggerFX( fx );
    }
    
    if(isDefined(level.allowHitMarkers) && level.allowHitMarkers)
        attacker thread show_hit_marker(self, undefined, meansOfDeath);
}

_player_damage_override_wrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    if(IsAI( eAttacker ))
    {
        if(isDefined( level.gungame_active ) && isDefined( self.gungame_promotion ))
            self gungame_damage_monitor();

        if(IsDefined( self.knockback_zombies ))
        {
            forward               = AnglesToForward( ( 0, eAttacker.angles[1], 0 ) );
            my_velocity           = VectorScale(forward, self.knockback_force);
            my_velocity_with_lift = (my_velocity[0], my_velocity[1], self.knockback_height);
        
            self setOrigin( self.origin + (0,0,5) );
            self SetVelocity( my_velocity_with_lift );
        }
    }   

    if(isDefined( self.demiGodmode ))
    {        
        self FakeDamageFrom( vDir );
        return 0;
    }

    if(( isDefined(self.noExplosiveDamage) && self.noExplosiveDamage)  && (sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE"))
        return 0;

    if(isDefined( level._overridePlayerDamage ))
        nDamage = [[ level._overridePlayerDamage ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    else   
        nDamage = zm::player_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    return nDamage;
}

show_hit_marker( victim, soundName = "mpl_hit_alert", meansOfDeath = "MOD_BULLET", weapon )
{
    if(!isDefined( weapon ))
        weapon = self getCurrentWeapon();

    damageStage = damagefeedback::damage_feedback_get_stage( victim );
    if( laststand::player_is_in_laststand() || _isAlive( victim ) )
        damageStage = 5;
    self PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(victim, meansOfDeath, weapon, damageStage));
    self thread damagefeedback::damage_feedback_growth(victim, meansOfDeath, weapon);
}

_friendly_fire()
{
    if( level.friendlyfire )
        self thread loop_hitmarkers();
    else 
        self notify("stop_hitmarkers");
}

loop_hitmarkers()
{
    self endon("disconnect");
    self endon("stop_hitmarkers");
    
    for(;;)
    {
        self waittill("weapon_fired");
        trace  = bullettrace( self gettagorigin("j_head"), self gettagorigin("j_head") + anglestoforward( self getplayerangles() ) * 1000000, true, self );
        victim = trace["entity"];
        if( isAlive( victim ) ) 
        {
            victim dodamage(20, victim.origin);
            self thread show_hit_marker( victim, undefined, undefined );
        }
    }
}

grab_all_parts()
{
    if(isdefined(level.all_parts_required))
        return;
    level.all_parts_required = true;
    foreach(s_craftable in level.zombie_include_craftables)
    {
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            if(isdefined( s_piece.pieceSpawn ))
                self zm_craftables::player_take_piece(s_piece.pieceSpawn);
        }
    }
}

grab_part( part )
{
    if(!isDefined( part ))
        return;
    foreach(s_craftable in level.zombie_include_craftables)
    {
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            if(isdefined( s_piece.pieceSpawn ) && s_piece.pieceSpawn.pieceName == part )
                self zm_craftables::player_take_piece(s_piece.pieceSpawn);
        }
    }
}

toggle_moon_doors()
{
    if(!isDefined( level.moon_doors ))
    {
        level.moon_doors = true;
        self thread doors_into_moon_doors();
    }
    else 
    {
        level.moon_doors = undefined;
        self open_all_doors();
    }
}

doors_into_moon_doors()
{
    self open_all_doors();
    waittillframeend;
    self close_all_doors();
    waittillframeend;

    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    while( isDefined(level.moon_doors) )
    {
        combined_array = ArrayCombine( level.players, getAIArray(), false, false );
        foreach( player in combined_array )
        {
            foreach( type in types )
            {
                zombie_doors = GetEntArray(type, "targetname");
                foreach( door in zombie_doors )
                {
                    if( distance2d( door.origin, player.origin ) < 220 && !isDefined(door.player_controlled) && isAlive( player ) )
                        player thread do_moon_door( door );
                }
            }
        }
        wait .1;
    }
}

do_moon_door( door )
{
    door.player_controlled = true;
    door zm_blockers::door_opened(door.zombie_cost, 0); //open
    door._door_open = 1;

    open = true;
    player = self;
    while( open )
    {
        open = distance2D( door.origin, player.origin ) < 220; //true / false
        if( !open )
        {
            combined_array = ArrayCombine( level.players, getAIArray(), false, false );
            foreach( ai in combined_array )
            {
                if( distance2D( door.origin, ai.origin ) < 220 && isAlive( ai ) )
                {
                    player = ai;
                    open = true;
                }
            }
        }
        wait .05;
    }
    door zm_blockers::door_opened(door.zombie_cost, 1); //close
    door._door_open = 0;
    door.player_controlled = undefined;
    for(i = 0; i < door.doors.size; i++)
        door.doors[i] thread connect_paths_when_done();
}

connect_paths_when_done()
{
    self util::waittill_either("rotatedone", "movedone");
    self connectPaths();
}

toggle_door_state()
{
    if(!isDefined(level.all_doors_open))
    {
        level.all_doors_open = true;
        edit_zombie_doors( 0, 1 );
    }
    else 
    {
        level.all_doors_open = undefined;
        edit_zombie_doors( 1, 0 );
    }
}

edit_zombie_doors( state, opened )
{
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    foreach( type in types )
    {
        zombie_doors = GetEntArray(type, "targetname");
        foreach( door in zombie_doors )
        {
            if( type == "zombie_debris" )
            {
                door.zombie_cost = 0;
                door notify("trigger", self); 
            }
            else if( door._door_open == state )
            {
                door thread zm_blockers::door_opened(door.zombie_cost, state);
                door._door_open = opened;

                all_trigs = GetEntArray(door.target, "target");
                foreach(trig in all_trigs)
                    trig zm_utility::set_hint_string(trig, "");
            }
        }
    }
}

open_all_doors()
{
    level.all_doors_open = true;
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    foreach( type in types )
    {
        zombie_doors = GetEntArray(type, "targetname");
        foreach( door in zombie_doors )
        {
            door.zombie_cost = 0;
            door notify("trigger", self);
        }
    }
    edit_zombie_doors( 0, 1 );
}

close_all_doors()
{
    level.all_doors_open = undefined;
    edit_zombie_doors( 1, 0 );
}

forceHost()
{
    level.forcehost = !(isdefined(level.forcehost) && level.forcehost);
    if(level.forcehost)
    {
        SetDvar("lobbySearchListenCountries", "0,103,6,5,8,13,16,23,25,32,34,24,37,42,44,50,71,74,76,75,82,84,88,31,90,18,35");
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 0);
        SetDvar("party_neverJoinRecent", 1);
        SetDvar("party_readyPercentRequired", .25);
        SetDvar("partyMigrate_disabled", 1);
    }
    else
    {
        SetDvar("lobbySearchListenCountries", "");
        SetDvar("excellentPing", 30);
        SetDvar("goodPing", 100);
        SetDvar("terriblePing", 500);
        SetDvar("migration_forceHost", 0);
        SetDvar("migration_minclientcount", 2);
        SetDvar("party_connectToOthers", 1);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 2);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 1);
        SetDvar("party_neverJoinRecent", 0);
        SetDvar("partyMigrate_disabled", 0);
    }
} 

server_musicPlayer( track, jingle )
{
    if( isDefined( jingle ) )
    {
        self notify("sndDone");
        self PlaySoundWithNotify(track, "sndDone");
    }
    else
    {
        level thread zm_audio::sndMusicSystem_StopAndFlush();   
        util::setClientSysState("musicCmd", "none");
        level.musicSystemOverride = 0;

        level thread zm_audio::sndMusicSystem_PlayState( track );
        level thread audio::unlockFrontendMusic("mus_" + track + "_intro");
    }
}

play_zombie_sound( sound )
{
    zm_utility::play_sound_at_pos(sound, self.origin);
}

edit_all_speed( val )
{
    foreach( player in level.players )
        self setmovespeedscale( val );
}

edit_jump_height_all( height )
{
    foreach( player in level.players )
    {
        player notify("stop_superjump");
        player.superJump = true;
        if( height != 0 )
            player thread doSuperJump( height );
        else 
            player.superJump = undefined;    
    }
}

function_1bfbfa4c(e_entity, str_area_name)
{
    if(e_entity.var_47c44e16 != str_area_name)
        return 0;
    return 1;
}

freeze_zombies()
{
    if(!isdefined( level.zombies_frozen ))
    {
        level.zombies_frozen = true;
        while( isDefined( level.zombies_frozen ) )
        {
            foreach(ai in GetAIArray())
            {
                if(isalive(ai) && !ai IsPaused())
                    freeze_zombie( ai );
            }
            wait .1;
        }
        foreach(ai in GetAIArray())
            unfreeze_zombie( ai );    
    }
    else 
        level.zombies_frozen = undefined;
}

freeze_zombie( ai )
{
    ai notify(#"hash_4e7f43fc");
    ai thread freeze_zombie_death();
    ai SetEntityPaused(1);
    ai.var_70a58794 = ai.b_ignore_cleanup;
    ai.b_ignore_cleanup = 1;
    ai.var_7f7a0b19 = ai.is_inert;
    ai.is_inert = 1;
}

freeze_zombie_death()
{
    self endon(#"hash_4e7f43fc");
    self waittill("death");
    if(isdefined(self) && self IsPaused())
    {
        self SetEntityPaused(0);
        if(!self IsRagdoll())
        {
            self StartRagdoll();
        }
    }
}

unfreeze_zombie(ai)
{
    ai notify(#"hash_4e7f43fc");
    ai SetEntityPaused(0);
    if(isdefined(ai.var_7f7a0b19))
        ai.is_inert = ai.var_7f7a0b19;
    if(isdefined(ai.var_70a58794))
        ai.b_ignore_cleanup = ai.var_70a58794;
    else
        ai.b_ignore_cleanup = 0;
}

set_zombie_cycle( cycle )
{
    level notify("stop_run_cycle");
    level endon("stop_run_cycle");
    
    if( !isDefined( level.run_cycle ) )   level.run_cycle = "restore";
    if( level.run_cycle != cycle )        level.run_cycle = cycle;

    spawner::remove_global_spawn_function("zombie", ::do_zombie_cycle);
    if( level.run_cycle != "restore" )
    {
        spawner::add_archetype_spawn_function("zombie", ::do_zombie_cycle);
        foreach( ai in GetAIArray() )
            ai thread do_zombie_cycle();
    }
    else 
    {
        foreach( ai in GetAIArray() )
            ai zombie_utility::set_zombie_run_cycle_restore_from_override();
    }
}

do_zombie_cycle()
{
    if( level.run_cycle == "super_sprint" && !( isDefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area ) )
        self util::waittill_any("death", "completed_emerging_into_playable_area");
    if(level.run_cycle != "restore") 
        self zombie_utility::set_zombie_run_cycle( level.run_cycle );    
}

_makeZombieCrawler()
{
    foreach( ai in GetAIArray() )
        ai zombie_utility::makeZombieCrawler();
}

_zombie_head_gib()
{
    foreach( ai in GetAIArray() )
        thread mark_zombie_for_head_gib(ai);
}

mark_zombie_for_head_gib(ai)
{
    ai.marked_for_death = 1;
    ai.var_85934541 = 1;
    ai.no_powerups = 1;
    ai.deathpoints_already_given = 1;
    ai.tesla_head_gib_func = ::zombie_head_gib;
    ai lightning_chain::arc_damage(ai, self, 1, level.var_3e825919);
}

zombie_head_gib()
{
    self endon("death");
    self clientfield::set("zm_bgb_mind_ray_fx", 1);
    wait(RandomFloatRange(0.65, 2.5));
    self clientfield::set("zm_bgb_mind_pop_fx", 1);
    self PlaySoundOnTag("zmb_bgb_mindblown_pop", "tag_eye");
    self zombie_utility::zombie_head_gib();
}

_gib_random_parts()
{
    foreach( ai in GetAIArray() )
        ai zombie_utility::gib_random_parts();
}

_enable_Power()
{
    if( getMapName() == "Revelations" )
    {
        for(e=1;e<5;e++)
            level flag::set( "power_on" + e );
        level flag::set( "all_power_on" );
        waittillframeend;
        
        while( !level flag::get("apothicon_near_trap") )
            wait .1;
        trigger = struct::get("apothicon_trap_trig", "targetname");
        trigger notify("trigger_activated", self);
        return;
    }
    if( getMapName() == "Shangri-La" )
    {
        directions = ["power_trigger_left", "power_trigger_right"];
        foreach( direction in directions )
        {
            switch_trigger = GetEnt("power_trigger_" + direction, "targetname");
            switch_trigger notify("trigger", self);
        }
        return;
    }
    trig = get_power_trig();
    trig notify("trigger", self);
}

get_power_trig()
{
    presets = ["elec", "power", "master"];
    foreach( preset in presets )
    {
        trig = getEnt("use_" + preset + "_switch", "targetname");
        if(isDefined( trig ))
            return trig;
    }
    return false;
}

_nuke_game()
{
    if( !self areYouSure() )
        return;
    foreach( player in level.players )
        player thread lockMenu("lock", "close");

    huds = [];
    huds[0] = self createRectangle("CENTER", "TOPLEFT", 50, 50, 50, 50, (0,0,0), "white", 2, 1, true); 
    huds[1] = self createRectangle("CENTER", "TOPLEFT", 154, 50, 150, 54, (0,0,0), "white", 2, .7, true); 
    huds[2] = self createText("objective", 1.2, "LEFT", "TOPLEFT", 85, 35, 3, 1, "Nuke Inbound... Say your last wishes.\nRest in peace " + getMapName() + ".\nYours sincerely " + self.name + ".", (1,1,1), true);
    huds[3] = self createRectangle("CENTER", "TOPLEFT", 36, 36, 25, 25, (1,0,0), "white", 1, 1, true); 
    huds[4] = self createRectangle("CENTER", "TOPLEFT", 64, 36, 25, 25, (1,0,0), "white", 1, 1, true);
    huds[5] = self createRectangle("CENTER", "TOPLEFT", 64, 64, 25, 25, (1,0,0), "white", 1, 1, true); 
    huds[6] = self createRectangle("CENTER", "TOPLEFT", 36, 64, 25, 25, (1,0,0), "white", 1, 1, true); 
    huds thread _nuke_colour();
    
    countdown = self createText("bigfixed", 2, "CENTER", "TOPLEFT", 50, 50, 3, 1, "9", (1,1,1), true);

    for(e=9;e>0;e--)
    {
        countdown setValue( e );
        if(e==1)
            setSlowMotion( 1.0, 0.25, 0.5 );
        self PlaySoundToTeam( "zmb_bgb_shoppingfree_coinreturn", "allies" );    
        wait 1;
    }
    destroyAll( huds );
    countdown destroy();

    thread LUI::screen_flash(0.2, 0.5, 1, 0.8, "white");
    self PlaySoundToTeam( "evt_nuked", "allies" );
    self PlaySoundToTeam( "evt_nuke_flash", "allies" );
    self killAllZombies();
    foreach( player in level.players )
    {
        earthquake( 0.6, 7, player.origin, 100000 );
        player thread commitSuicide( true );
    }
    wait 1;
    setSlowMotion( .25, 1, 2 );
}

_nuke_colour()
{
    self[0] endon("death");
    while( isDefined( self[0] ) )
    {
        for(e=3;e<self.size;e++)
        {
            self[e] thread _do_nuke_colour();
            wait .2;
        }
        wait .05;
    }
}

_do_nuke_colour()
{
    self endon("death");
    self fadeOverTime(.2);
    self.color = rgb(255, 240, 76); //yellow
    wait .2;
    self fadeOverTime(.2);
    self.color = rgb(255, 68, 4);  //orange 
    wait .2;
    self fadeOverTime(.2);
    self.color = rgb(203, 0, 2);  //red
    wait .2;
}

toggle_zombie_eyes()
{
    if( !isdefined( level.remove_zombie_eyes ) )
    {
        level.remove_zombie_eyes = true;
        level thread remove_zombie_eyes();
    }
    else 
        level.remove_zombie_eyes = undefined;    

}

remove_zombie_eyes()
{
    while( isDefined( level.remove_zombie_eyes ) )
    {
        foreach( ai in getAIArray() )
        {
            ai clientfield::set("zombie_has_eyes", 0); 
            ai clientfield::set("zombie_keyline_render", 1);
        }
        wait .05;
    }
    foreach( ai in getAIArray() )
        ai clientfield::set("zombie_has_eyes", 1); 
}

set_zombie_anim_scale( rate )
{
    spawner::remove_global_spawn_function("zombie", ::set_animation_rate);
    spawner::add_archetype_spawn_function("zombie", ::set_animation_rate, rate);
}  

set_animation_rate( rate )
{
    self util::waittill_any("death", "completed_emerging_into_playable_area");
    self ASMSetAnimationRate( rate );
}

set_clip_muliplier( value )
{
    SetDvar("player_clipSizeMultiplier", value);
}

set_perk_limit( value )
{
    level.perk_purchase_limit = value;
}

_bot_spawn( count )
{
    for(e=0;e<count;e++)
    {
        if(level.players.size == 4)
            return;

        bot = zbot_add();
        wait .1;
        bot thread zbot_spawn();
    }
}

zbot_add()
{
    bot = AddTestClient();
    if(!isdefined(bot))
        return;
    bot.pers["isBot"] = 1;
    bot.equipment_enabled = 0;
    return bot;
}

zbot_spawn()
{
    while(self.sessionstate != "spectator")
        wait .1;
    self [[level.spawnPlayer]]();
}

zbot_remove( count )
{
    foreach( bot in level.players )
    {
        if(!bot IsTestClient())
            continue;
        Kick( bot getEntityNumber() );
    }
}

zbot_give_weapon()
{
    foreach( bot in level.players )
    {
        if(!bot IsTestClient())
            continue;
        array = randomInt( level.weapons.size );
        index = level.weapons[array].size;
        weapon = level.weapons[ array ][ randomInt(index) ].id;

        bot giveWeap( weapon, true, 1 );
    }
}

disable_joker()
{
    if(isDefined(level.show_all_boxes))
        return self iPrintLnBold("Cannot turn this off when Show all boxes is enabled!");
    if(GetDvarString("magic_chest_movable") == "1")
    {
        level.joker_disabled = true;
        setDvar("magic_chest_movable", "0");
    }
    else 
    {
        level.joker_disabled = undefined;
        setDvar("magic_chest_movable", "1");
    }
}

toggle_all_boxes()
{
    if( !isDefined( level.show_all_boxes ) )
    {
        level.show_all_boxes = true;
        Array::thread_all( level.chests, ::show_mystery_box );
        Array::thread_all( level.chests, ::enable_all_chests );
        Array::thread_all( level.chests, ::fire_sale_box_fix );

        if(GetDvarString("magic_chest_movable") == "1")
            setDvar("magic_chest_movable", "0");
    }   
    else if(level.show_all_boxes != "waiting")
    {
        level notify("stop_showing_all_boxes");
        level.show_all_boxes = "waiting";

        Array::thread_all( level.chests, ::remove_mystery_box );
        if(!isDefined(level.joker_disabled))
            setDvar("magic_chest_movable", "1");
    }
}

show_mystery_box()
{
    if(self zm_magicbox::is_chest_active() || self get_chest_index() == level.chest_index)
        return;
    self thread zm_magicbox::show_chest(); 
}

remove_mystery_box( chest_index = self get_chest_index() )
{
    if( chest_index == level.chest_index )
        return;
    if(!isDefined(level.removing_count))
        level.removing_count = 0;
    
    while(self.hidden)
        wait .1;

    level.chests[chest_index].was_temp = 1;
    zm_powerup_fire_sale::remove_temp_chest( chest_index );

    level.removing_count++;
    if(level.removing_count == level.chests.size - 1)
    {
        level.show_all_boxes = undefined;
        level.removing_count = 0;
        level refreshMenuToggles();
    }
}

fire_sale_box_fix()
{
    level endon("stop_showing_all_boxes");
    while( true )
    {
        level waittill("fire_sale_off");
        self.was_temp = undefined;
    }
}

enable_all_chests()
{
    level endon("stop_showing_all_boxes");
    while( isDefined(self) ) 
    {
        self.zbarrier waittill("closed");
        thread zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, zm_magicbox::magicbox_unitrigger_think );
    }
}

get_chest_index()
{
    foreach( index, chest in level.chests )
    {
        if( self == chest )
            return index;
    }
    return undefined;
}

move_magic_box()
{
    while( level.chests[level.chest_index]._box_open && isDefined( level.chests[level.chest_index]._box_open ) && level flag::get("moving_chest_now") )
        wait .1;

    refreshMenuToggles();   
    level flag::set("moving_chest_now");
    level.chests[level.chest_index].zbarrier.chest_moving = 1;

    level.chests[level.chest_index] thread zm_magicbox::treasure_chest_move( self );
    level notify("weapon_fly_away_start");
    wait .1;
    level notify("weapon_fly_away_end");
    while( level flag::get("moving_chest_now") )
        wait .05;
    refreshMenuToggles();
}

teleport_box()
{
    while( level.chests[level.chest_index]._box_open && isDefined( level.chests[level.chest_index]._box_open ) || level flag::get("moving_chest_now"))
        wait .1;
    if( isDefined( level.custom_chest ) )
    {
        level notify("weapon_box_reset");
        level.custom_chest = undefined;
        return;
    }

    box = level.chests[ level.chest_index ];
    box thread do_teleport_box( box.zbarrier.origin, true ); //reset origin
    box thread do_teleport_box( self.origin ); //new origin
    level.custom_chest = true;
}

do_teleport_box( origin, wait )
{
    if( isDefined( wait ) )
        level util::waittill_any("weapon_fly_away_end", "weapon_box_reset");

    self.origin = origin;
    self.zbarrier.origin = origin;
    self.unitrigger_stub.origin = origin + (0,0,50);

    self zm_magicbox::get_chest_pieces();

    if( isDefined( wait ) )
        return;
    self zm_magicbox::hide_chest();
    wait 2;
    self zm_magicbox::show_chest();
}

mystery_box_price( price )
{
    for(i = 0; i < level.chests.size; i++)
    {
        if(isdefined(level.chests[i].zombie_cost))
        {
            level.chests[i].old_cost = price;
            level.chests[i].zombie_cost = price;
        }
    }
}

zombies_drop_powerups()
{
    if( !isdefined( level.zombie_drop_powerup ) )
    {
        self endon("disconnect");
        
        level.zombie_drop_powerup = true;
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 64;
        while( isdefined( level.zombie_drop_powerup ) )
        {
            bool = (level.powerup_drop_count > 6) ? 0 : 1;
            level.zombie_vars["zombie_drop_item"] = bool;
            wait .1;
        }
    }
    else 
    {
        level.zombie_vars["zombie_powerup_drop_max_per_round"] = 4;
        level.zombie_drop_powerup = undefined;
    }
}

disable_zombie_spawns()
{
    SetDvar("ai_disableSpawn", !GetDvarInt("ai_disableSpawn") + ""); 
}

disable_powerup( powerup_name )
{
    powerup = level.zombie_powerups[powerup_name].func_should_drop_with_regular_powerups;
    if([[ powerup ]]())
        level.zombie_powerups[powerup_name].func_should_drop_with_regular_powerups = zm_powerups::func_should_never_drop;
    else 
        level.zombie_powerups[powerup_name].func_should_drop_with_regular_powerups = zm_powerups::func_should_always_drop;

    all_disabled = true;
    foreach( powerup_name in getArrayKeys(level.zombie_include_powerups) )
    {
        powerup = level.zombie_powerups[powerup_name].func_should_drop_with_regular_powerups;
        if([[ powerup ]]())
            all_disabled = false;
    }

    level flag::set("zombie_drop_powerups");
    if(all_disabled)
        level flag::clear("zombie_drop_powerups");
}
    
powerup_special_drop_override()
{
    if( !level flag::get("zombie_drop_powerups") )
    {
        loc = struct::get("teleporter_powerup", "targetname");
        playfx(level._effect["lightning_dog_spawn"], loc.origin);
        playsoundatposition("zmb_hellhound_prespawn", loc.origin);
        wait 1.5;
        playsoundatposition("zmb_hellhound_bolt", loc.origin);
        earthquake(0.5, 0.75, loc.origin, 1000);
        playsoundatposition("zmb_hellhound_spawn", loc.origin);
        wait 1;
        thread zm_utility::play_sound_2d("vox_sam_nospawn");
        self delete();
        return undefined;
    }
    [[ level._original_powerup_special_drop_override ]]();
}

get_music_track( name = false )
{
    map = getMapName();
    music = [ "round_start", "round_end", "game_over" ];
    music_names = [ "Round Start", "Round End", "Game Over" ];

    if( map == "Shadows Of Evil" )
    {
        map_music = [ "zod_endigc_lullaby", "snakeskinboots", "snakeskinboots_instr", "coldhardcash", "zod_ee_apothifight" ];
        map_music_names = [ "Lullaby", "Snakes In Boots", "Snakes In Boots instrumental", "Cold Hard Cash", "Apothicon Fight" ];
    }
    if( map == "Gorod Krovi" )
    {
        map_music = [ "ace_of_spades", "sam", "sentinel_roundstart" ];
        map_music_names = [ "Ace Of Spades", "Samantha", "Sentinel Round" ];
    }
    if( map == "Kino Der Toten" )
    {
        map_music = [ "115", "sam" ];
        map_music_names = [ "115", "Samantha" ];
    }
    if( map == "Moon" )
    {
        map_music = [ "nightmare", "cominghome", "end_is_near", "samantha_reveal", "sam" ];
        map_music_names = [ "Nightmare", "Coming Home", "End Is Near", "Samantha Reveal", "Samantha"];
    }
    if( isDefined( map_music ) && isDefined( map_music_names ) )
    {
        music = ArrayCombine(map_music, music, false, false);
        music_names = ArrayCombine(map_music_names, music_names, false, false);
    }

    if( name )
        return map_music_names;
    return map_music;
}

disable_special_round( type )
{
    if( type == "wasp" )    
    {
        if( level.next_wasp_round == 999 )
            level.next_wasp_round = [[level.zm_custom_get_next_wasp_round]]();
        else 
            level.next_wasp_round = 999;
    }   
    if( type == "dog" )
    {
        if( level.next_dog_round == 999 )
            level.next_dog_round = level.round_number + randomintrange( 4, 7 ); 
        else 
            level.next_dog_round = 999;
    }
    if( type == "monkey" )
    {
        if( level.next_monkey_round == 999 )
            level.next_monkey_round = level.round_number + randomIntRange(1, 4);
        else 
            level.next_monkey_round = 999;
    }
    if( type == "thief" )
    {
        //Never officially used?
    }
    if( type == "mechz" )
    {
        if( level.next_mechz_round == 999 )
        {
            if(isdefined(level.is_forever_solo_game) && level.is_forever_solo_game)
                n_round_gap = randomIntRange( level.mechz_min_round_fq_solo, level.mechz_max_round_fq_solo );
            else
                n_round_gap = randomIntRange( level.mechz_min_round_fq, level.mechz_max_round_fq );
            level.next_mechz_round = level.round_number + n_round_gap;
        }
        else 
            level.next_mechz_round = 999;
    }
    if( type == "astro" )
    {
        if( level.next_astro_round == 999 )
            level.next_astro_round = level.astro_round_start + randomIntRange(0, level.max_astro_round_wait + 1);
        else 
            level.next_astro_round = 999;
    }
    if( type == "raps" )
    {
        if( level.n_next_raps_round == 999 )
            level.n_next_raps_round = [[level.zm_custom_get_next_raps_round]]();
        else 
            level.n_next_raps_round = 999;
    }
    if( type == "sentinel" )
    {
        if( level.var_a78effc7 == 999 )
            level.var_a78effc7 = level.round_number + randomIntRange(9, 12);
        else 
            level.var_a78effc7 = 999;
    }    
    if( type == "mangler" )
    {
        if( level.var_51a5abd0 == 999 )
            level.var_51a5abd0 = level.round_number + randomIntRange(5, 8);
        else 
            level.var_51a5abd0 = 999;
    }  
}

notify_server_commands( command, menu = "" )
{
    self notify("menuresponse", menu, command);
}

free_wallbuys()
{
    if( !IsDefined( level.free_wallbuys ) )
        level.free_wallbuys = true;
    else 
        level.free_wallbuys = undefined;
    
    foreach( spawn in level._spawned_wallbuys )
    {
        if(!IsDefined( level.zombie_weapons[ spawn.weapon ].o_cost ))
            level.zombie_weapons[ spawn.weapon ].o_cost = level.zombie_weapons[ spawn.weapon ].cost;
        level.zombie_weapons[ spawn.weapon ].cost = isDefined(level.free_wallbuys) ? 0 : level.zombie_weapons[ spawn.weapon ].o_cost;
    }
}

free_perkmachines()
{
    if( !IsDefined( level.free_perkmachines ) )
        level.free_perkmachines = true;
    else 
        level.free_perkmachines = undefined;
    
    foreach( vending in GetEntArray("zombie_vending", "targetname") )
    {
        if(!IsDefined( vending.o_cost ))
            vending.o_cost = vending.cost;
        
        vending.cost = isDefined(level.free_perkmachines) ? 0 : vending.o_cost;
    }
}

gibZombie( sHitLoc )
{
    if( IsSubStr(sHitLoc, "right_arm") )
        GibServerUtils::GibRightArm( self );
    else if( IsSubStr(sHitLoc, "left_arm") )    
        GibServerUtils::GibLeftArm( self );
    else if( IsSubStr(sHitLoc, "right_leg") )    
        GibServerUtils::GibRightLeg( self );
    else if( IsSubStr(sHitLoc, "left_leg") )    
        GibServerUtils::GibLeftLeg( self );
    else if( IsSubStr(sHitLoc, "no_legs") )    
        GibServerUtils::GibLegs( self );
    else if( IsSubStr(sHitLoc, "head") || IsSubStr(sHitLoc, "helmet") )    
        GibServerUtils::GibHead( self );    
}

_zombie_wrapper_function( func, p1, p2, p3, p4, p5 )
{
    foreach( ai in GetAIArray() )
        ai thread doOption( func, p1, p2, p3, p4, p5 );
}

_setDvar_wrapper( value, dvar )
{
    SetDvar( dvar, value );
}

create_and_play_dialog( category, subcategory )
{
    self zm_audio::create_and_play_dialog( category, subcategory );
}

queueNotifyMessage( message )
{
    if(!isdefined( level.messageNotifyQueue ))
    {
		level.messageNotifyQueue = [];
        level thread showNotifyMessage();
    }
    if(!isDefined( message ))
    {
        self thread refreshMenu();
        wait .2;
        message = self do_keyboard( "Custom Message" );
        wait .2;
        self notify( "reopen_menu" );
    }
    if(!isDefined( message ))
        return; //TO MAKE SURE A STRING IS VALID
    level.messageNotifyQueue[level.messageNotifyQueue.size] = message;
}

showNotifyMessage()
{
    level endon("game_ended");

    for(;;)
    {
        while(!isDefined(level.messageNotifyQueue[0]))
            wait .1;

        notifyData = level.messageNotifyQueue[0];
        level.notify_message_data = level createText("hudbig", 1.2, "CENTER", "TOP", 0, 100, 0, 1, notifyData, level.players[0].presets["TEXT"], true);  
        
        letter_time = 125;
        decay_start = (notifyData.size) * 250;
        decay_duration = 1000;
        
        playNotifyLoop = spawn("script_origin", (0, 0, 0));
        playNotifyLoop playloopsound("uin_notify_data_loop");

        level.notify_message_data setcod7decodefx(letter_time, decay_start, decay_duration);
        wait (decay_start + decay_duration) / 1000;

        playNotifyLoop delete();
        level.notify_message_data destroy();
        ArrayRemoveIndex( level.messageNotifyQueue, 0, false );
    }
}