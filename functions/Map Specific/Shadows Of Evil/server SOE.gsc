EE_Complete_Effects(var_9392be35)
{
    var_e0e332eb = GetEnt("mdl_god_far", "targetname");
    var_bd7c800e = GetEnt("mdl_god_near", "targetname");
    if(var_9392be35 || var_9392be35 == "Enable")
    {
        level thread LUI::screen_flash(0.2, 0.5, 1, 1, "white");
        level thread util::set_lighting_state(3);
        var_e0e332eb show();
        var_e0e332eb clientfield::set("far_apothigod_active", 1);
        level clientfield::set("rain_state", 1);
    }
    else
    {
        level thread util::set_lighting_state(0);
        var_e0e332eb Hide();
        var_e0e332eb clientfield::set("near_apothigod_active", 0);
        level clientfield::set("rain_state", 0);
    }
}

grab_fumigator()
{
    if( self.var_abe77dc0 )
        return;
    self clientfield::set_to_player("pod_sprayer_held", 1);
    self.var_abe77dc0 = 1;
    level flag::set("any_player_has_pod_sprayer");
    self thread shadowsuishow("zmInventory.widget_sprayer");
}

grab_quest_key()
{      
    if( !level.var_c913a45f && isDefined(level.var_c913a45f) )
        return;
    if(!isDefined(level.var_c913a45f))
        self open_smashable( "unlock_quest_key" );
    self activate_trigger( "quest_key_pickup" );
}

complete_all_rituals()
{
    str_names = ["boxer", "detective", "femme", "magician", "pap"];
    foreach( str in str_names )
    {
        if( str == "pap" )
            wait 3;
        self complete_ritual( str, true );
    }
    level.var_522a1f61 = 1; 
}

complete_ritual( name, skip )
{
    name = toLower( name );
    if( level flag::get("ritual_" + name + "_complete") )
        return;
    if( name == "pap" && !isDefined( skip ) )
    {
        self thread complete_all_rituals();
        return;
    }

    self grab_quest_key();
    self grab_ritual_part( name );
    wait .1;
    self do_ritual( name );
}

do_ritual( str_name )
{   
    if( str_name != "pap" )
    {
        foreach(item in level.a_uts_craftables)
        {
            if( item.equipname == "ritual_" + str_name )
            {
                item [[ item.craftableStub.onFullyCrafted ]]( self );
                thread zm_unitrigger::unregister_unitrigger( item );
                break;
            }
        }
    }
    else 
    {
        for(e=1;e<5;e++)
        {
            self activate_trigger(level.var_f86952c7["pap_basin_" + e]);
            wait .1;
        }
    }
    wait .1;

    trigStub = level.var_c0091dc4[ str_name ].var_28f7dec3.var_501122d5;
    trigStub.var_28f7dec3 notify( "trigger", self );
    wait .1;
    trigStub.var_b46f18d4 = 100;
    trigStub.var_3218a534 = 5;
    if( str_name == "pap" )
        return;
    level flag::wait_till("ritual_" + str_name + "_complete");
    wait(getanimlength("p7_fxanim_zm_zod_redemption_key_ritual_end_anim") + .1);
    self grab_part("relic_" + str_name);
}

shock_all_electrics()
{
    level.all_electrics_open = true;
    for(e=0;e<50;e++)
    {
        if( isDefined( level flag::get("power_on"+e) ))
           level flag::set("power_on"+e);
    }
}

open_all_smashables()
{
    self thread open_smashable();
}

open_smashable( type )
{
    level.all_smashables_open = true;
    ent_array = GetEntArray("beast_melee_only", "script_noteworthy");
    n_id = 0;
    foreach(e_clip in ent_array)
    {
        str_id = "smash_unnamed_" + n_id;
        if(isdefined(e_clip.targetname))
            str_id = e_clip.targetname;
        else
        {
            e_clip.targetname = str_id;
            n_id++;
        }
        if( isDefined( type ) && !isSubStr(str_id, type) )
            continue;
        e_clip UseBy( self );
    }
}

grab_ritual_part( part )
{
    if(level flag::get("memento_" + part + "_found"))
        return;

    if(!level flag::get("power_on" + 23) && part == "detective")
        level flag::set("power_on" + 23);
    if(!level flag::get("power_on" + 20) && part == "magician")
        level flag::set("power_on" + 20);   

    self open_smashable( part );
    self grab_part( "memento_" + part );
}
