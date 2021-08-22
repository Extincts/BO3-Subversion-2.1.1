spawn_Fx(fx, delete)
{
    if(isDefined( fx ))
    {
        if(!IsDefined( level.SpawnedFx )) 
            level.SpawnedFx = [];
        if(!isDefined( self.FxDistance ))
            self fx_distance( 100 );

        if(isDefined( fx ))
        {
            fxOrg = modelSpawner( self getEye() + anglesToForward( self getPlayerAngles() ) * self.FxDistance, "tag_origin" );
            effect = PlayFXOnTag( level._effect[fx], fxOrg, "tag_origin" );
            wait .05;
            triggerFx( effect );
            level.SpawnedFx[level.SpawnedFx.size] = fxOrg;
        }
        if(level.SpawnedFx.size >= 50)
        {
            array_delete( level.SpawnedFx );
            self iprintln("Notice: all fx's deleted due to too many spawned.");
            level.SpawnedFx = [];
        }
    }
    else
    {
        array_delete( level.SpawnedFx );
        self iprintln("All spawned FXs deleted!");
        level.SpawnedFx = [];
    }
}

fx_distance( value )
{
    self.fxDistance = int( value );
    self iprintln( "Distance set to: " + self.FxDistance );
    refreshMenuToggles();
}

spiralStaircase( height )
{
    if(IsDefined( level.spiral ))
        array_delete( level.spiral );
    if( height == 0 ) return;

    org = self.origin;
    level.spiral = [];
    for(e=0;e<int(height);e++)
        level.spiral[level.spiral.size] = modelSpawner(org + (cos(e*30)*30, sin(e*30)*30, e*20), "p7_zm_vending_doubletap2", (-20, (e*30), 90), .05); 
}
   
spawn_mexican_wave( amount )
{
    if(!IsDefined( self.mexican_wave ))
        self.mexican_wave = [];
    else
    { 
        array_delete( self.mexican_wave );
        self.mexican_wave = undefined;
        return;
    }
    
    angle  = self.angles;
    origin = self.origin;    
    
    model = self GetCharacterBodyModel();
    bodyRenderOptions = self GetCharacterBodyRenderOptions();

    for(e=0;e<int(amount);e++)
    {
        self.mexican_wave[e] = modelSpawner( origin + AnglesToRight( angle ) * ((e*36) - ( amount / 2 * 36 )), model, angle, .1 );
        self.mexican_wave[e] SetBodyRenderOptions(bodyRenderOptions, bodyRenderOptions, bodyRenderOptions);
        self.mexican_wave[e] thread move_mexican_wave(); 
    }
}

move_mexican_wave()
{
    while(IsDefined( self ))
    {
        self moveZ(80, 1, .2, .4);
        wait 1;
        self moveZ(-80, 1, .2, .4);
        wait 1;
    }
}   

spawn_3D_fx( fxID )
{
    if( IsDefined( level.dmc_fx_spawned ) && level.dmc_fx_spawned.size > 0 )
    {
        array_delete( level.dmc_fx_spawned );
        level.dmc_fx_spawned = [];
        return;
    }
    
    self thread refreshMenu();
    wait .2;
    
    level.dmc_fx_spawned = [];
    str                  = do_keyboard( "3D FX Drawing" );
    position             = dmc2_get_positions( str, .8, 35 );  //.8, 4.5
    angles               = self.angles;
    
    foreach( pos in position )
    {
        fx = SpawnFX( level._effect[ fxID ], (AnglesToForward( angles ) * 280 + pos) - (0,0,260) );
        TriggerFX( fx );
        level.dmc_fx_spawned[level.dmc_fx_spawned.size] = fx;
    }
    
    wait .2;
    self notify( "reopen_menu" );
}

dmc2_get_positions( str = "undefined", spacing, height )
{
    positions = [];
    angles    = self.angles;
    origin    = self.origin - (0,0,height);
    
    vecx = AnglesToRight(angles);
    vecy = AnglesToUp(angles);
    vecz = AnglesToForward(angles);
    str = toUpper( str );
    
    len = 0;
    for(i=0;i<str.size;i++)
    {
        letter = GetSubStr(str,i,i+1);
        len += level.aFontSize[letter] + spacing;
    }
    
    m = height; 
    x = (len / 2) * -1 * m;
    for(i=0;i<str.size;i++)
    {
        letter = GetSubStr(str,i,i+1);
        arr = level.aFont[letter];
        foreach(pos in arr)
        {
            ox = vectorScale(vecx, pos[0] * m + x);
            oy = vectorScale(vecy, (16 - pos[1]) * m);
            oz = vectorScale(vecz, 1);
            positions[ positions.size ] = origin + ox + oy + oz;
        }
        x += (level.aFontSize[letter] + spacing) * m;
    }
    return positions;
} 

dmc2_load_font()
{
    level.aFont     = [];
    level.aFontSize = [];
    font_letters    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!#^&*()-=+[]{}\\/,.'\"?$:;_ ";
    
    font = [];
    font[font.size] = "....x....x....x....x...x...x....x....x...x...x....x...x.....x....x.....x....x.....x....x...x...x....x...x.....x...x...x...x..x...x...x....x...x...x...x...x...x...x.x.....x...x.....x...x..x..x...x...x...x..x..x...x...x...x...x..x.x#x#.#x...x...x.x..x...x...x";
    font[font.size] = ".... .... .... .... ... ... .... .... ... ... .... ... ..... .... ..... .... ..... .... ... ... .... ... ..... ... ... ... .. ... ... .... ... ... ... ... ... ... . ..... ... ..... ... .# #. ... ... ... ## ## ..# #.. #.. ..# .. . # #.# ... .#. . .. ... ...";
    font[font.size] = ".##. ###. .##. ###. ### ### .##. #..# ### ### #..# #.. .#.#. #..# .###. ###. .###. ###. ### ### #..# #.# #.#.# #.# #.# ### .# ##. ### ..#. ### ### ### ### ### ### # .#.#. .#. .##.. .#. #. .# ... ... ... #. .# .#. .#. #.. ..# .. . . ... ### ### . .. ... ...";
    font[font.size] = "#..# #..# #..# #..# #.. #.. #... #..# .#. .#. #.#. #.. #.#.# ##.# #...# #..# #...# #..# #.. .#. #..# #.# #.#.# #.# #.# ..# ## ..# ..# .##. #.. #.. ..# #.# #.# #.# # ##### #.# #..#. ### #. .# ... ### .#. #. .# .#. .#. .#. .#. .. . . ... ..# #.. # .# ... ...";
    font[font.size] = "#### ###. #... #..# ##. ##. #.## #### .#. .#. ###. #.. #.#.# #.## #...# #..# #.#.# #..# ### .#. #..# #.# #.#.# .#. .#. .#. .# .#. ### #.#. ##. ### ..# ### ### #.# # .#.#. ... .##.. .#. #. .# ### ... ### #. .# #.. ..# .#. .#. .. . . ... .## ### . .. ... ...";
    font[font.size] = "#..# #..# #..# #..# #.. #.. #..# #..# .#. .#. #.#. #.. #.#.# #..# #...# ###. #..#. ###. ..# .#. #..# #.# #.#.# #.# .#. #.. .# #.. ..# #### ..# #.# .#. #.# ..# #.# . ##### ... #..#. #.# #. .# ... ### .#. #. .# .#. .#. .#. .#. .. . . ... ... ..# # .# ... ...";
    font[font.size] = "#..# ###. .##. ###. ### #.. .##. #..# ### #.. #..# ### #.#.# #..# .###. #... .##.# #..# ### .#. .### .#. .#.#. #.# .#. ### .# ### ### ..#. ##. ### .#. ### ### ### # .#.#. ... .##.# ... #. .# ... ... ... #. .# .#. .#. ..# #.. .# # . ... .#. ### . #. ### ...";
    font[font.size] = ".... .... .... .... ... ... .... .... ... ... .... ... ..... .... ..... .... ..... .... ... ... .... ... ..... ... ... ... .. ... ... .... ... ... ... ... ... ... . ..... ... ..... ... .# #. ... ... ... ## ## ..# #.. ..# #.. #. . . ... ... .#. . .. ... ...";

    pos1 = 0;
    index = 0;
    for(i=0;i<font[0].size;i++) 
    {
        if(GetSubStr(font[0], i, i + 1) == "x")
        {
            pos2 = i;
            letter = GetSubStr(font_letters, index, index+1);
            level.aFont[letter] = [];
            level.aFontSize[letter] = pos2 - pos1;
            for(x=pos1;x<pos2;x++) 
            {
                for(y=0;y<font.size;y++)
                {
                    if(GetSubStr(font[y], x, x+1) == "#") 
                        level.aFont[letter][level.aFont[letter].size] = (x - pos1, y, 0);
                }
            }
            index++;
            pos1 = pos2 + 1;
        }
    }
}

create_zipline( v )
{
    if( !IsDefined( level.ziplines ) ) 
        level.ziplines = [];
    if( !IsDefined( level.zipline_e_trigger) )
        level.zipline_e_trigger = [];
        
    if( IsDefined( level.ziplines[v] ) )
    {
        level notify("stop_zipline");
        level.ziplines[v] delete();
        level.zipline_e_trigger[v] gameobjects::destroy_object(1, 1);
        level.zipline_fx delete();
        return;
    }
        
    level.ziplines[v] = modelSpawner( self.origin + (0,0,90), "test_sphere_silver", undefined, undefined, 4 );
    
    if(level.ziplines.size >= 2 )
        level thread fx_zipline( level.ziplines );
    
    level.zipline_e_trigger[v] = setup_gameobject( level.ziplines[v].origin, undefined, "HOLD ^3[{+activate}]^7 TO ZIPLINE", level.ziplines[v], 60 );
    level.zipline_e_trigger[v].onUse = ::onUse_zipline;
}

fx_zipline( zipline )
{
    level endon("stop_zipline");
    level.zipline_fx = modelSpawner( zipline[0].origin, "tag_origin" );
    fxOrg            = level.zipline_fx;
    fx               = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
    while( IsDefined( fxOrg ) && level.ziplines.size >= 2 )
    {
        fxOrg MoveTo( zipline[0].origin, .05 );
        fxOrg util::waittill_any( "movedone", "death" );
        fxOrg MoveTo( zipline[1].origin, .05 );
        fxOrg util::waittill_any( "movedone", "death" );
    }
    fx delete();
}

onUse_zipline( player )
{
    player thread do_zipline( level.ziplines );
}

do_zipline( ziplines )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    
    target  = ArrayGetClosest( self.origin, ziplines );
    carrier = modelSpawner( target.origin - (0,0,80), "tag_origin", self.angles );
    self playerLinkToDelta( carrier, "tag_origin", 1, 180, 180, 180, 180 );
    self thread watchDrop_zipline( carrier );
    
    if( target == ziplines[1] )
        target = ziplines[0]; 
    else target = ziplines[1];
    
    time = distance( carrier.origin, target.origin ) / 600;
    carrier moveTo( target.origin - (0,0,80), time, time * 0.2 );
    target_angles = VectorToAngles( carrier.origin - target.origin );
    
    if( carrier.angles != target_angles )
        carrier rotateTo( target_angles, time * 0.8 );
    wait time + .2;
    
    self notify( "destination" );   
    self unlink();  
    carrier delete();
}

watchDrop_zipline( carrier )
{
    self waittill( "destination" );
    self Unlink();
    carrier delete();
}


toggle_fortress()
{
    if(isDefined( level.fortress_deletion_awaiting ))
        return self iPrintLnBold("Fortress is awaiting for deletion");
    if(!isDefined( level.fortress_struct ) && !isDefined( level.fortress_built ))
    {
        level.fortress_built = true;
        self thread build_fortress();
    }
    else 
    {
        level.fortress_deletion_awaiting = true;
        while(!isDefined( level.fortress_struct ))
            wait .1;

        level notify("stop_fortress");

        fort = level.fortress_struct;
        array_delete( fort.triggers );
        array_delete( fort.fortress );
        array_delete( fort.collisions );

        level.fortress_built = undefined;
        level.fortress_struct = undefined;
        level.fortress_windows = undefined;
        level.fortress_deletion_awaiting = undefined;
    }
}

build_fortress()
{
    origin   = (-1600, -735, 619);
    distance = 90;
    initial  = false;
    block    = 0;
    
    triggers   = [];
    fortress   = [];
    windows    = [];
    collisions = [];
    
    fortress[0] = modelSpawner(origin, "p7_zm_der_magic_box", (0,0,0)); //default spawn
    fortress[0] hide();
    
    for(i=0;i<=35;i++) 
    {
        distance      = 90;
        current_block = fortress[fortress.size-1];
        n_angle       = current_block.angles;
        
        if( block > 3 && !initial || initial )
        {
            distance = 20;
            n_angle  = current_block.angles + (0, 15, 0);
            initial  = ( n_angle[1] == 90 || n_angle[1] == 180 || n_angle[1] == 270 ) ? 0 : 1;
            block = 0;
        }
        for(e=0;e<7;e++) 
        {
            fortress[fortress.size] = modelSpawner((current_block.origin[0], current_block.origin[1], origin[2] + e*18) + AnglesToForward(current_block.angles)*distance, current_block.model, n_angle, .05);
            if(!initial && e >= 1 && e < 4)
            {
                windows[windows.size] = fortress[fortress.size-1];
                
                if(windows.size >= 12)
                {
                    triggers[triggers.size] = modelSpawner(windows[4].origin, "tag_origin", windows[4].angles);
                    triggers[triggers.size-1] thread monitor_windows( windows );
                    collisions[collisions.size] = spawncollision("collision_clip_wall_256x256x10", "collider", windows[4].origin + AnglesToForward(windows[4].angles)*25, windows[4].angles + (0,90,0));
                    windows = [];
                }
            }
            if(initial)
                collisions[collisions.size] = spawncollision("collision_player_32x32x128", "collider", current_block.origin + AnglesToRight(current_block.angles)*12, current_block.angles + (0,90,0));
        }
        block++;
    }
    for(i=0;i<5;i++) for(e=0;e<=22;e+=22)
    {
        fortress[fortress.size] = modelSpawner(fortress[8].origin + (0, 0, i*18) - (AnglesToRight(fortress[7].angles)*(209 + e)), fortress[7].model, (0, 0, 0), .05);
        fortress[fortress.size] = modelSpawner(fortress[15].origin + (0, 0, i*18) - (AnglesToRight(fortress[13].angles)*(209 + e)), fortress[13].model, (0, 0, 0), .05);
    }
    collisions[collisions.size] = spawncollision("collision_clip_wall_512x512x10", "collider", fortress[fortress.size-1].origin + (0,0,32), fortress[fortress.size-1].angles + (90,90,0));
    
    for(i=1;i<19;i++) for(e=1;e<6;e++)
        fortress[fortress.size] = modelSpawner(fortress[0].origin - AnglesToForward(fortress[0].angles)*36 + AnglesToForward(fortress[0].angles)*(90*e) - AnglesToRight(fortress[0].angles)*(23*i) + (0,0,90), current_block.model, fortress[0].angles, .05);

    fort = spawnStruct();
    fort.triggers   = triggers;
    fort.fortress   = fortress;
    fort.collisions = collisions;
    level.fortress_struct = fort;
    level.fortress_windows = 1;
}

monitor_windows( group )
{ 
    level endon("stop_fortress");

    self MakeUsable();
    self SetCursorHint("HINT_ACTIVATE");
    self SetHintString("Press [{+activate}] To Open / Close Window.");
    self.state = 1;
    
    array = [];
    for(e=3;e<9;e++)
        array[array.size] = group[e];

    while(IsDefined(self))
    {
        foreach(i, section in array)
        {
            if(i > 2 && self.state || i < 3 && !self.state)
                section MoveTo( (section.origin + AnglesToForward(section.angles)*90), 2 );
            else 
                section MoveTo( (section.origin + AnglesToForward(section.angles)*-90), 2 );
        }
        self.state = !self.state;
        wait 2.1;
        self waittill("trigger", player);
    }
}

open_fortress_windows()
{
    if(!isDefined(level.fortress_struct))
        return;
    
    level.fortress_windows = !level.fortress_windows;
    foreach(window in level.fortress_struct.triggers)
    {
        iPrintLnBold(window.origin);
        if(window.state == level.fortress_windows)
            window notify("trigger", self);
    }
}

teleport_to_fortress()
{
    if(!isDefined(level.fortress_struct))
        return;
    obj = level.fortress_struct.triggers[ randomInt(3) ];
    origin = obj.origin - anglesToRight( obj.angles ) * 100; 
    self setOrigin( getGroundPoint( origin ) );
}
