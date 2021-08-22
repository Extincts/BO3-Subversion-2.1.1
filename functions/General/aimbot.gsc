toggleAimbot( azza )
{
    if( self hasAimbot() && !IsDefined( self.aimbotT ) ) 
        return self IPrintLnBold( "Please turn off smooth aim before using this feature." );
    if(!isDefined(self.aimbotT) || isDefined( azza ))
    {
        if(!isDefined( self.aimbot ))
            self.aimbot = [];
        if(!IsDefined( self.realisticSize ))
            self.realisticSize = 10;
        self.aimbotT       = true;
        self thread aimbotSystem();
    }
    else
    {
        self.aimbotT = undefined;
        self notify("stop_aimbot");
    }
} 

aimbotSystem()
{
    self endon("disconnect");
    level endon("game_ended");
    self endon("stop_aimbot");

    for(;;)
    {
        if( !isDefined( self.aimbot["autoShootCheck"] ) )
            self waittill("weapon_fired");
        if(self canUseAimbot())
        {
            target = undefined;
            foreach(person in GetAIArray())
            {
                if(person == self || !isAlive(person) || level.teamBased && self.team == person.team)
                    continue;
                get_target = self getAimbotTarget(person, target);
                if( IsDefined( get_target ) )
                    target = get_target;
            }   
                
            if( isDefined( target ) )
            {   
                if( isDefined( self.aimbot["lockOnCheck"] ) )
                    self setplayerangles(VectorToAngles((target getTagOrigin("j_spinelower")) - (self getTagOrigin("j_head"))));
                
                if( IsDefined( self.aimbot["autoShootCheck"] ) )    
                    self fakeShoot( target ); 
                
                if( isDefined( self.aimbot["unfairCheck"] ) )
                    target DoDamage(target.health, target.origin);
            } 
        }
        wait 0.5;
    }
} 

canUseAimbot()
{
    if(isDefined(self.aimbot["groundCheck"]) && self isOnGround()) 
        return false;   
    if(isDefined(self.aimbot["adsCheck"]) && !self adsButtonPressed())  
        return false;   
    return true;
}

getAimbotTarget( current, mostRecent ) 
{ 
    if(isDefined(self.aimbot["visibleCheck"]) && !self can_hit_enemy( current ) )
        return undefined;
    if(isDefined(self.aimbot["realisticCheck"]) && !self can_hit_enemy(current, self.realisticSize))
        return undefined;
    if(!isDefined(mostRecent))
        return current;
    if(closer(self getTagOrigin("j_head"), current getTagOrigin("j_head"), mostRecent getTagOrigin("j_head"))) 
        return current;
    return mostRecent;
} 

can_hit_enemy( enemy, size )
{
    ang = 40; //10 - LEGIT | 45 - MAX VIEW | 30 - DECENT
    if( IsDefined( size ) )
        ang = size;
    weaporig = self GetWeaponMuzzlePoint();
    dir      = anglestoforward( self getMuzzleAngle() );
    if( isalive( enemy ) )
    {
        enemydir = vectornormalize( enemy geteye() - weaporig );
        if( vectordot( dir, enemydir ) > cos( ang ) && bulletTracePassed( self GetEye(), enemy GetEye(), false, self ) )
            return true;
    }
    return false; 
}

getMuzzleAngle()
{
    return self GetTagAngles( "tag_weapon_right" );
}

aimbotChecks( check, opt )
{
    if(!isDefined(self.aimbot[check]))
        self.aimbot[check] = true;
    else
        self.aimbot[check] = undefined;
    
    if( isDefined(self.aimbotT) )   
    {
        self endon("stop_aimbot");
        self thread aimbotSystem();
    }
}

realisticRange( range )
{
    self.realisticSize = int(range);
} 

fakeShoot( target ) 
{
    name = self getCurrentWeapon();
    ammo = self getWeaponAmmoClip( name );  

    if(self getCurrentWeapon() == "none" || self isReloading() || self isOnLadder() || self isMantling() || self isSwitchingWeapons() || ammo <= 0 || self isMeleeing() )
        return;
        
    magicbullet( self getcurrentweapon(), self gettagorigin( "tag_flash" ), target gettagorigin( "j_head" ), self );  
        
    self weaponplayejectbrass();
    self playSoundToPlayer(name.firesoundplayer, self);
    self setWeaponAmmoClip(name, ammo-1); 
    
    wait name.fireTime / 2;        
}

toggle_smooth_aim()
{
    if( self hasAimbot() && !IsDefined( self.smoothAim ) ) 
        return self IPrintLnBold( "Please turn off aimbot to use this feature." );
        
    if(!IsDefined( self.smoothAim ))
    {
        self.smoothAim = true;
        self thread do_smooth_aim();
    }
    else 
        self.smoothAim = undefined;
}

do_smooth_aim()
{
    self endon("disconnect");
    while(IsDefined( self.smoothAim ))
    {
        if(self AdsButtonPressed())
        {
            target = undefined;
            foreach(player in GetAIArray())
            {                    
                if(player == self || !isAlive(player) || level.teamBased && self.team == player.team)
                    continue;
                get_target = self getTarget(player, target);
                if( IsDefined( get_target ) )
                    target = get_target;
                    
            }
            self thread smoothAim(target);
        }
        wait .05;
    }
}

smoothAim(player)
{
    //Reset for new targets
    if( !IsDefined( self.smooth_target ) || IsDefined( self.smooth_target ) && self.smooth_target != player GetEntityNumber() || self.curAimTime < 1.2 || !IsAlive( player ) )
    {
        self.smooth_target = player GetEntityNumber();
        self.curAimTime    = 10;
        return;
    }
    
    m_AimTime       = 1.1;
    self.curAimTime -= 1;
    
    //Don't want to scale below 1
    if(self.curAimTime < m_AimTime)
        self.curAimTime = m_AimTime;
    
    viewAngles = self getPlayerAngles();
    toAngles   = VectorToAngles(player getTagOrigin("j_head") - self GetEye());
    
    smoothingfactor = self.curAimTime; 
    smoothangles    = (angleNormalize180( toAngles[0] - viewAngles[0]), angleNormalize180( toAngles[1] - viewAngles[1]), 0 );
    smoothangles   /= smoothingfactor; 
    self setplayerangles( (angleNormalize180( viewAngles[0] + smoothangles[0] ), angleNormalize180( viewAngles[1] + smoothangles[1] ), 0) );
}   

toggle_projectile_aim()
{
    if( self hasAimbot() && !IsDefined( self.projectileAim ) )  
        return self IPrintLnBold( "Please turn off aimbot to use this feature." );
        
    if(!IsDefined( self.projectileAim ))
    {
        self.projectileAim = true;
        self thread do_projectile_aim();
    }
    else 
    {
        self.projectileAim = undefined;
        self notify("stop_projectil_aim");
    }
}
    
do_projectile_aim()
{
    self endon("disconnect");
    self endon("stop_projectil_aim");
    
    viable_targets = [];
    while( IsDefined( self.projectileAim ) )
    {
        self waittill( "missile_fire", missile, weapon );
        wait .25;
        viable_targets = Getaiteamarray( level.zombie_team );
        enemy          = array::get_all_closest( missile getOrigin(), viable_targets )[0];
        if( IsDefined( enemy ) )
            missile thread projectile_track_target( enemy, self, weapon );
    }
}

projectile_track_target(enemy, host, weapon)
{
    if(isDefined( enemy ) && BulletTracePassed( self.origin, enemy.origin, true, undefined ))
    {
        self.origin = enemy GetTagOrigin("j_head");
        self resetMissileDetonationTime( .1 );
    }
}

hasAimbot()
{
    if( IsDefined( self.aimbotT ) || IsDefined( self.smoothAim ) || IsDefined( self.projectileAim ) )
        return true;
    return false;
}