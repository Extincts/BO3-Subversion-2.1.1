modelSpawner( origin, model, angles, time, scale )
{
    if(isDefined(time))
        wait time;
     
    obj = util::spawn_model( model, origin, angles );    
    if(isDefined( scale ))
        obj SetScale( scale );
    return obj;
}

returnBoolean( var )
{
    if(isDefined(var))
        return true;
    return false;
}

removeDuplicates( array )
{
    newArray = [];
    foreach( item in array )
    {
        if( !isInArray(newArray, item) )
            newArray[ newArray.size ] = item;
    }
    return newArray;
}

removeDuplicateEntArray( name ) 
{
    newArray = []; saveArray = [];
    foreach( item in GetEntArray( name, "targetname" ) )
    {
        if( !isInArray(newArray, item.script_noteworthy) )
        {
            newArray[ newArray.size ] = item.script_noteworthy;
            saveArray[ saveArray.size ] = item;
        }
    }
    return saveArray;
}

array_delete( ID )
{   
    foreach( item in ID )
    {
        if(IsDefined( item ))
            item delete();
    }
}

replaceChar( string, substring, replace )
{
    final = "";
    for(e=0;e<string.size;e++)
    {
        if(string[e] == substring)
            final += replace;
        else 
            final += string[e];
    }
    return final;
}

constructString( string ) 
{
    final = "";
    for(e=0;e<string.size;e++)
    {
        if(e == 0)
            final += toUpper(string[e]);
        else if(string[e-1] == " ")
            final += toUpper(string[e]);
        else 
            final += string[e];
    }
    return final;
}

cutName( fxName )
{
    result = "";
    for(e=0;e<fxName.size;e++)
    {
        if( e > 17 )
            return result;
        result += fxName[e];
    }
    return result;
} 

vectorScale(vec, scale)
{
    return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}

removeDuplicatedModels( array )
{
    newArray = [];
    foreach( item in array )
    {
        if( !isInArray(newArray, item.model) && item.model != "" )
            newArray[ newArray.size ] = item.model;
    }
    return newArray;
}

returnList( min, max, inc )
{   
    list = "";
    for(e=min;e<max;e+=inc)
    {
        if( e == max )
            list += e;
        else
            list += e + ";";
    }
    return list;
}

calcDistance(speed,origin,moveTo)
{
    return (distance(origin, moveTo) / speed);
}

delayedFall( val )
{
    if(isDefined(self)) 
        self PhysicsLaunch( self.origin, self.origin );
    wait val;
    if(isDefined(self)) 
        self delete();
}

getRandomThrowSpeed() 
{
    yaw = randomFloat( 360 );
    pitch = randomFloatRange( 65, 85 );
    amntz = sin( pitch );
    cospitch = cos( pitch );
    amntx = cos( yaw ) * cospitch;
    amnty = sin( yaw ) * cospitch;
    speed = randomFloatRange( 400, 600);
    velocity = (amntx, amnty, amntz) * speed;
    return velocity;
}

lookPos( dist = 99999, type = "position") 
{ 
    angles = anglesToForward( self getPlayerAngles() );
    return bullettrace( self getEye(), self getEye() + vectorScale(angles, dist), false, self )[ type ]; 
} 

shadowsuishow( val, time = 3.5 )
{
    self clientfield::set_player_uimodel(val, 1);
    wait time;
    self clientfield::set_player_uimodel(val, 0);
}

show_infotext_for_duration(str_infotext, n_duration)
{
    self clientfield::set_to_player(str_infotext, 1);
    wait(n_duration);
    self clientfield::set_to_player(str_infotext, 0);
}

getPlayerFromName( name )
{
    foreach( player in level.players )
        if( name == player.name )
            return player;
}

getMapName()
{
    id = ["zm_zod", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_factory", "zm_tomb", "zm_theater", "zm_prototype", "zm_asylum", "zm_moon", "zm_sumpf", "zm_cosmodrome", "zm_temple"];
    rl = ["Shadows Of Evil", "Der Eisendrache", "Zetsubou No Shima", "Gorod Krovi", "Revelations", "The Giant", "Origins", "Kino Der Toten", "Nacht Der Untoten", "Verruckt", "Moon", "Shi No Numa", "Ascension", "Shangri-La"];
    for(e=0;e<id.size;e++)
    {
        if( id[e] == GetDvarString("mapname") )
            return rl[e];
    }
    return GetDvarString("mapname");
}

moon_doors_supported()
{
    array = ["zm_sumpf", "zm_asylum", "zm_factory", "zm_theater", "zm_cosmodrome"];
    if( isInArray(array, GetDvarString("mapname")) )
        return true;
    return false;    
}

getTarget( current, mostRecent ) 
{ 
    if(!self can_hit_enemy( current ) )
        return undefined;
    if(!isDefined(mostRecent))
        return current;
    if(closer(self getTagOrigin("j_head"), current getTagOrigin("j_head"), mostRecent getTagOrigin("j_head"))) 
        return current;
    return mostRecent;
} 

angleNormalize360(angle)
{
    v3     = floor((angle * 0.0027777778));
    result = ((angle * 0.0027777778) - v3) * 360.0;
    if ( (result - 360.0) < 0.0 )
        v2 = ((angle * 0.0027777778) - v3) * 360.0;
    else
        v2 = result - 360.0;
    return v2;
}

angleNormalize180(angle)
{
    angle = angleNormalize360(angle);
    if(angle > 180)
        angle -= 360; 
    return angle;
}

getMiscWeapons()
{
    level.weapons[7] = [];
    //blacklist = ["Ull's Arrow", "Kimat's Bite", "Kagutsuchi's Blood", "Boreas' Fury"];
    foreach( weapon in getArrayKeys(level.zombie_weapons) )
    {
        isInArray = false;
        for(e=0;e<level.weapons.size;e++)
        {
            for(i=0;i<level.weapons[e].size;i++)
            {
                if( isDefined(level.weapons[e][i]) && level.weapons[e][i].id == weapon.name )
                {
                    isInArray = true;
                    break 2;
                }
            }
        } 
        if( !isInArray && weapon.displayname != "" ) // && !isInArray( blacklist, MakeLocalizedString( weapon.displayname ) ) )
        {
            weapons = spawnStruct();
            weapons.name = MakeLocalizedString( weapon.displayname );
            weapons.id = weapon.name;
            level.weapons[7][level.weapons[7].size] = weapons;
        }
    }
}

returnClosestPlayer()
{
    foreach(player in level.players)
    { 
        if(Closer( self getTagOrigin("j_head"), player getTagOrigin("j_head"), final getTagOrigin("j_head") ) && player != self)
            final = player;
    }
    return final;
}

getPerks()
{
    return getArrayKeys(level._custom_perks);
}

getPerkName( perk, alt )
{
    perkID = ["fastreload", "quickrevive", "armorvest", "additionalprimaryweapon", "doubletap2", "widowswine", "staminup", "deadshot"];
    perkName = ["Speed Cola", "Quick Revive", "Jugger-Nog", "Mule Kick", "Double Tap Root Beer", "Widow's Wine", "Stamin-Up", "Deadshot Daiquiri"];
    for(e=0;e<perkID.size;e++)
    {
        if( !isDefined( alt ) && perk == "specialty_" + perkID[e] || isDefined( alt ) && isSubStr( toLower( perkName[e] ), perk ))
            return perkName[e];
    }
    return perk;
}

_isAlive( player )
{
    if( player.sessionstate == "playing" )
        return true;
    return false;    
}

moveToOriginOverTime(origin, time, who, vec = (0,0,0), tag)
{
	self endon("killanimscript");
    self endon("death");
	
	offset = self.origin - origin;
	frames = Int(time * 20);
	offsetreduction = VectorScale(offset, 1 / frames);
    
	for(i = 0; i < frames; i++)
	{
		offset = offset - offsetreduction;

        if( isDefined(tag) )
            self.origin = (who getTagOrigin( tag ) + vec) + offset;
        else if( isDefined( who ) )
            self.origin = (who.origin + vec) + offset;
        else 
		    self.origin = (origin + offset);
		wait .05;
	}
}

get_teleport_points()
{
    p_points = struct::get_array("player_respawn_point", "targetname");
    a_points = struct::get_array("player_respawn_point_arena", "targetname");
    respawn_points = ArrayCombine(p_points, a_points, false, false);
    
    point_array    = [];
    foreach(point in respawn_points)
        point_array[point_array.size] = point;

    if(point_array.size <= 0)
        return array("No Points Found.");

    teleport_points = [];
    foreach( spawn in point_array )
    {
        target_array = struct::get_array(spawn.target, "targetname");
        //foreach( target in target_array )
            teleport_points[ teleport_points.size ] = target_array[0];
    }
    return teleport_points;
}

getGroundPoint(position)
{
    trace = bullettrace(position + VectorScale((0, 0, 1), 10), position - VectorScale((0, 0, 1), 1000), 0, undefined);
    return trace["position"];
}

activate_trigger( ent )
{
    if( isString( ent ) )
        ent = GetEnt(ent, "targetname").unitrigger_stub;
    if( !isDefined( ent ) )
        return;
    for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
    {
        triggerStub = level._unitriggers.trigger_stubs[i];
        if( triggerStub != ent )
            continue;    

        trigger = zm_unitrigger::check_and_build_trigger_from_unitrigger_stub(triggerStub, self);            
        trigger.origin = self.origin;
        wait .1;
        trigger notify("trigger", self);
    }
}

activate_from_targetname( target )
{
    for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
    {
        trigger = level._unitriggers.trigger_stubs[i];
        if( trigger.targetname == target )
        {
            trigger.origin = self.origin;
            wait .1;
            trigger notify("trigger", self);
            break;
        }
    }
}

get_array_spots(sName, spots)
{
    for(i = 0; i < 4; i++)
    {
        spots[i] = GetEnt(sName + i, "targetname");
    }
    return spots;
}

match_slope(var_a84e1ffa)
{
    groundnormal = calc_slope(var_a84e1ffa, 0);
    if(!isdefined(groundnormal))
        return;
    
    fwd        = AnglesToForward(self.angles);
    ovr        = AnglesToRight(self.angles);
    new_angles = VectorToAngles(groundnormal);
    pitch      = nAngleClamp180(new_angles[0] + 90);
    new_angles = (0, new_angles[1], 0);
    nFwd       = AnglesToForward(new_angles);
    mod        = VectorDot(nFwd, ovr);

    mod = (mod < 0) ? -1 : 1;
    dot = VectorDot(nFwd, fwd);
    var_4ef8701 = dot * pitch;
    var_676ea8f0 = 1 - Abs(dot) * pitch * mod;
    var_676ea8f0 = 0;
    self.angles = (var_4ef8701, self.angles[1], var_676ea8f0);
}

calc_slope(var_a84e1ffa, debug)
{
    ignore = !isDefined(var_a84e1ffa) ? self : var_a84e1ffa;
    var_4f9e9c19 = Array(self.origin); 
    var_d54ec402 = (0, 0, 0);
    trace_count  = 0; 

    foreach(point in var_4f9e9c19)
    {
        trace = bullettrace(point + VectorScale((0, 0, 1), 4), point + VectorScale((0, 0, -1), 16), 0, ignore);
        if( trace["fraction"] > 0 && trace["fraction"] < 1 )
        {
            var_d54ec402 = var_d54ec402 + trace["normal"];
            trace_count++;
        }
    }
    if(trace_count > 0)
        return var_d54ec402 / trace_count;
    return undefined;
}
    
delete_if_disconnect( player )
{
    self endon("death");
    player waittill("disconnect");
    self delete();
}

nAngleClamp180( angle )
{
    v1 = floor( angle / 360 );
    newAngle = ( (angle / 360) - v1 ) * 360;
    return ( (newAngle <= 180) ? newAngle : (360 - newAngle) );
}

getTraceOrigin()
{
    start = self.origin;
    end = start + VectorScale((0, 0, -1), 2000);
    return playerphysicstrace(start, end);
}

setup_gameobject( v_pos, STR_MODEL, STR_USE_HINT, e_los_ignore_me, n_radius = 48 )
{
    // Setup a USE Trigger
    e_trigger = spawn( "trigger_radius_use", v_pos, 0, n_radius, 30 );
    e_trigger TriggerIgnoreTeam();
    e_trigger SetVisibleToAll();
    e_trigger SetTeamForTrigger( "none" );
    e_trigger UseTriggerRequireLookAt();
    e_trigger SetCursorHint( "HINT_NOICON" );
    
    // You can add multiple models into the gameobjects model array, each with their own relative offset
    gobj_model_offset = (0, 0, 0);
    if(isdefined(STR_MODEL))
    {
        gobj_visuals[0] = spawn("script_model", v_pos + gobj_model_offset);
        gobj_visuals[0] SetModel(STR_MODEL);
    }
    else
        gobj_visuals = [];
        
    // This is the LUA objective name, defined in the gametype LUA script
    // CP currently only uses coop
    // It defines the look and style of the LUA icons
    //gobj_objective_name = &"bomb";
    gobj_objective_name = undefined;

    // Create the gameobject
    gobj_team           = "allies";
    gobj_trigger        = e_trigger;
    gobj_offset         = VectorScale((0, 0, -1), 5);
    e_object            = gameobjects::create_use_object( gobj_team, gobj_trigger, gobj_visuals, gobj_offset, gobj_objective_name );
    
    // Setup gameobject params
    e_object gameobjects::allow_use( "any" );
    e_object gameobjects::set_use_time( 0 );
    e_object gameobjects::set_use_text( "" );
    e_object gameobjects::set_use_hint_text( STR_USE_HINT );
    e_object gameobjects::set_visible_team( "any" );
    
    // OLD STYLE OBJECTIVES
    e_object gameobjects::set_3d_icon( "friendly", "T7_hud_prompt_press_64" );
    e_object gameobjects::set_3d_icon( "enemy", "T7_hud_prompt_press_64" );
    e_object gameobjects::set_2d_icon( "friendly", "T7_hud_prompt_press_64" );
    e_object gameobjects::set_2d_icon( "enemy", "T7_hud_prompt_press_64" );
        
    e_object thread gameobjects::hide_icon_distance_and_los((1, 1, 1), 840, 1, e_los_ignore_me);
    return e_object;
}

GetGroundPosition( origin, radius )
{
    return bulletTrace(origin, origin - (0,0,9999), false, self)["position"];
}

arySetUnUsable( array, exclude )
{
    foreach( trigger in array )
    {
        foreach( player in level.players )
        {
            if( trigger != self && player == exclude && !isDefined( trigger.in_use ) )
                trigger SetInvisibleToPlayer( player );
            else if( trigger == self && player != exclude && isDefined( trigger.in_use ) )
                trigger SetInvisibleToPlayer( player );
        }
    }
}

arySetUsable( array )
{
    foreach( player in level.players )
    {
        foreach( trigger in array )
        {
            if( !isDefined( trigger.in_use ) )
                trigger SetVisibleToPlayer( player );
        }
    }
}

stringToFloat( stringVal )
{
    floatElements = strtok( stringVal, "." );
    
    floatVal = int( floatElements[0] );
    if ( isDefined( floatElements[1] ) )
    {
        modifier = 1;
        for ( i = 0; i < floatElements[1].size; i++ )
            modifier *= 0.1;
        
        floatVal += int ( floatElements[1] ) * modifier;
    }
    return floatVal;    
}