//GUNGAME 
initialize_gungame()
{
    level.gungame_active = true;
    level randomize_weapon_array();

    foreach(player in level.players)
        player player_initialize_gungame();
}

player_initialize_gungame()
{
    self takeAllWeapons();
    self thread giveWeap( level.gungame_weapons[ 0 ], true );
    self thread monitor_weapon_kills();
}

randomize_weapon_array()
{
    weapons_array = [];
    level.gungame_weapons = [];
    
    for(e=0;e<level.weapons.size-1;e++)
    {
        foreach(weapon in level.weapons[e])
        {
            if(randomInt(100) > 75)
                weapons_array[weapons_array.size] = zm_weapons::get_upgrade_weapon(GetWeapon(weapon.id), 1);
            else 
                weapons_array[weapons_array.size] = weapon.id;
        }
    }
    level.gungame_weapons = Array::Randomize( weapons_array );
}

monitor_weapon_kills()
{
    self endon("death");
    self endon("disconnect");
    level endon("game_ended");

    self.gungame_promotion = 0;
    self.gungame_kills = 0;

    current_promotion = self.gungame_promotion;
    while(true)
    {
        if( current_promotion != self.gungame_promotion ) 
        {
            current_promotion = self.gungame_promotion;
            self thread giveWeap( level.gungame_weapons[ current_promotion ], true );
            self.gungame_kills = 0;
        }

        if( self.gungame_kills >= Ceil( (current_promotion + 1) / .4) )
        {
            self.gungame_promotion++;
            self iPrintLnBold("gun promoted: ", self.gungame_promotion);
        }
        wait .1;
    }
}

gungame_damage_monitor()
{
    if(self.gungame_promotion > 0)
        self.gungame_promotion--;

    self.gungame_kills = 0;
    iPrintLnBold("gungame: demoted");
}
