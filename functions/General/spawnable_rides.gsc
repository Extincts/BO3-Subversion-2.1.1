monitorSeats( ride, array )
{
    self endon("death");
    trig = self;
    trig MakeUsable();
    trig SetCursorHint( "HINT_ACTIVATE" );
    trig setHintString( "Press ^3[{+activate}]^7 to ride the " + ride + "." );
    
    while( true )
    {
        trig waittill( "trigger", player );
        
        if(IsDefined( player.in_seat ))
            break;
            
        save_origin    = player.origin;
        player.in_seat = true;
        trig.in_use    = true;
        
        trig arySetUnUsable( array, player );
        trig setHintString( "Press ^3[{+melee}]^7 to exit the " + ride + "." );
        player animmode( "noclip" );

        if( ride == "Ferris Wheel" )
        {
            seat = modelSpawner( trig.origin - anglesToRight(self.angles) * 22, "script_origin", (0,90,0) );
            //seat thread seatAngleFix( trig );
            player PlayerLinkToDelta( seat );
        }
        else if( ride == "Centrox" || ride == "Fireball" )
            player PlayerLinkToAbsolute( trig, "tag_origin" ); 
        else if( ride == "The Claw" )    
            player PlayerLinkToDelta( trig );
        else
            player playerLinkTo( trig );
            
        player setStance( "crouch" );  
        player editMovements( 0 );
        
        if( !isDefined( player.godmode ) )
            player EnableInvulnerability();  
        
        while(!player MeleeButtonPressed() && !isDefined( player.kicked_from_ride ) && isDefined( player.in_seat ) && IsAlive( player ))
            wait .05;
            
        trig setHintString( "Press ^3[{+activate}]^7 to ride the " + ride + "." );
        if( !isDefined( player.godmode ) )
            player DisableInvulnerability();
            
        player unlink();    
        player setOrigin( save_origin );
        player editMovements( 1 );
        player animmode( "noclip", true );
        
        if( ride == "Ferris Wheel" )
            seat delete();
            
        trig.in_use             = undefined;
        player.kicked_from_ride = undefined;
        player.in_seat          = undefined;
        trig arySetUsable( array );
    }
}

detach_from_seat()
{
    foreach(player in level.players)
    {
        if(IsDefined( player.in_seat ))
        {
            player unlink();
            if(!isDefined(player.godmode))
                player DisableInvulnerability();
                
            player editMovements( 1 );      
            player.in_seat = undefined;
        }   
    }   
}

toggle_claw_spawn()
{
    if( !IsDefined( level.claw_spawned ) )
    {
        level.claw_spawned = true;
        self thread build_claw();
    }
    else
    {
        level.claw_spawned = undefined;
        
        level thread detach_from_seat();
        level notify("destroy_claw");
        
        array_delete( level.seats );
        array_delete( level.claw );
        array_delete( level.legs );
    }
}

build_claw()
{
    level endon("destroy_claw");
    pos = self.origin;
    
    level.seats = []; 
    level.claw  = [];
    level.legs  = [];
    
    for(i=0;i<2;i++) for(e=0;e<2;e++) for(a=0;a<4;a++) 
    {
        multi  = (i == 1) ? -1 : 1;
        upward = AnglesToForward( (120 * multi, 0, 90) ) * (90 * multi) * a;
        level.legs[level.legs.size] = modelSpawner(pos + (0,15,270) + (-30 * multi, -170 + (e*340), 0) + upward, "p7_zm_der_magic_box", (120 * multi, 0, 90),.1);
    }

    for(a=0;a<4;a++) for(e=0;e<=10;e++)
        level.claw[level.claw.size] = modelSpawner(pos + (0,-130+(a*90),310) + (sin(-90 + (e*36))*36, 0, sin(e*36)*36), "p7_zm_der_magic_box", (0, 90, 90 + (e*36)), .1);
    
    for(a=0;a<8;a++) for(e=0;e<3;e++)
    level.claw[level.claw.size] = modelSpawner(pos + (0,15,290) + (cos(a*45)*12,sin(a*45)*12, e*-90), "p7_zm_der_magic_box", (90,(a*45)+90,90),.1);
    level.claw[level.claw.size] = modelSpawner(pos + (-10,15,60), "p7_zm_der_magic_box", (90,90,90),.1);    
    
    for(a=0;a<2;a++) for(e=0;e<8;e++)
    level.claw[level.claw.size] = modelSpawner(pos + (0,15,90) + (cos(e*45)* (50 + a*50), sin(e*45)* (50 + a*50), -70), "p7_zm_der_magic_box", (0, (e*45) + (a*90), 0), .1);
    
    for(e=0;e<8;e++)
        level.seats[level.seats.size] = spawn("script_origin", pos + (0,15,90) + (cos(e*45)*86,sin(e*45)*86, -60));

    link = modelSpawner(pos + (0,15,310), "tag_origin");
    foreach(model in level.claw)
        model linkTo( link );
    foreach(model in level.seats)
        model linkTo( link );
    
    link thread clawMovements();    
    thread Array::thread_all( level.seats, ::monitorSeats, "The Claw", level.seats );
}

clawMovements()
{
    level endon("destroy_claw");
    
    level.claw_speed  = .5;
    level.claw_height = 110;
    
    speed  = level.claw_speed;
    height = level.claw_height;

    for(e=0; e > 0 - (height / 3); e-=2)
    {
        self rotateTo( (e, self.angles[1], 0), speed);
        wait .1; 
    }
    
    for(e=e; e < (height / 2.5); e+=3)
    {
        self rotateTo( (e, self.angles[1], 0), speed );
        wait .1;
    }
    
    for(e=e; e > 0 - (height / 2); e-=3)
    {
        self rotateTo( (e, self.angles[1], 0), speed );
        wait .05;
    }
    
    for(e=e; e < (height / 1.5); e+=4)
    {
        self rotateTo( (e, self.angles[1], 0), speed );
        wait .05;
    }
    
    while( true )
    {
        for(e=e; e > 0 - height; e-=5)
        {
            self rotateTo( (e, self.angles[1], 0), speed );
            wait .05;
        }

        for(e=e; e < height; e+=5)
        {
            self rotateTo( (e, self.angles[1], 0), speed );
            wait .05;
        }
        wait .05;
    }
}
