godmode()
{
    if(!isDefined( self.godmode ))
    {
        self.godmode = true;
        self.demiGodmode = undefined;  
        self EnableInvulnerability();
    }
    else
    {
        self.godmode = undefined;
        self DisableInvulnerability();
    }
}

demiGodmode()
{
    if(!isDefined( self.demiGodmode ))
    {
        self.demiGodmode = true;
        self.godmode     = undefined;
    }
    else 
        self.demiGodmode = undefined;    
}

noClipExt()
{
    self endon("disconnect");
    self endon("game_ended");
    
    if(!isDefined( self.noclipBind ))
    {
        self.noclipBind = true;
        while(isDefined( self.noclipBind ))
        {
            if(self fragButtonPressed())
            {
                if(!isDefined(self.noclipExt))
                    self thread doNoClipExt();
            }
            wait .05;
        }
    }
    else 
        self.noclipBind = undefined;
}

doNoClipExt()
{
    self endon("disconnect");
    self endon("noclip_end");
    self disableWeapons();
    self disableOffHandWeapons();
    self.noclipExt = true;

    clip = spawn("script_origin", self.origin);
    self playerLinkTo(clip);
    self EnableInvulnerability();

    while(true)
    {
        vec = anglesToForward( self getPlayerAngles() ); 
        end = (vec[0]*60, vec[1]*60, vec[2]*60);
        if(self attackButtonPressed()) 
            clip.origin = clip.origin + end;
        if(self adsButtonPressed()) 
            clip.origin = clip.origin - end;
        if(self meleeButtonPressed()) 
            break;
        wait .05;
    }

    clip delete();
    self enableWeapons();
    self enableOffHandWeapons();

    if(!isDefined( self.godmode ))
        self DisableInvulnerability();
    
    self.noclipExt = undefined;
}

ufoMode()
{
    if(isDefined(self.noclipBind)) return self iprintlnBold("^1Error^7: Please turn off noclip before using UFO Mode.");
    
    if( self hasMenu() ) self thread refreshMenu();  

    self enableInvulnerability();
    self disableWeapons();
    self disableOffHandWeapons();
    clip = modelSpawner( self.origin, "script_origin" );
    self playerLinkTo(clip);
    while(1)
    {
        vec = anglesToForward(self getPlayerAngles());
        vecU = anglesToUp(self getPlayerAngles());
        end = (vec[0]*35,vec[1]*35,vec[2]*35);
        endU = (vecU[0]*30,vecU[1]*30,vecU[2]*30);
        if(self attackButtonPressed())  clip.origin = clip.origin - endU;
        if(self adsButtonPressed())     clip.origin = clip.origin + endU;
        if(self fragButtonPressed())    clip.origin = clip.origin + end;
        if(self meleeButtonPressed())   break;
        wait .05;
    }
    clip delete();
    self enableWeapons();
    self enableOffHandWeapons();
    if(!isDefined(self.godmode))
        self DisableInvulnerability();
    self notify( "reopen_menu" );
}

thirdPerson()
{
    if(!isDefined(self.thirdPerson))
        self.thirdPerson = true;
    else self.thirdPerson = undefined;
    self setclientthirdperson( returnBoolean(self.thirdPerson) );
}

invisibility()
{
    if( !IsDefined( self.invisibility ) )
    {
        self.invisibility = true;
        self hide();
    }
    else 
    {
        self.invisibility = undefined;
        self show();
    }
}

infiniteAmmo( reload )
{
    self endon("disconnect");

    if( !isDefined( self.infAmmo ) )
    {
        self.infAmmo = true;
        while( isDefined( self.infAmmo ) )
        {
            weapons = self GetWeaponsList();
            foreach( weapon in weapons )
            {
                if( weapon.isgadget )
                {
                    slot = self GadgetGetSlot( weapon );
                    if( self GadgetPowerGet( slot ) < 100 && !self GetCurrentWeapon().isgadget || self GadgetPowerGet( slot ) < 10 ) 
                        self GadgetPowerSet( slot, 100 );
                }
                
                if( weapon != "none" && tolower( reload ) == "reload" ) 
                    self givemaxammo( weapon );
                else if( toLower( reload ) != "reload" ) 
                    self setWeaponAmmoClip( weapon, weapon.clipsize );
            }
            wait .1;
        }
    }
    else self.infAmmo = undefined;
}

infiniteEquip()
{
    self endon("disconnect");

    if( !isDefined( self.infEquip ) )
    {
        self.infEquip = true;
        while( isDefined( self.infEquip ) )
        {
            if( self getcurrentoffhand() != "none" ) 
                self givemaxammo( self getcurrentoffhand() );
            wait .05;
        }
    }
    else self.infEquip = undefined;
}

setAllPerks( clear = self hasAllPerks() )
{
    a_str_perks = getArrayKeys(level._custom_perks);
    if(clear)
    {
        for(i = 0; i < a_str_perks.size; i++)
            if(self hasPerk(a_str_perks[i]))
                self removePerk(a_str_perks[i]);
    }
    else
    {
        for(i = 0; i < a_str_perks.size; i++)
            if(!self hasPerk(a_str_perks[i]))
                self zm_perks::give_perk(a_str_perks[i], 0);
    }
}

_setPerkFunction( perkName )
{
    if(!self hasperk( perkName ))
    {
        self setPerk( perkName ); 
        self zm_perks::vending_trigger_post_think( self, perkName );  
    }
    else 
        self removePerk( perkName );    
}

removePerk( perk )
{
    self notify(perk + "_stop"); 
}

hasAllPerks()
{
    for(e=0;e<getPerks().size;e++)
    {
        perk_id = getPerks()[e];
        if(!self hasPerk( perk_id ))
            return false;
    }
    return true;
}

changeAppearance( index, fx )
{   
    if( isdefined( fx ) )
    {
        playFX(level._effect["human_disappears"], self.origin);
        playsoundatposition("zmb_player_disapparate", self.origin);
        self playlocalsound("zmb_player_disapparate_2d");
    }

    self.characterIndex = int( index );
    self SetCharacterBodyType( int( index ) );
    self SetCharacterBodyStyle( 0 );
    self SetCharacterHelmetStyle( 0 );
}

cycleAppearance()
{
    if(!IsDefined( self.cycleAppearance ))
    {
        self.cycleAppearance = true;
        self thread doCycleAppearance();
    }
    else 
    {
        self.cycleAppearance = undefined;
        self notify("stop_cycleAppearance");
    }
}

doCycleAppearance()
{
    self endon("disconnect");
    self endon("stop_cycleAppearance");

    while(IsDefined( self.cycleAppearance ))
    {
        for(e=0;e<8;e++)
        {
            self changeAppearance( e );
            wait .4;
        }
        wait .05;
    }
}

clone( which )
{
    if(isDefined(self.invisibility))
        return self iprintln("^1Error^7: Disable Invisibility before using spawn clone.");
    if( which == "Clone" || which == "Dead" )
        clone = self clonePlayer( 1, self getcurrentweapon() );
    if( which == "Dead" )
        clone startRagdoll( 1 );
    if( which == "Statue" )
    {
        model = self GetCharacterBodyModel();
        clone = modelSpawner(self.origin, model, self.angles);
        bodyRenderOptions = self GetCharacterBodyRenderOptions();
        clone SetBodyRenderOptions(bodyRenderOptions, bodyRenderOptions, bodyRenderOptions);
    }
    wait 5;
    clone delete();
}

set_movement_speed( val )
{
    self.movement_speed = true;
    if( val == 1 )
        self.movement_speed = undefined;
    self setmovespeedscale( val );
}

music_player( track )
{
    if(isdefined(self.music_player))
    {
        self.music_player stopsounds();
        wait .1;
        self.music_player delete();
    }
    self.music_player = modelspawner( self.origin, "tag_origin" );
    self.music_player playsoundtoplayer( track, self );
}

respawn_player()
{
    if( IsDefined( self.reviveTrigger ) )
        return self zm_laststand::auto_revive( self );
    if(_isAlive( self ))
        return;
    self [[level.spawnPlayer]]();
    self FreezeControls( false );
}

editPoints( value, minus = false )
{
    if( value >= 0 && !minus )
        self zm_score::add_to_player_score( value );
    else
        self zm_score::minus_to_player_score( value );
}

commitSuicide( skip = false )
{
    if( !skip ) if( !self areYouSure() )
        return;
    self.maxhealth = 100;
    self.health = self.maxhealth;
    self.demiGodmode = undefined;
    self disableInvulnerability();
    self dodamage(self.health + 10000, self.origin);
    self.bleedout_time = 0;
}

give_gobble_gum( gum_id )
{
    saved = self GetCurrentWeapon();
    weapon = GetWeapon("zombie_bgb_grab");
    self GiveWeapon(weapon, self CalcWeaponOptions(level.bgb[gum_id].camo_index, 0, 0));
    self SwitchToWeapon(weapon);
    self playsound("zmb_bgb_powerup_default");
  
    evt = self util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");
    if(evt == "weapon_change_complete")
    {
        self takeWeapon( weapon );
        self zm_weapons::switch_back_primary_weapon(saved);
        bgb::give( gum_id );
    }
}

do_health_info()
{
    if(!isdefined(self.health_bar))
    {
        self.health_bar = true;
        self thread gameskill::playerHurtcheck();
        self iPrintLnBold("Notice: Health Bar will show when the menu is closed.");
    }
    else 
    {
        self.health_bar = undefined;
        self notify("killHurtCheck");
    }
}

draw_health_info()
{
    self.health_info = [];
    self.healthBarHudElems = [];
    
    self.health_info[0] = "Health:";
    self.health_info[1] = "No Hit Time:";

    if(!isdefined(level.playerInvulTimeEnd))
        level.playerInvulTimeEnd = 0;
    if(!isdefined(level.player_deathInvulnerableTimeout))
        level.player_deathInvulnerableTimeout = 0;

    y = 41;
    for(e=0;e<self.health_info.size;e++)
    {
        textelem = self createText("objective", 1.1, "LEFT", "TOPLEFT", 40, y, 3, 1, self.health_info[e], (1,1,1));
        bgbar    = self createRectangle("LEFT", "TOPLEFT", 85, y, 200, 10, (0,0,0), "white", 1, 1);
        bar      = self createRectangle("LEFT", "TOPLEFT", 86, y, 1, 8, "rainbow", "white", 2, 1);

        bgbar.maxwidth = 1;
        textelem.bar   = bar;
        textelem.bgbar = bgbar;

        y = y + 10;
        self.healthBarHudElems[e] = textelem;
    }
    
    wait .1; 
    self thread update_health_info();
}

update_health_info()
{
    self endon("disconnect");
    self endon("end_health_bar");
    
    while(1)
    {
        for(e=0;e<self.health_info.size;e++)
        {
            width = 0;
            if(e == 0)
            {
                width = self.health / self.maxhealth * 200;
                self.healthBarHudElems[e] setText(self.health_info[0] + " " + self.health);
            }
            else if(e == 1)
            {
                width = ((level.playerInvulTimeEnd - GetTime()) / 1000) * 40;
            }
            
            width = Int(max(width, 1));
            width = Int(min(width, 200));

            bar = self.healthBarHudElems[e].bar;
            bar SetShader("white", width, 8);
            bgbar = self.healthBarHudElems[e].bgbar;

            if( width + 2 > bgbar.maxwidth)
            {
                bgbar.maxwidth = width + 2;
                bgbar SetShader("black", bgbar.maxwidth, 10);
            }
        }
        wait .05;
    }
}

destroy_health_info()
{
    self notify("end_health_bar");
    if(!isDefined(self.healthBarHudElems))
        return;
    for(i=0;i<self.health_info.size;i++)
    {
        self.healthBarHudElems[i].bgbar destroy();
        self.healthBarHudElems[i].bar destroy();
        self.healthBarHudElems[i] destroy();
    }
    self.healthBarHudElems = [];
}

no_explosive_damage()
{
    if(!isDefined( self.noExplosiveDamage ))
        self.noExplosiveDamage = true;
    else 
        self.noExplosiveDamage = undefined;    
}

auto_revive()
{ 
    if( !isDefined( self.auto_revive ) )
    {
        self endon("end_autorevive");
        self endon("disconnect");
        self.auto_revive = true;
        
        if( IsDefined( self.reviveTrigger ) )
            self zm_laststand::auto_revive( self );
        while( isDefined( self.auto_revive ) )
        {
            self waittill( "player_downed" );
            self zm_laststand::auto_revive( self );
        }
    }
    else 
    {
        self.auto_revive = undefined;
        self notify("end_autorevive");
    }
}

set_vision( type, vision )
{
    self notify("vision_changed");
    if( self.current_vision == vision )
    {
        self.current_vision = "none";
        return;
    }
    self.current_vision = vision;
        
    waittillframeend;
    visionset_mgr::activate_per_player( type, vision, self, 1.25 );
    self waittill("vision_changed");
    visionset_mgr::deactivate_per_player( type, vision, self );
}

money_drop()
{
    if(!IsDefined( self.money_drop ))
    {
        self.money_drop = true;
        self thread do_money_drop();
    }
    else 
        self.money_drop = undefined;
}

do_money_drop()
{
    level endon("game_ended");
    self endon("death");
    self endon("disconnect");
    
    while( IsDefined(self.money_drop) )
    {
        colour = pow(2, randomint(3));
        money  = modelSpawner( self GetTagOrigin("j_head") + (0,0,50), "zombie_z_money_icon" );
        money clientfield::set( "powerup_fx", int(colour) );
        money PhysicsLaunch( money.origin, (RandomIntRange(-5, 5), RandomIntRange(-5, 5), RandomIntRange(-5, 5)) );
        wait .2;
        money thread monitor_money_drop( 3 );
    }
}

monitor_money_drop( time )
{
    timeout = 0;
    while( IsDefined( self ) )
    {
        timeout++;
        foreach( player in level.players )
        {
            if( self IsTouchingVolume( player.origin - (0,0,40), player GetMins(), player GetMaxs() ) )
            {
                player zm_score::add_to_player_score( 500 );
                playsoundatposition( "zmb_cha_ching", self.origin );
                break 2;
            }
        }
        if(timeout > 30)
            break;
            
        self PhysicsLaunch( self.origin, (0, 0, RandomIntRange(4, 10)) );
        wait .1;
    }
    self delete();
}

money_gun()
{
    if(!IsDefined( self.money_gun ))
    {
        self.money_gun = true;
        self thread do_money_gun();
    }
    else 
    {
        self.money_gun = undefined;
        self notify("end_money_gun");
    }
}

do_money_gun()
{
    level endon("game_ended");
    self endon("death");
    self endon("disconnect");
    self endon("end_money_gun");
    
    while( true )
    {
        self waittill("weapon_fired");
        colour = pow(2, randomint(3));
        money = modelSpawner( self GetWeaponMuzzlePoint(), "zombie_z_money_icon" );
        money clientfield::set( "powerup_fx", int(colour) );
        money PhysicsLaunch( money.origin, AnglesToForward( self GetPlayerAngles() ) * 100 );
        wait .2;
        money thread monitor_money_drop( 3 );
    }
}