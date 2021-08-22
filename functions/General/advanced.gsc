toggle_body_guard()
{
    if(!isDefined( self.body_guard_active ))
    {
        self.body_guard_active = true;
        zombie = body_guard_zombie();
        self waittill( "body_guard_death" );
        zombie kill();
    }
    else 
    {
        self.body_guard_active = undefined;
        self notify( "body_guard_death" );
    }
}

body_guard_zombie()
{
    spawner = Array::random(level.zombie_spawners);
    zombie = zombie_utility::spawn_zombie(spawner, spawner.targetname);

    zombie.allowPain = 0;
    zombie.allowdeath = 0;

    while( !zombie.completed_emerging_into_playable_area )
        wait .1;

    zombie.team = self.team;
    zombie.no_gib = 1;
    zombie.variant_type = 8;
    zombie.can_attack = 0;  
    zombie.ignoreall = 1;
    zombie.ignore_find_flesh = 1;

    zombie thread body_guard_follow( self );
    return zombie;
}

body_guard_follow( owner )
{
    self endon( "death" );
    self endon( "body_guard_death" );

    while( isDefined( self ) )
    {
        _anim = "walk";
        if(owner IsSprinting() || distance2D( self.origin, owner.origin ) > 100 )
            _anim = "sprint";

        if( self.zombie_move_speed != _anim )
            self zombie_utility::set_zombie_run_cycle( _anim );

        self SetGoal(owner.origin + (0,70,0) );

        foreach( zombie in getAIArray() )
        {
            if( distance2D( self.origin, owner.origin ) < 100 && distance2D( zombie.origin, self.origin ) < 600 && self != zombie )
            {
                if(!bulletTracePassed( self.origin, zombie.origin, false, self ) || zombie.health < 1)
                    continue;

                self.can_attack = 1;  
                self.ignoreall = 0;
                self.ignore_find_flesh = 0;
                self zombie_utility::set_zombie_run_cycle( "sprint" );

                while( isAlive( zombie ) )
                    wait .05;
                self.ignore_find_flesh = 1;
            }
        }
        wait .1;
    }
}

toggle_perk_circle()
{
    if( !isDefined( level.perk_circle ) )
    {
        level.perk_circle = true;
        self thread perk_circle();
    }
    else 
    {
        level.perk_circle = undefined;
        self thread perk_circle( true );
    }
    refreshMenuToggles();
}

perk_circle( reset = false )
{
    a_keys = getArrayKeys(level._custom_perks);
    foreach(i, key in a_keys)
    {
        machine = GetEntArray(level._custom_perks[key].radiant_machine_name, "targetname");
        machine_triggers = GetEntArray(level._custom_perks[key].radiant_machine_name, "target");

        size = 360 / a_keys.size;
        radius = 15 * a_keys.size;

        for(e = 0; e < machine.size; e++)
        {
            if( !isDefined( machine[e].default_origin ) )
            {
                machine[e].default_origin = machine[e].origin;
                machine[e].default_angles = machine[e].angles;
            
                machine_triggers[e].default_origin = machine_triggers[e].origin;
                machine_triggers[e].default_angles = machine_triggers[e].angles;
            }

            origin = reset ? machine[e].default_origin : self.origin + ( cos(i*size) * radius, sin(i*size) * radius, 0 );
            angle = reset ? machine[e].default_angles : ( 0, (i*size) + 270, 0 );

            machine[e] unlink();
            machine[e].origin = origin;
            machine[e].angles = angle;

            origin = reset ? machine_triggers[e].default_origin : self.origin + ( cos(i*size) * radius, sin(i*size) * radius, 50 );
            angle = reset ? machine_triggers[e].default_angles : ( 0, (i*size) + 270, 0 );

            machine_triggers[e] unlink();
            machine_triggers[e].origin = origin;
            machine_triggers[e].angles = angle;
        }
    }
}

teleport_pap()
{
    if( !isDefined( level.custom_pap ) )
        level.custom_pap = true;
    else 
        level.custom_pap = undefined;

    self thread do_teleport_pap( level.custom_pap );
}

do_teleport_pap( custom = false )
{
    foreach( ent in level.pack_a_punch.triggers )
    {
        if( !isDefined( ent.default_origin ) )
        {
            ent.default_origin_t = ent.origin;
            ent.default_origin = ent.zbarrier.origin;
        }

        ent.origin = custom ? (self.origin + (0,0,level.pack_a_punch.interaction_height)) : ent.default_origin_t;
        ent.zbarrier.origin = custom ? self.origin : ent.default_origin;
    }
}

do_zombie_colour( value )
{
    self thread clientfield::set_to_player("eye_candy_render", value);
}

toggle_napalm_zombies()
{
    if(!isDefined( level.napalm_zombies ))
    {
        if(isDefined(level.sparky_zombies))
        {
            spawner::remove_global_spawn_function("zombie", ::sparky_zombies);
            level.sparky_zombies = undefined;
        }
        level.napalm_zombies = true;
        spawner::add_archetype_spawn_function("zombie", ::napalm_zombies);
        self iPrintLnBold("Newly Spawned Zombies Will Be Napalm!");
    }
    else 
    {
        level.napalm_zombies = undefined;
        spawner::remove_global_spawn_function("zombie", ::napalm_zombies);
    }
}

napalm_zombies()
{
    ai_zombie = self;
    if(!isdefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
    {
        ai_zombie.is_elemental_zombie = 1;
        ai_zombie.var_9a02a614 = "napalm";  
        ai_zombie clientfield::set("arch_actor_fire_fx", 1);
        ai_zombie clientfield::set("napalm_sfx", 1);
        ai_zombie.health = Int(ai_zombie.health * 0.75);
        ai_zombie thread special_zombie_death_effects( "napalm_zombie_death_fx" );
        ai_zombie thread special_zombie_damage_monitor( "napalm_damaged_fx" );
        ai_zombie zombie_utility::set_zombie_run_cycle("sprint");
    }
}

napalm_shellshock(damage, attacker, direction_vec, point, mod)
{
    if(GetDvarString("blurpain") == "on")
        self shellshock("pain_zm", 0.5);
}

toggle_sparky_zombies()
{
    if(!isDefined( level.sparky_zombies ))
    {
        if(isDefined(level.napalm_zombies))
        {
            spawner::remove_global_spawn_function("zombie", ::napalm_zombies);
            level.napalm_zombies = undefined;
        }
        level.sparky_zombies = true;
        spawner::add_archetype_spawn_function("zombie", ::sparky_zombies);
        self iPrintLnBold("Newly Spawned Zombies Will Be Sparky!");
    }
    else 
    {
        level.sparky_zombies = undefined;
        spawner::remove_global_spawn_function("zombie", ::sparky_zombies);
    }
}

sparky_zombies()
{
    ai_zombie = self;
    if(!isdefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
    {
        ai_zombie.is_elemental_zombie = 1;
        ai_zombie.var_9a02a614 = "sparky";
        ai_zombie clientfield::set("sparky_zombie_spark_fx", 1);
        ai_zombie.health = Int(ai_zombie.health * 1.5);
        ai_zombie thread special_zombie_death_effects( "sparky_zombie_death_fx" );
        ai_zombie thread special_zombie_damage_monitor( "sparky_damaged_fx" );
    }
}

special_zombie_damage_monitor( type )
{
    self endon("entityshutdown");
    self endon("death");
    while(1)
    {
        self waittill("damage");
        if(RandomInt(100) < 50)
            self clientfield::increment(type);
        wait(0.05);
    }
}

special_zombie_death_effects( type )
{
    ai_zombie = self;
    ai_zombie waittill("death", attacker);
    if(!isdefined(ai_zombie) || ai_zombie.nuked == 1)
        return;
    ai_zombie clientfield::set(type, 1);
    ai_zombie zombie_utility::gib_random_parts();
    GibServerUtils::Annihilate(ai_zombie);
    if( type == "napalm_zombie_death_fx" )
        ai_zombie.custom_player_shellshock = ::napalm_shellshock;

    RadiusDamage(ai_zombie.origin + VectorScale((0, 0, 1), 35), 128, 70, 30, self, "MOD_EXPLOSIVE");
}

toggle_bgb_circle()
{
    if( !isDefined( level.bgb_circle ) )
    {
        level.bgb_circle = true;
        self thread teleport_bgb_machine();
    }
    else 
    {
        level.bgb_circle = undefined;
        self thread teleport_bgb_machine( true );
    }
}

teleport_bgb_machine( reset = false )
{
    size = 360 / level.bgb_machines.size;
    for(e = 0; e < level.bgb_machines.size; e++)
    {
        machine = level.bgb_machines[e];
        
        if( !isDefined( machine.default_origin ) )
        {
            machine.default_origin = machine.origin;
            machine.default_angles = machine.angles;
        }
            
        origin = reset ? machine.default_origin : self.origin + ( cos(e*size) * 100, sin(e*size) * 100, 0 );
        angle  = reset ? machine.default_angles : ( 0, (e*size) + 270, 0 );
        
        machine.origin = origin;
        machine.angles = angle;
        
        machine.unitrigger_stub.origin = machine.origin + (anglestoright( machine.angles ) * 22.5);
        machine zm_unitrigger::unregister_unitrigger(machine.unitrigger_stub);
        ///TODO ADD BACK IN, FREEZE ON SOME CUSTOM MAPS
        machine thread zm_unitrigger::register_static_unitrigger(machine.unitrigger_stub, bgb_machine::bgb_machine_unitrigger_think);
    }    
}

Ac130( walking )
{
    self endon("death");
    self endon("stop_ac130");
    self endon("disconnect");
    
    if( IsDefined( self.isInAc130 ) )
        return;
    
    self thread refreshMenu();
    self.saved_origin = undefined;
    self.isInAc130    = true;
    
    if( !isDefined( walking ) )
    {
        AC130Mid      = self.origin;
        self.saved_origin = self.origin;
        
        self.ac130m = [];
        self.ac130m[0] = modelSpawner( AC130Mid + (0,0,1400), "tag_origin" ); //rotate
        self.ac130m[1] = modelSpawner( AC130Mid + (460,0,1070), "tag_origin", (0,180,0) ); //seat
        self.ac130m[1] linkTo( self.Ac130M[0] );
        
        self PlayerLinkToDelta( self.Ac130M[1], "tag_origin", 1, 85, 85, 0, 100 );
        self hide();
    }       
        
    self.ac130m[0] thread killstreakCircle( 13 );
    self thread Ac130Monitor();

    self editMovements( 0 );
    self EnableInvulnerability();
    self disableWeaponCycling();
    self disableWeapons();
}

Ac130Monitor()
{
    self endon("death");
    self endon("stop_ac130");
    self endon("disconnect");

    huds = [];
    huds[0] = strTok("21;0;2;24;-20;0;2;24;0;-11;40;2;0;11;40;2;0;-39;2;57;0;39;2;57;-48;0;57;2;49;0;57;2;-155;-122;2;21;-154;122;2;21;155;122;2;21;155;-122;2;21;-145;132;21;2;145;-132;21;2;-145;-132;21;2;146;132;21;2", ";");
    huds[1] = strTok("0;-70;2;115;0;70;2;115;-70;0;115;2;70;0;115;2;0;-128;14;2;0;128;14;2;-128;0;2;14;128;0;2;14;0;-35;8;2;0;35;8;2;-29;0;2;8;29;0;2;8;-64;0;2;9;64;0;2;9;0;-85;10;2;0;85;10;2;-99;0;2;10;99;0;2;10", ";");
    huds[2] = strTok("21;0;35;2;-21;0;35;2;0;25;2;46;-60;-57;2;22;-60;57;2;22;60;57;2;22;60;-57;2;22;-50;68;22;2;50;-68;22;2;-50;-68;22;2;50;68;22;2;6;9;1;7;9;6;7;1;11;14;1;7;14;11;7;1;16;19;1;7;19;16;7;1;21;24;1;7;24;21;7;1;26;29;1;7;29;26;7;1;36;33;6;1", ";");
    weapons = strTok("hunter_rocket_turret_player;launcher_standard_upgraded;pistol_standardlh_upgraded", ";");
    info    = strTok("105mm,40mm,25mm", ",");

    self.ac130 = [];
    curs = 0;
    
    for(;;)
    {
        if(self useButtonPressed())
        {
            curs++;
            if(curs > 2)
                curs = 0;
        
            if(isDefined(self.ac130[0]))
            {
                self destroyAll( self.ac130 );
                self.ac130 = [];    
            }
            
            for(e=0; e < (huds[curs].size / 4); e++)
            self.ac130[e] = self createRectangle("CENTER", "CENTER", int(huds[curs][4*e]), int(huds[curs][(4*e)+1]), int(huds[curs][(4*e)+2]), int(huds[curs][(4*e)+3]), (1,1,1), "white", 11, 1);
            self iprintlnBold(info[curs]);
            
            wait .3;
        }
        else if(self attackButtonPressed())
        {
            weapon = getWeapon( weapons[curs] );
            MagicBullet( weapon, self GetWeaponMuzzlePoint(), self lookPos(), self );
            Earthquake( 1 / (curs + 1), 1 / (curs + 1), self.origin, 500 );
            
            wait weapon.fireTime;
        }
        else if(self meleeButtonPressed())
        {
            self killstreakEnd( "stop_ac130", "Ac130" );
            break;
        }
        wait .05;
    }
}

killstreakEnd( notify0, type = "" )
{
    if( type == "Ac130" )
    {
        self.isInAc130 = undefined;
        array_delete( self.ac130m );
        self destroyAll( self.ac130 );
    }
    
    self setOrigin( self.saved_origin );
    self enableWeaponCycling();
    self enableOffhandWeapons();
    self enableWeapons();
    self editMovements( 1 );
    if(!isDefined( self.godmode ))
        self DisableInvulnerability();
    if(!IsDefined( self.invisibility ))
        self show();
    self notify( "reopen_menu" );
    self notify( notify0 );
}

killstreakCircle( time )
{
    self endon("death");
    while( isDefined( self ) )
    {
        self rotateTo((self.angles[0], self.angles[1]+90, self.angles[2]), time);
        wait time;
    }
}

editMovements( bool )
{
    self allowCrouch( bool );
    self allowSprint( bool );
    self allowProne( bool );
    //self allowjump( num );
}

missile_barrage()
{
    self thread refreshMenu();
    self.isMissleBarrage = true;
    
    marker = [];
    position = self lookPos();
    marker[0] = modelSpawner( position, "tag_origin" );
    
    size = 360 / 14;
    for(e=0;e<14;e++)
    {
        marker[ marker.size ] = modelSpawner( position + (cos(e*size) * 50, sin(e*size) * 50, 0), "tag_origin" );
        marker[ marker.size-1 ] clientfield::set( "powerup_fx", 1 );
    }
    
    while( !self AttackButtonPressed() )
    {
        for(e=0;e<14;e++)
        {
            position = getGroundPoint( lookpos() + (cos(e*size) * 50, sin(e*size) * 50, 60) ) + (0,0,4);
            marker[ e + 1 ].origin = position;
        }
        marker[0].origin = lookpos();
        wait .05;
    }
    self iPrintLnBold( "Location Confirmed: Attack Incoming!" );
    
    weapons = ["launcher_standard_upgraded", "pistol_standardlh_upgraded"];
    for(e=0;e<10;e++)
    {
        weapon = getWeapon( weapons[ RandomInt(2) ] );
        MagicBullet( weapon, marker[0].origin + (RandomIntRange(-100,100), RandomIntRange(-100,100), RandomIntRange(600,800)), marker[0].origin, undefined );
        wait weapon.fireTime;
    }
    wait .2;
    array_delete( marker );
    self.isMissleBarrage = undefined;
    self notify( "reopen_menu" );
}

spawn_controllable_zombie()
{
    self thread refreshMenu();
    self.isControllableZombie = true;
    self.saved_origin         = self.origin;
    
    ai        = zombie_utility::spawn_zombie(level.zombie_spawners[0]);
    ai.origin = self.origin;
    ai.angles = self.angles;
    ai.health = 9999999;
    
    ai notSolid();
    
    wait .1;
    
    self FreezeControls(1);
    self LUI::screen_fade_out(0.25);
    self playerLinkToDelta( ai, "tag_origin" );
    
    self LUI::screen_fade_in(0.25);
    self.ignoreme = true;
    
    self Hide();
    self setClientThirdPerson( true ); 
    self DisableWeapons();
    self DisableOffhandWeapons();
    self SetPlayerCollision( 0 );
    self EnableInvulnerability();
    self FreezeControls( 0 );

    marker = modelSpawner(self.origin, "tag_origin");
    marker clientfield::set( "powerup_fx", 1 );
    
    ai zombie_utility::set_zombie_run_cycle( "sprint" ); 
    for(;;) 
    {
        wait .05;
        if( !IsDefined( ai ) )
            break;
        if( !( isDefined( ai.completed_emerging_into_playable_area ) && ai.completed_emerging_into_playable_area ) )
            continue;
            
        movementDirection = self GetNormalizedMovement();
        if( movementDirection[0] >= 0.15 || movementDirection[1] >= 0.15 || movementDirection[0] <= -0.15 || movementDirection[1] <= -0.15 )
        {
            newValidPosition = self lookPos( 180 ); 
            newValidPosition = GetClosestPointOnNavMesh(newValidPosition, 100, 30);
            if(!isdefined(newValidPosition)) 
                continue;
            marker.origin = newValidPosition;

            ai ClearEntityTarget();
            ai SetGoal( newValidPosition, 1 );
        }
            
        if( self AttackButtonPressed() )
        {
            closest = undefined;
            foreach( ent in ArrayCombine(level.players, GetAIArray(), false, false) )
            {
                if( ent == ai || ent == self )
                    continue;
                if( closer( ai.origin, ent.origin, closest.origin ) )
                    closest = ent;
            }
            if( BulletTracePassed(ai.origin, closest.origin, true, ai ) && Distance(ai.origin, closest.origin) <= 72 )
            {
                ai.team = level.zombie_team;
                if(!isPlayer( closest ))
                    ai.team = self.team;
            }
        } 
    
        if( self MeleeButtonPressed() )
            break;
    }
        
    if( IsDefined( ai ) )
        ai kill();
    if( !IsDefined( self.thirdPerson ) )
        self setClientThirdPerson( false ); 
        
    self.isControllableZombie = undefined;
    self.ignoreme             = false;
    self SetPlayerCollision( 1 );
    self thread killstreakEnd( "temp" );
    marker delete();
    self notify( "reopen_menu" );
}

valkyrieMissile()
{
    self endon("disconnect");
    self thread refreshMenu();
    wait .1;
    
    self.isInValkyie = true;
    self disableWeapons();
    saved_origin = self.origin;
    
    hud = [];
    xyz = strTok("15;0;2;30;-15;0;2;30;0;-15;30;2;0;15;30;2;25;0;20;2;-25;0;20;2;0;25;2;20;0;-25;2;20;87;100;26;2;100;87;2;26;-87;100;26;2;100;-87;2;26;87;-100;26;2;-100;87;2;26;-87;-100;26;2;-100;-87;2;26",";");
    for(i = 0; i < xyz.size; i += 4)
        hud[hud.size] = self createRectangle("CENTER", "CENTER", int(xyz[i]), int(xyz[i + 1]), int(xyz[i + 2]), int(xyz[i + 3]), (1,1,1), "white", 1, 1);
       
    valkyries = 2;
    while( valkyries != 0 )
    {
        if( self AttackButtonPressed() )
        {
            level thread LUI::screen_flash(0.1, 0.2, 1, 1, "white");
            wait .2;
            missile = modelSpawner( self GetWeaponMuzzlePoint(), "p7_zm_power_up_nuke", vectorToAngles(lookPos() - (0,0,70)));
            missile clientfield::set( "powerup_fx", 2 );
            
            self hide();
            self playerLinkTo( missile );
            
            while(IsDefined( missile ))
            {
                vector      = anglesToForward( missile.angles );
                forward     = missile.origin + (vector[0]*45, vector[1]*45, vector[2]*45);
                collision   = bulletTrace( missile.origin, forward, false, self );
                missile.angles = (vectorToAngles( (lookPos()-(0,0,70) ) - missile.origin ) );
                
                missile moveTo(forward,.05);
                wait .05;
                
                if(collision["surfacetype"] !="default" && collision["fraction"] < 1)
                {
                    position = missile.origin;
                    playFx(level._effect["zombie_guts_explosion"], position, AnglesToForward(self.angles));

                    a_ai_zombies = Array::get_all_closest(position, GetAITeamArray("axis"), undefined, undefined, 360);
                    foreach( zombie in a_ai_zombies )
                    {   
                        zombie DoDamage( zombie.health, position, self, self, "none", "MOD_IMPACT" );

                        v_curr_zombie_origin = zombie GetCentroid();
                        n_random_x = RandomFloatRange(-3, 3);
                        n_random_y = RandomFloatRange(-3, 3);
                        zombie StartRagdoll(1);
                        zombie LaunchRagdoll(50 * VectorNormalize(v_curr_zombie_origin - position + (n_random_x, n_random_y, 30)), "torso_lower");
                    }

                    PlayRumbleOnPosition( "grenade_rumble", position );
                    earthquake( 0.5, 0.75, position, 800 );
                            
                    playSoundAtPosition("wpn_grenade_explode", position);
                    missile hide();
                    level thread LUI::screen_flash(0.2, 0.3, 1, 1, "white");
                    wait .2;
                    missile delete();
                }
            }
            self setOrigin(saved_origin);
            
            if(!IsDefined( self.invisibility ))
                self show();
                
            valkyries--; 
        }
        if(self MeleeButtonPressed())
            break;
        wait .05;
    }
    
    self destroyAll( hud );
    self EnableWeapons();
    self.isInValkyie = undefined;
    self notify( "reopen_menu" );
}

gravity_missile()
{
    if( !IsDefined( self.gravityMissile ) )
    {
        self.gravity_missile = true;
        self thread monitor_missiles();
    }
    else 
    {
        self.gravity_missile = undefined;
        self notify("stop_missile_monitor");
    }
}

monitor_missiles()
{
    self endon("disconnect");
    self endon("stop_missile_monitor");
    
    while( IsDefined( self.gravityMissile ) ) 
    {
        self waittill( "missile_fire", bullet, weaponName );
        if(!IsDefined( bullet ))
            continue;
        bullet thread force_gravity( 20, 9999, 0.1 );   
    }
}

force_gravity( force, duration, timescale ) 
{
    self endon("death");
    while(IsDefined(self)) 
    {
        self.angles = VectorToAngles( ( (self.origin + AnglesToForward( self.angles ) * 1000) - (0,0,force) ) - self.origin );
        wait timescale;
    }
}

powerup_magnet()
{
    if(!isDefined( self.powerup_magnet ))
    {
        self.powerup_magnet = true;
        self thread do_powerup_magnet();
    }
    else 
    {
        self.powerup_magnet = undefined;
        self notify("powerup_magnet");
    }
}

do_powerup_magnet()
{
    self endon("death");
    self endon("disconnect");
    self endon("powerup_magnet");

    while(isdefined( self.powerup_magnet ))
    {
        a_powerups = util::get_array_of_closest( self.origin, level.active_powerups, undefined, undefined, 400 );
        if( isDefined( a_powerups ) && a_powerups.size > 0 )
        {
            foreach( powerup in a_powerups )
            {
                if(isDefined( powerup.a_is_picked_up ))
                    continue;

                powerup thread moveToOriginOverTime( self.origin + (0,0,33), .6, self, (0,0,33) );
                powerup.a_is_picked_up = true;
            }
        }
        wait .2;
    }
}