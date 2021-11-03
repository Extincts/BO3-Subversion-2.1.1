explosive_melee()
{
    if(!IsDefined( self.explosive_melee ))
    {
        self.explosive_melee = true;
        self thread do_explosive_melee();
    }
    else 
        self.explosive_melee = undefined;
}

do_explosive_melee()
{
    self endon("disconnect");
    while(IsDefined( self.explosive_melee ))
    {
        if( self isMeleeing() )
        {
            position        = self GetTagOrigin( "tag_weapon_right" );
            phyExpMagnitude = 7;
            blastRadius     = 250;

            fx = isDefined( level._effect["raps_impact"] ) ? level._effect["raps_impact"] : level._effect["dog_gib"];
            playFx(fx, position, AnglesToForward(self.angles) * 50);
            playSoundAtPosition("wpn_grenade_explode", self.origin);

            a_ai_zombies = Array::get_all_closest(position, GetAITeamArray("axis"), undefined, undefined, 360);
            foreach( zombie in a_ai_zombies )
            {   
                zombie DoDamage( zombie.health + 1, position, self, self, "none", "MOD_IMPACT" );
                zombie kill();
                
                v_curr_zombie_origin = zombie GetCentroid();
                n_random_x = RandomFloatRange(-3, 3);
                n_random_y = RandomFloatRange(-3, 3);
                zombie StartRagdoll(1);
                zombie LaunchRagdoll(100 * VectorNormalize(v_curr_zombie_origin - position + (n_random_x, n_random_y, 30)), "torso_lower");
            }

            PlayRumbleOnPosition( "grenade_rumble", position );
            earthquake( 0.5, 0.75, position, 800 );
            wait .1;
            physicsExplosionSphere( position, blastRadius, blastRadius / 2, phyExpMagnitude );
            
            while(self isMeleeing())
                wait .05;
        }
        wait .05;
    }
}

riotSmash()
{
    level endon("game_ended");
    if(!isDefined(self.riotSmash))
    {
        self.riotSmash = true;
        self giveWeapon( getWeapon("riotshield") );
        self switchToWeapon( getWeapon("riotshield") );
        
        while(isDefined( self.riotSmash ) && self getCurrentWeapon().name == "riotshield")
        {
            if(self meleeButtonPressed())        
                self sheildLaunched();
            wait .05;
        }
        self.riotSmash = undefined;
    }
    else 
        self.riotSmash = undefined;
}

sheildLaunched()
{
    sheild = modelSpawner(self getEye() + anglesToForward( self getPlayerAngles() )*20, GetWeapon( "riotshield" ).worldmodel, self getPlayerAngles());

    for(e=0;e<400;e++)
    {
        trace = worldtrace(sheild.origin, sheild.origin + anglesToForward( sheild.angles ) * 10);
        sheild moveTo(sheild.origin + anglesToForward( sheild.angles ) * 20, .05);

        if( trace["fraction"] != 1 )
            break;
        foreach(ai in getAIArray())
            if(ai isTouching( sheild ))
                break 2;
        wait .05;
    }        
    
    a_ai_zombies = Array::get_all_closest(sheild.origin, GetAITeamArray("axis"), undefined, undefined, 360);
    foreach( zombie in a_ai_zombies )
    {   
        zombie DoDamage( zombie.health, sheild.origin, self, self, "none", "MOD_IMPACT" );

        v_curr_zombie_origin = zombie GetCentroid();
        n_random_x = RandomFloatRange(-3, 3);
        n_random_y = RandomFloatRange(-3, 3);
        zombie StartRagdoll(1);
        zombie LaunchRagdoll(100 * VectorNormalize(v_curr_zombie_origin - sheild.origin + (n_random_x, n_random_y, 30)), "torso_lower");
    }

    fx = isDefined( level._effect["raps_impact"] ) ? level._effect["raps_impact"] : level._effect["dog_gib"];
    playFx(fx, sheild.origin, AnglesToForward(sheild.angles) * 50);
    playSoundAtPosition("wpn_grenade_explode", sheild.origin);

    PlayRumbleOnPosition( "grenade_rumble", sheild.origin );
    earthquake( 0.5, 0.75, sheild.origin, 800 );

    wait .05;
    sheild delete();
}

shieldProtector()
{
    if( !isDefined( self.shieldProtector ) )
    {
        self endon("disconnect");
        self.shieldProtector = true;
        self AllowSprint( false );
        rotateSheilds = modelSpawner(self.origin, "tag_origin");    

        model = GetWeapon( "riotshield" ).worldmodel;
        if( !isDefined( model ) )
            model = "p7_zm_power_up_insta_kill";
        
        sheilds = [];
        for(e=0;e<4;e++)
        {
            sheilds[e] = modelSpawner(self.origin + (cos(e*90)*35, sin(e*90)*35, 30), model, (0,0 + e*90,0));
            sheilds[e] linkTo(rotateSheilds);
            if( model == "p7_zm_power_up_insta_kill" )
                sheilds[e] clientfield::set("powerup_fx", e+1);
        }
        while( isDefined( self.shieldProtector ) )
        {
            a_ai_zombies = Array::get_all_closest(rotateSheilds.origin, GetAITeamArray("axis"), undefined, undefined, 80);
            foreach( zombie in a_ai_zombies )
            {
                GibServerUtils::GibHead( zombie );
                if( math::cointoss() )
                    GibServerUtils::GibLeftArm( zombie );
                else
                    GibServerUtils::GibRightArm( zombie );
                GibServerUtils::GibLegs( zombie );

                zombie DoDamage( zombie.health, zombie.origin, self, self, "none", "MOD_IMPACT" );
            }
            rotateSheilds.origin = self.origin + (0,0,2) + AnglesToForward( self.angles )*10;
            rotateSheilds rotateyaw( 360, .3 );
            wait .05;
        }
        rotateSheilds delete();
        for(e=0;e<4;e++)
            sheilds[e] thread delayedFall(3);
        self AllowSprint( true ); 
    }
    else self.shieldProtector = undefined;
}

clusterGrenade()
{
    self endon("disconnect");
    if(!isDefined(self.cluster))
    {
        self.cluster = true;
        while(isDefined(self.cluster))
        {
            self waittill( "grenade_fire", grenade, weapon_name );
            self doCluster( grenade, weapon_name );
        }
    }
    else
        self.cluster = undefined;
}

doCluster( grenade, weapon_name )
{
    if(!isDefined(self.cluster))   
        return;
    while(isDefined( grenade ))
    {
        origin = grenade.origin;
        wait .1;
    }
    for(e=0;e<10;e++) 
        self MagicGrenadeType(weapon_name, origin, getRandomThrowSpeed(), (1.5 + e / 10));
}

moddedSpread( amount )
{
    if(!IsDefined( self.moddedSpread ))
    {
        self.moddedSpread = true;
        self thread doModdedSpread( amount );
    }
    else 
    {
        self.moddedSpread = undefined;
        self notify("end_moddedspread");
    }
}

doModdedSpread( amount )
{
    self endon("disconnect");
    self endon("end_moddedspread");
    
    while( IsDefined( self.moddedSpread ) )
    {
        self waittill( "weapon_fired", weapon );
        pos  = self lookPos();
        for(e = 0; e < int(amount); e++)
        {
            if(distance(self.origin, pos) < 2000)
                magicBullet(weapon, self GetWeaponMuzzlePoint(), pos + fakeSpread(50), self);
            else
                magicBullet(weapon, self GetWeaponMuzzlePoint(), (self GetWeaponMuzzlePoint() + anglestoforward( self getplayerangles() ) * 2000) + fakeSpread(70), self);
        }
    }
}
    
fakeSpread( amount ) 
{
    return (randomIntRange(amount * -1, amount), randomIntRange(amount * -1, amount), randomIntRange(amount * -1, amount));
}

skyTrip()
{
    self endon("disconnect");
    if(!isDefined(self.skytrip))
    {
        self.skytrip = true;
        if( self hasMenu() ) self thread refreshMenu();
        
        firstOrigin = self.origin;
        tripShip = modelSpawner(self.origin, "tag_origin");
        self playerLinkTo(tripShip);
        
        tripShip MoveTo(firstOrigin+(0,0,2500),4);
        wait 6;
        tripShip MoveTo(firstOrigin+(0,4800,2500),4);
        wait 6;
        tripShip MoveTo(firstOrigin+(4800,2800,2500),4);
        wait 6;
        tripShip MoveTo(firstOrigin+(-4800,-2800,4500),4);
        wait 6;
        tripShip MoveTo(firstOrigin+(0,0,2500),4);
        wait 6;
        tripShip MoveTo(firstOrigin+(25,25,60),4);
        wait 4;
        tripShip MoveTo(firstOrigin+(0,0,30),1);
        wait 1;
        tripShip delete();
        
        self notify( "reopen_menu" );
        
        self.skytrip = undefined;
    }
    else
        self iPrintln("Wait For The Current Sky Trip To Finish");
}
  
toggleKillText()
{
    if( !isDefined( self.killtxt ) )
    {
        self.killtxt = true;
        self thread loopKillText();
    }
    else
    {
        self.killtxt = undefined;
        self notify("stop_kill_text");
    }
}  
    
loopKillText()
{
    self endon("disconnect");
    self endon("stop_kill_text");
    
    self.current_stage = 0;
    for(;;)
    {
        self waittill( "zombie_killed", MOD );
        self thread calcKillText( MOD );
    }
}

calcKillText( MOD )
{
    self notify("end_current_text");
    self endon("end_current_text");
    
    stage = ["", "Double Kill!", "Triple Kill!", "Quadra Kill!", "Penta Kill!", "Rampage!", "Killing Spree!", "Unstoppable!"];
    wait .05;
    if( self.current_stage != 0 )
        self iPrintLnBold( stage[self.current_stage] );

    if( self.current_stage < 7 )
        self.current_stage++;
    wait .4;
    self.current_stage = 0;
}

superJump( height )
{
    if(!IsDefined( self.superJump ))
    {
        self.superJump = true;
        self thread doSuperJump( int(height) );
    }
    else 
    {
        self.superJump = undefined;
        self notify("stop_superjump");
    }
}

doSuperJump( height )
{
    self endon("disconnect");
    self endon("stop_superjump");

    wait .2;
    while( IsDefined( self.superJump ) )
    {
        if(self JumpButtonPressed() && !self IsOnGround() && !self IsMantling())
        {
            for(e=0;e<height;e++)
            {
                self setVelocity(self getVelocity() + (0, 0, 237));
                wait .05;
            }
            while(!self IsOnGround())
                wait .05;
        }
        wait .05;
    }
}

noTarget()
{
    self.ignoreMe = !self.ignoreMe;
    self.ignorme_count = self.ignoreMe * 999;
}

spawnPowerup( powerup_name )
{
    if( powerup_name == "Spawn All" )
    {
        self thread hash_7084af67::activation();
        return;
    }
    level thread zm_powerups::specific_powerup_drop(powerup_name, self.origin + anglesToForward( self.angles ) * 80 );
}

exo_suits()
{ 
    dvars = strTok("doubleJump_enabled;juke_enabled;playerEnergy_enabled;wallrun_enabled;sprintLeap_enabled;traverse_mode;weaponrest_enabled", ";");
    if( !isdefined( self.exo_suits ) )
    {
        self endon("stop_exo");
        self endon("disconnect");
        self.exo_suits = true;
        foreach( dvar in dvars )
            SetDvar( dvar, true );
        while( isDefined( self.exo_suits ) )
        {
            self.var_54343c90 = 1;
            self func_f0051f1b(1);
            self func_7c34e9c7(1);
            wait .1;
        }
    }
    else 
    {
        self notify("stop_exo");
        self.exo_suits = undefined;
        self.var_54343c90 = 0;
        self func_f0051f1b(0);
        self func_7c34e9c7(0);
        foreach( dvar in dvars )
            SetDvar( dvar, false );
    }
}

moon_gravity()
{
    if( !isdefined( self.moon_gravity ) )
    {
        self.moon_gravity = true;
        self setplayergravity(136);
    }
    else 
    {
        self.moon_gravity = undefined;
        self clearplayergravity();
    }
}

gravityGun()
{
    if(!isDefined(self.gravityGun))
    {
        self.gravityGun = true;
        self thread do_gravity_gun();
    }
    else self.gravityGun = undefined;
}

do_gravity_gun()
{
    while(isDefined(self.gravityGun))
    {
        trace = bulletTrace(self GetTagOrigin("j_head"),self GetTagOrigin("j_head")+ anglesToForward(self GetPlayerAngles())* 1000000,1,self);
        while(self adsButtonPressed())
        {
            if(isplayer(trace["entity"])) 
                trace["entity"] EnableInvulnerability(); 
                
            origin = self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles())* 200;    
            trace["entity"] ForceTeleport( origin );
            trace["entity"].origin = origin;
            
            if(self attackButtonPressed())
            {
                ang  = self getPlayerAngles();
                fwd  = anglesToforward(ang);
                fake = modelSpawner(origin, "tag_origin");
                
                if(isplayer(trace["entity"]))
                    trace["entity"] playerLinkTo( fake, "tag_origin" );
                else    
                    trace["entity"] LinkTo( fake, "tag_origin" );
                wait .05;

                fake Launch( fwd * 999 );
                fake thread gravity_gun_end( trace["entity"] );
                wait 1;
            }
            wait .05;
        }
        wait .05;
    }
}

gravity_gun_end( player )
{
    oldOrigin = player.origin;
    wait .05;
    while(oldOrigin != player.origin)
    {
        oldOrigin = player.origin;
        wait .05;
    }
    if(!isDefined(player.godmode))
        player DisableInvulnerability();
    self delete();    
}


adv_forge_mode()
{
    if(!IsDefined( self.forge_mode ))
    {
        self.forge_mode = true;
        self thread do_adv_forge_mode();
    }
    else
    {
        self.forge_mode = undefined;
        self notify("stop_adv_forge");
    }
}

do_adv_forge_mode()
{
    self endon("disconnect");
    self endon("stop_adv_forge");
    
    while( true )  
    {
        trace = beamtrace( self GetTagOrigin("j_head"), self GetTagOrigin("j_head") + anglesToForward(self GetPlayerAngles()) * 1000000, 1, self);
        if(IsDefined( trace["entity"] ))
        {
            if(self adsbuttonpressed())
            {
                while(self adsButtonPressed())
                {   
                    trace["entity"] ForceTeleport(self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles())* 200);
                    trace["entity"].origin = self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles())* 200;
                    wait .01;
                }
            }
            if(self attackButtonPressed())
            {
                while(self attackButtonPressed())
                {
                    trace["entity"] rotatePitch(1, .01);
                    wait .01;
                }
            }
            if(self fragbuttonpressed())
            {
                while(self fragbuttonpressed())
                {   
                    trace["entity"] rotateyaw(1,.01);
                    wait .01;
                }
            }
            if(self secondaryoffhandbuttonpressed())
            {
                while(self secondaryoffhandbuttonpressed())
                {   
                    trace["entity"] rotateroll(1,.01);
                    wait .01;
                }
            }
            if( !isPlayer( trace["entity"] ) && self meleeButtonPressed() )
            {
                trace["entity"] delete();
                wait .2;
            }
        }
        wait .05;
    }
}

toggle_shoot_powerups()
{
    if(!isDefined(self.shoot_powerups))
    {
        self.shoot_powerups = true;
        self thread do_shoot_powerups();
    }
    else
    {
        self.shoot_powerups = undefined;
        self notify("stop_shoot_powerups");
    }
}

do_shoot_powerups()
{
    self endon("disconnect");
    self endon("stop_shoot_powerups");
    
    for(;;)
    {
        self waittill("weapon_fired");
        level.zombie_devgui_power = 1;
        level.zombie_vars["zombie_drop_item"] = 1;
        level.powerup_drop_count = 0;
        level thread zm_powerups::powerup_drop(lookPos());
    }
}

teleport_zombies_grenade()
{
    if(!isDefined( self.zombie_tele_grenade ))
    {
        self.zombie_tele_grenade = true;
        self thread do_teleport_zombies_grenade();
    }
    else 
    {
        self.zombie_tele_grenade = undefined;
        self notify("end_zteleport_grenades");
    }
}

do_teleport_zombies_grenade()
{
    self endon("disconnect");
    self endon("end_zteleport_grenades");

    while( true )
    {
        self waittill( "grenade_fire", grenade );

        while(isdefined( grenade ))
        {
            origin = grenade.origin;
            wait .05;
        }

        playFx( level._effect["samantha_steal"], origin);
        playSoundatPosition( "zmb_laugh_child", origin );
        foreach( ai in getAIArray() )
            ai forceteleport( origin );
    }
}

light_protector()
{
    if(!isDefined( self.light_protector_active ) )
    {
        values = [1,2,4]; 
        self.light_protector_active = true;
        self.light_protector = modelSpawner(self.origin + (0,0,80), "tag_origin");
        self.light_protector clientfield::set("powerup_fx", values[randomInt(3)]);
        self.light_protector thread do_light_protector( self );
    }
    else 
    {
        self notify( "stop_light_protector" );
        self.light_protector delete();
        self.light_protector_active = undefined;
    }
}

do_light_protector( player )
{
    player endon( "stop_light_protector" );
    player endon("disconnect");
    while(isDefined( self ))
    {
        foreach( ai in getAIArray() )
        {
            if(distance(ai.origin, player.origin) < 500)
            {
                if(!bulletTracePassed( self.origin, ai.origin, false, self ) || ai.health < 1)
                    continue;

                time = calcDistance(540, self.origin, ai.origin);
                self moveToOriginOverTime(ai GetTagOrigin("j_head"), time, ai, undefined, "j_head");
                GibServerUtils::GibHead( ai );
                ai doDamage( ai.health + 1, (0,0,0) );
                playsoundatposition("mus_raygun_stinger", ai.origin);
                wait .1;
                time = calcDistance(540, self.origin, player.origin);
                self moveToOriginOverTime(player GetTagOrigin("j_head"), time, player, (0,0,20), "j_head");
            }
        }
        self moveToOriginOverTime(player GetTagOrigin("j_head") + (0,0,20), .1);
        wait .05;
    }
}

do_jumpscare( name, map )
{
    pers = self;
    foreach( player in level.players )
        if( player.name == name )
            pers = player;

    if( IsDefined(pers.inJumpScare) && pers.inJumpScare )
        return;
    
    if( map == "Shadows Of Evil" )
    {
        sound = "zmb_zod_egg_scream";
        string = "JumpScare";
    }
    else 
    {
        sound = "zmb_easteregg_scarydog";
        string = "JumpScare-Tomb";
    }

    pers.inJumpScare = true;
    pers playlocalsound( sound );
    
    pers.var_92fcfed8 = pers OpenLUIMenu( string );
    wait 0.55;
    pers CloseLUIMenu(pers.var_92fcfed8);
    wait .55;
    pers.inJumpScare = undefined;
}

toggle_electric_cherry( version )
{
    if( isDefined( self.electric_cherry ) && self.electric_cherry != version )
        self.electric_cherry = version;
    else if( !isDefined( self.electric_cherry ) )
    {
        self.electric_cherry = version;
        self thread electric_cherry_remastered( self.electric_cherry );
    } 
    else 
    {
        self.electric_cherry = undefined;
        self notify("stop_cherry");
    }
}

electric_cherry_remastered( version )
{
    self endon("stop_cherry");
    self endon("disconnect");
    while( true )
    {
        if( self isReloading() )
        {
            self playsound("zmb_bgb_popshocks_impact");

            origin = self GetTagOrigin("tag_weapon_right");
            fxOrg = util::spawn_model("tag_origin", origin);
            fxOrg LinkTo(self, "tag_weapon_right");

            fx = PlayFXOnTag(level._effect["tesla_shock"], fxOrg, "tag_origin");
            fx = PlayFXOnTag(level._effect["tesla_bolt"], fxOrg, "tag_origin");
            self thread electrify_zombie( version );

            wait 1;
            fxOrg delete();   

            while( self isReloading() )
                wait .5;
        }
        wait .05;
    }
}

electrify_zombie( v2 )
{
    a_zombies = zombie_utility::get_round_enemy_array();
    a_zombies = util::get_array_of_closest(self.origin, a_zombies, undefined, undefined, 150);

    if( self.electric_cherry == "v2" )
    {
        self.tesla_enemies = undefined;
        self.tesla_enemies_hit = 1;
        self.tesla_firing = 1;

        closest = ArrayGetClosest(self.origin, a_zombies);
        closest lightning_chain::arc_damage(closest, self, 1, level._lightning_params);

        self.tesla_enemies_hit = 0;
        self.tesla_firing = 0;
    }
    else 
    {
        foreach( ai in a_zombies )
        {
            if(isalive(self) && isalive(ai))
            {
                ai lightning_chain::arc_damage_ent(self, 1, level._lightning_params);
                self zm_score::add_to_player_score(40);
            }
        }
    }
}

toggleRicochetBullets()
{
    if( !isDefined( self.ricochetBullet ) )
    {
        self endon("stop_ricochet");
        self.ricochetBullet = true;
        while( isDefined( self.ricochetBullet ) )  
        { 
            self waittill("weapon_fired"); 
            self ricochetBullets( 5 );
        } 
    }
    else 
    {
        self.ricochetBullet = undefined;
        self notify("stop_ricochet");
    }
}

ricochetBullets( times = 1, weapon = self getCurrentWeapon() )
{ 
    incident = anglestoforward( self getplayerangles() ); 
    trace = bullettrace(self getEye(), self getEye() + incident*100000, 0, self); 
    reflection = incident - (2 * trace["normal"] * vectorDot( incident, trace["normal"] )); 
    magicbullet( weapon, trace["position"], trace["position"] + (reflection*100000) ); 
    wait .1; 
    for(i=0;i<times;i++) 
    { 
        trace = bullettrace( trace["position"], trace["position"] + (reflection*100000), 0, self ); 
        incident = reflection; 
        reflection = incident - (2 * trace["normal"] * vectorDot( incident, trace["normal"] )); 
        magicbullet(weapon, trace["position"], trace["position"] + ( reflection*100000 )); 
        wait .1;
    } 
}

multiJump( amount )
{
    if(!isDefined( self.multiJump ))
    {
        self thread toggle_multiJump( amount );
        self.multiJump = true;
    }
    else
    {
        self notify("multiJump_stop");
        self.multiJump = undefined;
    }
}

toggle_multiJump( amount )
{
    self endon("disconnect");
    self endon("multiJump_stop");
    jumps = 0;
    while(isDefined( self.multiJump ))
    {
        if(self JumpButtonPressed() && jumps <= amount)
        {
            self setVelocity(self getVelocity() + (0, 0, 250));
            jumps++;
        }
        if(jumps >= amount && self isOnGround())
            jumps = 0;
        wait .1;
    }
}

frog_jump()
{
    if(!isDefined( self.frog_jump ))
    {
        self.frog_jump = true;
        self thread do_frog_jump();
    }
    else 
    {
        self.frog_jump = undefined;
        self notify("stop_frog_jump");
    }
}

do_frog_jump()
{
    self endon("disconnect");
    self endon("stop_frog_jump");
    
    while(1)
    {
        if(self jumpbuttonpressed() && !isDefined(self.reviveTrigger))
        {
            forward = anglesToForward(self getPlayerAngles());
            self setOrigin(self.origin+(0,0,5));
            self setVelocity((forward[0]*700, forward[1]*700, 400));
            wait 1;
        }
        wait .05;
    }
}

auto_bunny_hop()
{
    if(!isDefined( self.bunny_hop ))
    {
        self.bunny_hop = true;
        self thread do_auto_bunny_hop();
    }
    else
    {
        self.bunny_hop = undefined;
        self notify("stop_bunny_hop");
    }
}

do_auto_bunny_hop()
{   
    self endon("disconnect");
    self endon("stop_bunny_hop");
    
    for(;;)
    {
        while(self isOnGround() && !isDefined(self.reviveTrigger))
        {   
            wait .01;
            vel = self getVelocity();
            self setorigin(self.origin);
            self setVelocity((vel[0], vel[1], 300));
            wait .01;
        }
        while(!self isOnGround())
            wait .05;
        
        wait .05;
    }
}

auto_detonate_grenades()
{
    if( !IsDefined( self.auto_detonate_grenades ) )
    {
        self endon("disconnect");
        self endon("stop_auto_detonate_grenades");
        
        self.auto_detonate_grenades = true;
        while( true )
        {
            self waittill("grenade_fire", grenade, weapon);
            grenade resetMissileDetonationTime( .0005 );
            grenade.immediateDetonation = 1;
        }
    }
    else 
    {
        self notify("stop_auto_detonate_grenades");
        self.auto_detonate_grenades = undefined;
    }
}

auto_detonate_projectiles()
{
    if( !IsDefined( self.auto_detonate_projectiles ) )
    {
        self endon("disconnect");
        self endon("stop_auto_detonate_projectiles");
        
        self.auto_detonate_projectiles = true;
        while( true )
        {
            self waittill( "missile_fire", missile, weapon ); 
            missile resetMissileDetonationTime( .0005 );
            missile.immediateDetonation = 1;
        }
    }
    else 
    {
        self notify("stop_auto_detonate_projectiles");
        self.auto_detonate_projectiles = undefined;
    }
}

zombie_custom_ragdoll()
{
    if( !isDefined( self.custom_ragdoll ) )
    {
        self.custom_ragdoll = true;
        if(!isDefined( self.ragdoll_height ))
            self.ragdoll_height = 20;
        if(!isDefined( self.ragdoll_force ))
            self.ragdoll_force = 100;
    }
    else 
        self.custom_ragdoll = undefined;
}

set_ragdoll_height( value )
{
    self.ragdoll_height = value;
}

set_ragdoll_force( value )
{
    self.ragdoll_force = value;
}

player_knockback_zombies()
{
    if(!IsDefined( self.knockback_zombies ))
    {
        self.knockback_zombies = true;
        if(!isDefined( self.knockback_height ))
            self.knockback_height = 100;
        if(!isDefined( self.knockback_force ))
            self.knockback_force = 400;
    }
    else 
        self.knockback_zombies = undefined;
}
    
set_knockback_height( value )
{
    self.knockback_height = value;
}

set_knockback_force( value )
{
    self.knockback_force = value;
}

codJumper()
{
    if(!IsDefined( self.codJumper ))
    {
        self.codJumper = true;
        self thread do_codJumper();
        self iPrintLnBold("Shoot to place or move Cod Jumper");
    }
    else 
    {
        self.codJumper = undefined;
        self notify("stop_codJumper");
        array_delete( self.c_jumper );
    }
}

do_codJumper()
{
    self endon("disconnect");
    self endon("stop_codJumper");
    
    self.c_jumper = [];
    while( true )
    {
        self waittill("weapon_fired");
        colour   = pow(2, randomint(3));
        position = lookpos();
        
        array_delete( self.c_jumper );
        for(e=0;e<3;e++) for(i=0;i<4;i++)
        {
            position = getGroundPoint( lookpos() + (37 - (e*25), 30 - (i*15), 60) );
            self.c_jumper[self.c_jumper.size] = modelSpawner( position, "p7_zm_power_up_max_ammo" );
            
            self.c_jumper[self.c_jumper.size-1] match_slope();
            self.c_jumper[self.c_jumper.size-1] clientfield::set( "powerup_fx", int(colour) );
            self.c_jumper[self.c_jumper.size-1] thread monitorCodJumper( self );
            self.c_jumper[self.c_jumper.size-1] thread delete_if_disconnect( self );
        }
    }
}

monitorCodJumper( owner )
{
    self endon("death");
    while(IsDefined( self ))
    {
        combined_array = ArrayCombine( level.players, getAIArray(), false, false );
        foreach( player in combined_array )
        {
            if( self isTouchingSwept( player ) )
            {
                if(!isPlayer( player ))
                    player thread zm_spawner::zombie_ragdoll_then_explode( VectorScale((RandomIntRange(-20,20), RandomIntRange(-20,20), 60), 0.1), owner );
                else 
                {
                    p_angles = AnglesToForward( player.angles );
                    player SetOrigin( player.origin + (0,0,5) );
                    player SetVelocity( (p_angles[0]*300, p_angles[1]*300, 600) );
                }
            }
        }
        wait .05;
    }
} 

extra_gore()
{
    if(!IsDefined( self.extra_gore ))
        self.extra_gore = true;
    else 
        self.extra_gore = undefined;
}
    
spec_nade()
{
    if(!IsDefined( self.spec_nade ))
    {
        self endon("disconnect");
        self endon("stop_spec_grenade");
        self.spec_nade = true;
        while(IsDefined( self.spec_nade ))
        {
            self waittill( "grenade_fire", grenade, weapon, cookTime );
            
            if(zm_utility::is_placeable_mine( weapon ))
                continue;
            ent = modelSpawner( grenade.origin - AnglesToForward(grenade.angles) * 50, "tag_origin" );
            ent LinkToBlendToTag( grenade, "tag_origin" );
            
            self CameraSetPosition( ent );
            self CameraSetLookAt( grenade );
            self CameraActivate( true );  
            
            grenade spec_nade_follow( ent );
            
            self CameraActivate( false );
            ent delete();
        }
    }
    else 
    {
        self notify("stop_spec_grenade");
        self.spec_nade = undefined;
    }
}

spec_nade_follow( camera )
{
    self endon("death");
    while(IsDefined( self ))
    {
        camera.origin = (self.origin + (0,0,10)) - AnglesToForward(camera.angles) * 50;
        wait .05;
    }
}

toggleBuckshot()
{
    if(!IsDefined( self.buckshot_missile ))
    {
        self.buckshot_missile = true;
        self thread doBuckshot();
    }
    else 
    {
        self notify("stop_buckshot");
        self.buckshot_missile = undefined;
    }
}

doBuckshot()
{
    self endon("stop_buckshot");
    while( IsDefined( self.buckshot_missile ) ) 
    {
        self waittill( "missile_fire", bullet, weaponName );
        wait .8;
        if(!IsDefined( bullet ))
            continue; 
        bullet.angles = VectorToAngles( GetGroundPosition( bullet.origin, 2 ) - bullet.origin );
    }
}

auto_revive_gun()
{
    if( !IsDefined( self.auto_revive_gun ) )
    {
        self.auto_revive_gun = true;
        self thread auto_revive_gun_monitor();
        self iPrintLnBold( "Shoot a downed teammate to revive them!" );
    }
    else 
    {
        self.auto_revive_gun = undefined;
        self notify("stop_auto_revive_gun");
    }
}

auto_revive_gun_monitor()
{
    self endon("disconnect");
    self endon("stop_auto_revive_gun");
    
    while( IsDefined( self.auto_revive_gun ) )
    {
        self waittill("weapon_fired");
        trace  = bullettrace( self gettagorigin("j_head"), self gettagorigin("j_head") + anglestoforward( self getplayerangles() ) * 1000000, true, self );
        victim = trace["entity"];
        if( IsDefined( victim.reviveTrigger ) )
            victim zm_laststand::auto_revive( victim );
    }
}

cod4Bounce()
{
    if(!isDefined(self.doCod4Bounce))
    {
        self.doCod4Bounce = true;
        self thread doCod4Bounce();
    }
    else self.doCod4Bounce = undefined;
}

doCod4Bounce()
{
    self endon("disconnect");
    level endon("game_ended");
    
    while(isDefined(self.doCod4Bounce))
    {
        while(!self jumpButtonPressed())
            wait .05;

        while(!self isOnGround())
        {
            vel = self GetVelocity()[2];
            wait .05;
        }
        
        bounceTrace = [];
        bounceTrace[0] = bulletTrace(self.origin, self.origin + (anglesToRight( self getPlayerAngles() ) * 20) + (anglesToUp( self getPlayerAngles() ) *-9999), false, self); //RIGHT DOWN
        bounceTrace[1] = bulletTrace(self.origin, self.origin + (anglesToRight( self getPlayerAngles() ) * -20) + (anglesToUp( self getPlayerAngles() ) * -9999), false, self); //LEFT DOWN
        bounceTrace[2] = bulletTrace(self.origin, self.origin + (anglesToForward( self getPlayerAngles() ) * 20) + (anglesToUp( self getPlayerAngles() ) * -9999), false, self); //FORWARD DOWN
        bounceTrace[3] = bulletTrace(self.origin, self.origin + (anglesToForward( self getPlayerAngles() ) * -20) + (anglesToUp( self getPlayerAngles() ) * -9999), false, self); //BAKCWARD DOWN
        
        for(e=0;e<bounceTrace.size;e++)
        {
            if(distance(bounceTrace[e]["position"], self.origin) > 30 && vel < -250)
            {
                self setOrigin((self.origin));
                for(z=int((vel / 90) * -1);z>0;z--)
                {
                    self setVelocity(self getVelocity() + (0, 0, 350));
                    wait .05;
                }
                break 1;
            }
        }
        wait .05;
    }
}

//Solo Pong - 25/11/2019 ~ Extinct [DOGSHIT ON BO3 / MUCH BETTER ON MW2]
pong_huds()
{
    self thread refreshMenu();
    wait .28;
    
    pong = [];
    pong[0] = self createRectangle("CENTER", "CENTER", 0, 0, 320, 200, (0,0,0), "white", 0, .8); //MAIN BG
    pong[1] = self createRectangle("CENTER", "CENTER", 0, 0, 14, 14, (1,1,1), "zombie_stopwatch_glass", 2, 1); //BALL
    
    pong[2] = self createRectangle("CENTER", "CENTER", 150, 0, 5, 50, (1,1,1), "white", 1, 1); //PADDLE 
    pong[3] = self createRectangle("CENTER", "CENTER", 0, 0, 3, 200, (1,1,1), "white", 1, .4); //CENTER LINE 
    
    pong[4] = self createRectangle("CENTER", "CENTER", 0, -101, 320, 3, (1,1,1), "white", 1, .4); //TOP LINE 
    pong[5] = self createRectangle("CENTER", "CENTER", 0, 101, 320, 3, (1,1,1), "white", 1, .4); //BORROM LINE 
    
    pong[6] = self createText("small", 1.3, "CENTER", "CENTER", 0, -110, 5, 1, "SCORE: 0", (1,1,1)); //SCORES
    pong[7] = self createText("small", 1.3, "CENTER", "CENTER", 0, 108, 5, 1, "PRESS [{+melee}] TO EXIT!", (1,1,1)); //SCORES
    
    self thread pong_monitor_ball( pong );
    self thread pong_player_monitor( pong );
    self thread pong_exit( pong );
    self FreezeControls( true );
}

pong_monitor_ball( huds )
{
    score = 0;
    best  = 0;
    x     = 8;
    y     = 0;
    
    while( IsDefined( huds[1] ) )
    {
        huds[1] thread hudMoveXY( .1, huds[1].x + x, huds[1].y + y );
        
        if(huds[1].x >= huds[2].x - 13 && huds[1].x <= huds[2].x && huds[1].y >= huds[2].y - 30 && huds[1].y <= huds[2].y + 30 )
        {
            score++;    
            x *= -1;
            y = RandomIntRange( -6, 6 );
            huds[6] setText( "SCORE: " + score );
            self PlaySoundToPlayer( "ui_mp_timer_countdown", self );
        }
        else if(huds[1].x > 160 ) //ENDING POINT (FAILED TO SAVE BALL)
        {
            if( score > best )    
                best = score;    
                
            huds[6] setText( "GAME OVER - BEST SCORE " + best + " - PRESS [{+usebutton}] TO TRY AGAIN!" );  
            huds[1] thread hudMoveXY( 0, 0, 0 ); 
            while(!self UseButtonPressed())
                wait .05; 
             
            score = 0;    
            huds[6] setText( "SCORE: " + score );    
        }    
        
        if(huds[1].x < -148)
            x *= -1;
        if(huds[1].y < -90 || huds[1].y > 90 ) 
            y *= -1;
        self.predict = (huds[1].y + (y * 4));    
        wait .05;
    }
}

pong_player_monitor( huds )
{
    while( IsDefined( huds[2] ) )
    {
        //self ai_control_paddle( huds, 2 );
        //wait .05;
        
        //ACTUAL PLAYERS
        if( self AttackButtonPressed() )
        {
            if( huds[2].y < 75 )
                huds[2] thread hudMoveXY( .1, huds[2].x, huds[2].y + 25 );
            wait .1;  
        }
        else if( self AdsButtonPressed() )
        {
            if( huds[2].y > -75 )
                huds[2] thread hudMoveXY( .1, huds[2].x, huds[2].y - 25 );
            wait .1;    
        }
        wait .05;
    }
}

ai_control_paddle( huds, index )
{
    ball = self.predict;
    if( ball <= 0 )
        ball *= -1; 
    
    amount = 0;
    for(e=0;e<4;e++)
    {
        if( 25 * amount < ball )
            amount = e;
    }    
            
    if( huds[1].x > 60 && huds[index].y == 0 )
    {  
        for(e=0;e<amount;e++)
        {
            if( huds[index].y < 75 && self.predict > 25)
                huds[index] thread hudMoveXY( .1, huds[index].x, huds[index].y + 25 );
             if( huds[index].y > -75 && self.predict < -25)
                huds[index] thread hudMoveXY( .1, huds[index].x, huds[index].y - 25 );    
            wait .1; 
        }
    }
    if( huds[1].x < 60 && huds[index].y != 0 )
    {
        huds[index] thread hudMoveXY( .1 * amount, huds[index].x, 0 );
        wait .1 * amount;
    }
}

pong_exit( huds )
{
    while( IsDefined( huds[2] ) )
    {
        if(self MeleeButtonPressed())
        {
            destroyAll( huds );
            break;
        }
        wait .05;
    }
    self FreezeControls( false );
    self notify( "reopen_menu" );
}