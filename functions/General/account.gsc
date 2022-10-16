_setPlayerData( statValue, statString )
{
    if( !self areYouSure() )
        return;

    self SetDStat( "playerstatslist", statString, "StatValue", statValue );
    self setRank( self rank::getRankForXp( self rank::getRankXP() ), self GetDStat("playerstatslist", "PLEVEL", "StatValue") );
    wait .1;
    UploadStats(self);
}

addPlayerXP( value )
{
    if( !self areYouSure() )
        return;
    if( value > 35 )
    {
        xpTable = int(tableLookup( "gamedata/tables/zm/zm_paragonranktable.csv", 0, value - 36, ((value == 100) ? 7 : 2) ));
        old = int(self GetDStat("playerstatslist", "paragon_rankxp", "statValue"));
    }
    else 
    {
        xpTable = int(tableLookup( "gamedata/tables/zm/zm_ranktable.csv", 0, value - 1, ((value == 35) ? 7 : 2) ));
        old = int(self GetDStat("playerstatslist", "rankxp", "statValue"));
    }

    self AddRankXPValue("win", xpTable - old);
    wait .1;
    UploadStats(self);
    self refreshMenuToggles();
}

getCurrentRank()
{
    if(self.pers["plevel"] > 10 && self GetDStat("playerstatslist", "paragon_rank", "StatValue") >= 1)
        return self GetDStat("playerstatslist", "paragon_rank", "StatValue") + 36;
    return self GetDStat("playerstatslist", "rank", "StatValue") + 1;    
}

do_all_challenges()
{
    if( !self areYouSure() )
        return;
    self thread progressbar( 0, 100, 1, .125 ); 

    for(value=512;value<642;value++)
    {
        stat         = spawnStruct();
        stat.value   = int( tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 2 ) );
        stat.type    = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 3 );
        stat.name    = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 4 );
        stat.split   = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 13 );

        switch( stat.type )
        {
            case "global":
                self setDStat("playerstatslist", stat.name, "statValue", stat.value);
                self setDStat("playerstatslist", stat.name, "challengevalue", stat.value);
            break;

            case "attachment":
                foreach( attachment in strTok(stat.split, " ") )
                {
                    self SetDStat("attachments", attachment, "stats", stat.name, "statValue", stat.value);
                    self SetDStat("attachments", attachment, "stats", stat.name, "challengeValue", stat.value);
                    for(i = 1; i < 8; i++)
                    {
                        self SetDStat("attachments", attachment, "stats", "challenge" + i, "statValue", stat.value);
                        self SetDStat("attachments", attachment, "stats", "challenge" + i, "challengeValue", stat.value);
                    }
                }
            break;

            default:
                foreach( weapon in strTok(stat.split, " ") )         
                    self addWeaponStat( GetWeapon( weapon ), stat.name, stat.value ); 
            break;
        }
        wait .1;
    }
    self waittill("progress_done");
    self max_weapon_level( true );
    self.unlock_all = true;
    self refreshMenuToggles();
    UploadStats(self);
}

giveLiquid( value )
{
    self endon("disconnect");
    if( !self areYouSure() )
        return;

    amount = value / 250;
    multi  = 10 / amount;
    round  = multi + "";
    self thread progressbar( 0, 100, int(round[0]), .1); 

    for(e=0;e<amount;e++)
    {
        for(i=0;i<250;i++)
            self incrementbgbtokensgained();

        self.var_f191a1fc = self.var_f191a1fc + int(value / amount);
        self reportlootreward("3", int(value / amount));
        UploadStats(self); 
        wait 1.1;
    }
}

unlockAchievements()
{
    self endon("disconnect");
    if( !self areYouSure() )
        return;

    self thread progressbar( 0, 100, 1, .1);    
    foreach(achivement in level.achievements)
    {
        self zm_utility::giveachievement_wrapper(achivement);
        wait .1;
    }
    self.unlock_achievements = true;
}

bgb_remove()
{
    if( !self areYouSure() )
        return;
    foreach(bgb in self GetBubbleGumPack())
    {
        level.players[0] iPrintLnBold( bgb, ": ", self GetBGBRemaining(bgb) );
        level flag::set( "consumables_reported" );
        incrementCounter("zm_dash_coop_end_consumables_count", self GetBGBRemaining( bgb ));
        self reportlootconsume( bgb, self GetBGBRemaining( bgb ) );
    }
    self flag::set("finished_reporting_consumables");
}

steal_media_items()
{
    result = "1";
    if( GetDvarString( "fileshareAllowDownloadingOthersFiles" ) == "1" )
        result = "0";
    setDvar("fileshareAllowDownload", result);
    setDvar("fileshareAllowDownloadingOthersFiles", result);
    setDvar("fileshareAllowVariantDownload", result);
    setDvar("fileshareAllowEmblemDownload", result);
    setDvar("enable_camo_materials_tab", result);
}

set_all_EE()
{
    if( !self areYouSure() )
        return;
    strings = ["DARKOPS_GENESIS_SUPER_EE", "darkops_zod_ee", "darkops_factory_ee", "darkops_castle_ee", "darkops_island_ee", "darkops_stalingrad_ee", 
    "darkops_genesis_ee", "darkops_zod_super_ee", "darkops_factory_super_ee", "darkops_castle_super_ee", "darkops_island_super_ee", "darkops_stalingrad_super_ee"];
    
    result = 1;
    if( result == int( self GetDStat("PlayerStatsList", "DARKOPS_GENESIS_SUPER_EE", "StatValue") ))  
        result = 0;
    
    foreach(string in strings)
        self SetDStat("playerstatslist", string, "statValue", result);
    self refreshMenuToggles();
}

max_weapon_level( skip = false )
{
    self endon("disconnect");
    
    if( !skip )
    {
        if( !self areYouSure() )
            return;
    }
    
    if(!isDefined( self.max_weapons ) || skip )
        self.max_weapons = true;
    else 
        self.max_weapons = undefined;
        
    for(e=0;e<level.weapons.size;e++)
    {
        foreach( weapon in level.weapons[e] )
        {
            index = GetBaseWeaponItemIndex( GetWeapon( weapon.id ) );
            self SetDStat( "ItemStats", index, "xp", !isDefined(self.max_weapons) ? 0 : 665535 );
        }
    }
    self refreshMenuToggles();
}

setClantag( string, name = "" )
{
    if(!IsDefined( string ))
    {
        self thread refreshMenu();
        wait .2;
        string = self do_keyboard( "Clantag Editor" );
        wait .2;
        self notify( "reopen_menu" );
    }
    if( string.size == 0 && name != "None" )
        return;
    self setDStat( "clanTagStats", "clanName", string );
    self iPrintLnBold( ((name != "") ? "Name Colour" : "Clantag"), " Set: ", string + name );
}
