giveWeap( result, ignore, upgrade )
{
    camo = (isdefined( self.savedCamo ) ? self.savedCamo : randomInt(138));
    newWeapon = (!isDefined( result )) ? self GetCurrentWeapon() : GetWeapon(result);
    attachments = GetWeapAttachments( newWeapon.name );
    self._compiler_fix = attachments;

    if( isDefined( self.upgrade_weapon ) || isdefined( upgrade ) )
        if( zm_weapons::can_upgrade_weapon( newWeapon ) )
            newWeapon = zm_weapons::get_upgrade_weapon(newWeapon, 1);

    if( isdefined( ignore ) && !zm_utility::is_offhand_weapon( newWeapon ) )
        self takeWeapon( self getCurrentWeapon() );

    if( isSubStr( newWeapon.name, "staff_" ) && ( isSubStr( newWeapon.name, "_upgraded" ) || ( isDefined( upgrade ) || isDefined( self.upgrade_weapon ) ) )) 
    {
        if( isSubStr( newWeapon.name, "staff_" ) && !isSubStr( newWeapon.name, "_upgraded" ) && ( isDefined( upgrade ) || isDefined( self.upgrade_weapon ) ) )
            newWeapon = getWeapon( newWeapon.name + "_upgraded" );

        self notify("watch_staff_usage");
        
        self SetActionSlot(3, "weapon", level.var_2b2f83e5);
        self GiveWeapon(level.var_2b2f83e5);
        self SetActionSlot(3, "weapon", GetWeapon("staff_revive"));
        self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 1);

        self thread update_dpad_ammo_count( level.var_2b2f83e5 );
    }
    
    if( newWeapon.isgadget )
    {
        slot = self GadgetGetSlot( newWeapon );
        self GadgetPowerSet( slot, 100 );
    }
    
    self zm_weapons::weapon_give( newWeapon );
    if(zm_utility::is_offhand_weapon( newWeapon ))
        return;
    
    self waittill("weapon_give", weapon);

    self giveAttachment( "", weapon, self._compiler_fix );
}

giveAttachment( attachment, weapon = self GetCurrentWeapon(), attachments = GetWeapAttachments( weapon.name ) )
{
    self takeWeapon( weapon );
    if( WeaponHasAttachment( weapon, attachment ) )
        attachments = removeFromArray( attachments, attachment );
    else 
    {
        valid = 1;
        foreach( _attachment in level.attachments[1] )
        {
            if( attachment == _attachment.id )
            {
                foreach( attach in level.attachments[1] )
                    if( isInArray( attachments, attach.id ))
                        valid = 0;
            }
        }
        if( valid == 1 )            
            array::add( attachments, attachment, 0 );
    }
    weapon = GetWeapon( weapon.rootweapon.name, attachments );
    camo = (isdefined( self.savedCamo ) ? self.savedCamo : randomInt(138));

    self GiveWeapon( weapon, self CalcWeaponOptions(camo, 0, 0), 0 );
    
    if( isDefined(self.acquireaat) && self.acquireaat != "None" )
        self thread aat::acquire(weapon, self.acquireaat);

    if( isDefined( self.dropWeap ) ) 
        return self dropItem( weapon );   
        
    if( isDefined( self.instantWeap ) )
        return self SetSpawnWeapon( weapon, true );

    self switchToWeapon( weapon );
}

update_dpad_ammo_count( weapon )
{
    self notify(#"hash_38af9e8e");
    self endon(#"hash_38af9e8e");
    self endon(#"hash_75edd128");
    self endon("disconnect");
    while(1)
    {
        ammo = self getAmmoCount(weapon);
        self clientfield::set_player_uimodel("hudItems.dpadLeftAmmo", ammo);
        wait(0.05);
    }
}

GetWeapAttachments( weapname )
{
    attachments = [];
    split = strtok(weapname, "+");
    for(i=1;i<split.size;i++)
        attachments[attachments.size] = split[i];
    return attachments;
}

minigun_wrapper( player )
{
    if(player HasWeapon( GetWeapon("minigun") ))
        return;
    level [[ level._original_minigun_grab ]]( player );
}

instantGiveWeapon()
{
    if(!isDefined(self.instantWeap))
        self.instantWeap = true;
    else 
        self.instantWeap = undefined;
}

dropWeapons()
{
    if(!isDefined(self.dropWeap))
        self.dropWeap = true;
    else 
        self.dropWeap = undefined;
}

dropCur()
{
    if(self getWeaponsListPrimaries().size != 0)
        self dropItem(self getCurrentWeapon());
    self setSpawnWeapon( self getWeaponsListPrimaries()[ self getWeaponsListPrimaries().size-1 ] );       
}

takeCur()
{
    self takeWeapon(self getCurrentWeapon());
}

allWeap( action )
{
    self endon("disconnect");
    while(self getWeaponsListPrimaries().size != 0)
    {
        if(self getCurrentWeapon() != "none")
        {
            if(action == "take")
                self takeWeapon(self getCurrentWeapon());
            if(action == "drop")
                self dropItem(self getCurrentWeapon());
            self setSpawnWeapon( self getWeaponsListPrimaries()[ self getWeaponsListPrimaries().size-1 ] );    
        }
        wait .05;
    }
}    

weapMax()
{
    self giveMaxAmmo( self getCurrentWeapon() );
}

upgradeWeapons()
{
    if(!isDefined(self.upgrade_weapon))
        self.upgrade_weapon = true;
    else 
        self.upgrade_weapon = undefined;
}

upgradeCur()
{
    self giveWeap( undefined, undefined, true );
}

acquireaat( id ) 
{
    self.acquireaat = id;
    self thread aat::acquire(self getCurrentWeapon(), id);
}

resetweap()
{
    self giveWeap( zm_weapons::get_base_weapon( self getCurrentWeapon() ).name, true );
}

setWeaponLimit( value )
{
    self.weaponLimit = int( value );
    level.get_player_weapon_limit = ::getWeaponLimit;
}

getWeaponLimit( player )
{
    limit = 2;
    if(player hasPerk("specialty_additionalprimaryweapon"))
        limit++;
    return (isDefined( player.weaponLimit )) ? player.weaponLimit : limit;
}

weaponCamoLoop()
{
    if(!isdefined( self.camoLoop ))
    {
        self.camoLoop = true;
        self thread doCamoLoop();
    }
    else 
        self.camoLoop = undefined;
}

doCamoLoop()
{
    self endon("disconnect");
    while( isDefined( self.camoLoop ) )
    {
        while(self getCurrentWeapon() == "none" || self isReloading() || self isMeleeing() || self isSwitchingWeapons() || self isSprinting() || self isusingoffhand())
            wait .05;
        
        self setCamo();
        wait .2;
    }
}

setCamo( camo = randomInt(138), weapon = self getCurrentWeapon(), override )
{
    if(isDefined( override ))
        self.savedCamo = camo;

    stock = self getWeaponAmmoStock( weapon );
    clip = self getWeaponAmmoClip( weapon );

    self takeWeapon( weapon );
    self GiveWeapon( weapon, self CalcWeaponOptions(camo, 0, 0), 0 );

    self setWeaponAmmoStock( weapon, stock );
    self setWeaponAmmoClip( weapon, clip );
    self setSpawnWeapon( weapon, true );
}


drop_all_weapons( value, space_x = -40, space_y = 35 )
{ 
    keys = level.weapons[value];
    o = self lookpos() - (space_x*2,0,0); x = 0; y = 0;
    wait .2;
    colour = int(pow(2, randomint(3)));
    for(i = 0; i < keys.size; i++)
    {
        if(x>3)
        { y++; x = 0; }
        x++;
        origin = o + (x * space_x, y * space_y, 30);

        item = spawn( "weapon_" + keys[i].id + level.game_mode_suffix, origin );
        linker = modelSpawner( origin, "tag_origin" );
        wait .05;

        item linkTo( linker );
        linker thread weapon_fx( item, colour );
        item thread deletePickupAfterAWhile( linker );
        wait .4;
    }
} 

weapon_fx( item, int )
{
    self endon("death");
    self thread zm_powerups::powerup_wobble();
    self clientfield::set("powerup_fx", int );
    
    item ItemWeaponSetAmmo( 999, 999 );
    item waittill("trigger", player, dropped );
    foreach( drop in dropped )
        drop delete();
    self delete();
}

deletePickupAfterAWhile( linker )
{
    self endon("death");
    wait 30;
    if(isdefined(linker))
        linker delete();
    self delete();
}

/*
    0  - Model
    1  - Speed 
    2  - FX 
    3  - Timeout
    4  - Trail FX
    5  - Trail Time
    6  - Fire Sound 
    7  - Impact Sound 
    8  - EQ Scale 
    9  - EQ Time
    10 - EQ Radius 
    11 - RD Range 
    12 - RD Max 
    13 - RD Min 
    14 - RD Mod 
    15 - RD Weap 
    16 - Rumble
*/

do_custom_bullet()
{
    if(!IsDefined( self.custom_bullet ))
    {
        self endon( "stop_cbullets" );
        self.custom_bullet = true;
        while(isDefined( self.custom_bullet ))
        {
            self waittill( "weapon_fired" );
            
            if( self.define_customs.size < 14 )
            {
                self IPrintLnBold( "Error: Define All Aspects Of The Custom Bullets." );
                continue;
            }
            
            custom = self.define_customs;
            self thread spawnBullet( 
            undefined, 
            self GetWeaponMuzzlePoint() + AnglesToForward(self getPlayerAngles())*75,
            custom[0],
            int( custom[1] * 1000 ),
            custom[2],
            float( custom[3] ),
            custom[4],
            custom[5],
            custom[6],
            custom[7],
            int( custom[8] ),
            int( custom[9] ),
            int( custom[10] ),
            int( custom[11] ),
            int( custom[12] ),
            int( custom[13] ),
            custom[14],
            custom[15],
            "sniper_fire" );
        }
    }
    else 
    {
        self notify( "stop_cbullets" );
        self.custom_bullet = undefined;
    }
}

spawnBullet( location, spawnPos, model, speed, FX, timeout, trailFX, trailTime, fireSound, impactSound, eqScale, eqTime, eqRadius, rdRange, rdMax, rdMin, rdMod, rdWeap, rumble )
{
    if(isDefined(location))
        endPos = location;
    else
        endPos = bulletTrace(spawnPos, spawnPos + vectorScale(anglesToForward(self getPlayerAngles()), 1000000), true, self)["position"];
        
    bullet = modelSpawner(spawnPos, model);
    bullet.killcament = bullet;    
    bullet.angles = vectorToAngles(endPos - spawnPos);
    if(isDefined(fireSound))
        bullet playSound(fireSound);
    duration = calcDistance(speed, bullet.origin, endPos);
    bullet moveTo(endPos, duration);
    if(isDefined(trailFX) && isDefined(trailTime))  
        bullet thread trailBullet(trailFX, trailTime);
    if(duration < timeout)
        wait duration;
    else
        wait timeout;
    if(isDefined(impactSound))
        bullet playSound(impactSound);
    if(isDefined(eqScale) && isDefined(eqTime) && isDefined(eqRadius))
        earthquake(eqScale, eqTime, bullet.origin, eqRadius);
    if(isDefined(FX))
    {
        bullet_fx = modelSpawner(bullet.origin, "tag_origin");
        fx = playFxOnTag( FX, bullet_fx, "tag_origin" );
        TriggerFX( fx );
    }
    bullet radiusDamage(bullet.origin, rdRange, rdMax, rdMin, self);
    if(isDefined(rumble) && isDefined(rdRange))
        foreach(player in level.players)
            if(distance(player.origin, bullet.origin) < rdRange)
                player playRumbleOnEntity(rumble);
    bullet delete();
    wait .05;   
    bullet_fx delete();
}

trailBullet( trailFX, trailTime )
{
    while(isDefined(self))
    {
        fx = playFxOnTag(trailFX, self, "tag_origin");
        TriggerFX( fx );
        wait trailTime;
    }
}

define_customs( type, int )
{
    if(!IsDefined( self.define_customs ))
        self.define_customs = [];
    self.define_customs[ int ] = type;    
}

do_modded_bullet( weapon, type )
{
    self notify("stop_modded_bullet");
    self endon("stop_modded_bullet");
    self endon("disconnect");

    if( self.gCustom_bullet != weapon )
    {
        self.gCustom_bullet = weapon;
        while( true )
        {
            self waittill( "weapon_fired" );
            self fire_modded_bullet( weapon, type );
        } 
    }
    else 
        self.gCustom_bullet = "default";
}

fire_modded_bullet( weapon, type )
{
    weapon = getWeapon( weapon );
    if( zm_utility::is_offhand_weapon(weapon) || isDefined( type ) )
    {
        bulletDirection = vectorNormalize(anglesToForward(self getPlayerAngles()));
        velocity = VectorScale(bulletDirection, 2500);
        self MagicGrenadeType(weapon, self getEye(), velocity, 2);
    }
    else 
    {
        MagicBullet(weapon, self GetWeaponMuzzlePoint(), self lookPos(), self);
    }
}

mystery_box_pap()
{
    if( !IsDefined(level.mystery_box_pap) )
        level.mystery_box_pap = true;
    else 
        level.mystery_box_pap = undefined;
}

edit_box_weapons( weapon )
{
    if( isInArray( level.box_weapons, weapon ) )
        level.box_weapons = removeFromArray( level.box_weapons, weapon );
    else level.box_weapons[ level.box_weapons.size ] = weapon;

    if( level.box_weapons.size > 0 )
        level.CustomRandomWeaponWeights = ::boxWeapons;
    else level.CustomRandomWeaponWeights = undefined;
}

boxWeapons( keys )
{
    weapons = [];
    foreach( weapon in level.box_weapons )
    {
        weapon = getWeapon( weapon );
        if( IsDefined( level.mystery_box_pap ) && zm_weapons::can_upgrade_weapon( weapon ))
            weapons[ weapons.size ] = zm_weapons::get_upgrade_weapon( weapon, 1 );
        else 
            weapons[ weapons.size ] = weapon;
    }
    return array::randomize( weapons );
}