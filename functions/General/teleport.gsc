advancedTele( end, angle )
{
    if(isDefined( self.teleporting ))
        return self iprintln("^1Error^7: Please wait until you have finished teleporting.");
    if(!isDefined( angle )) angle = self.angles;
    
    if(isDefined(self.cinematicTele))
    {
        self.teleporting = true;
        start            = self.origin;
        angles           = vectorToAngles(end - self geteye());
        camera           = modelSpawner(start + (0,0,40), "tag_origin", angles);
        
        if(!isDefined(self.godmode))
            self EnableInvulnerability();
        self setOrigin( end );
        self setPlayerAngles( angle );
        self freezeControls( true );
        
        self cameraSetPosition( camera );
        self cameraSetLookAt();
        self cameraActivate( true );
        
        camera moveTo(start + (0,0,5000), 4, 2, 2);
        camera rotateto(angles + (90,0,0), 3, 1, 1);
        wait 3;
        camera moveTo(end, 4, 2, 2);
        wait 1;
        camera rotateto(angle, 3, 1, 1);
        wait 3;
        
        self cameraActivate( false );
        if(!isDefined(self.godmode))
            self DisableInvulnerability();
        self freezeControls( false );   
        self.teleporting = undefined;   
        camera delete();
    }
    else 
    {
        self setOrigin( end );
        self setPlayerAngles( angle );
    }
}

cinematicTele()
{
    if(!isDefined(self.cinematicTele))
        self.cinematicTele = true;
    else self.cinematicTele = undefined;
}

savePos()
{
    if(!isDefined(self.posSaved))
    {
        self.posSaved = self.origin;
        self.posAngles = self.angles;
    }
    else
    {
        self.posSaved = undefined;
        self.posAngles = undefined;
    }
}

loadPos()
{
    if(isDefined(self.posSaved))
    {
        if(!isDefined(self.cinematicTele))
        {
            self setOrigin( self.posSaved );
            self setPlayerAngles( self.posAngles );
        }
        else self thread advancedTele( self.posSaved, self.posAngles );
    }
    else self iprintln("^1Error^7: Save Your Position First");
}

saveLoadBind()
{
    self endon("disconnect");
    level endon("game_ended");
    
    if(!isDefined( self.saveLoad ) && !isDefined( self.adSaveLoad ) )
    {   
        self.saveLoad = true;
        self.savePos = undefined;
        
        self iprintln("Press ^2[{+actionslot 3}]^7 To Load Location");
        self iprintln("Press ^2[{+actionslot 3}] ^7&^2 Prone^7 To Save Location");
        self iprintln("Press ^2[{+melee}] ^7&^2 Prone^7 To Reset Location");
        
        while( isDefined(self.saveLoad) )
        {
            if(self actionslotthreebuttonpressed() && isDefined(self.savePos))
            {
                self setOrigin((self.savePos));
                self SetPlayerAngles((self.saveAngle));
                self iprintln("Position Loded: ^2"+self.savePos);
                wait .2;
            }
            else if(self actionslotthreebuttonpressed() && self getStance() == "prone")
            {
                self.savePos   = self.origin;
                self.saveAngle = self.angles;
                self iprintln("Position Saved: ^2"+self.savePos);
                wait .2;
            }
            else if(self actionslotthreebuttonpressed() && self getStance() == "prone")
            {
                self.savePos = undefined;
                self iprintln("Position Successfully Reset!");
                wait .2;
            }
            else if(self actionslotthreebuttonpressed() && !isDefined(self.savePos))
            {
                self iprintln("^1Error^7: Please save a origin you would like to load.");
                wait .2;
            }
            wait .05;
        }
    }
    else if(isDefined( self.saveLoad ))
        self.saveLoad = undefined;
    else self iprintln("^1Error^7: Please Turn Off The Other Save & Load.");
}

teleCrosshair( range )
{
    if(range == "Max") range = 999999;
        self setOrigin(bulletTrace(self getTagOrigin("j_head"), self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles()) * int(range), false, self)["position"]);
}

teleportToRandomSpawn()
{
    array = level.spawnPoints;
    if(!isDefined(array) || array.size == 0)
        return;
    random = array[randomInt(array.size)];
    self advancedTele( random.origin, random.angles );
}

allToMe( team, crosshair )
{
    foreach(player in level.players)
    {
        if( team == "Closest" )
            player = self returnClosestPlayer();
        if( isDefined(crosshair) )
            player setOrigin(bulletTrace(self getTagOrigin("j_head"), self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles()) * 999999, false, self)["position"]);
        else 
            player setOrigin( self.origin );
        if( team == "Closest" )
            return;
    }
}

teleRandomPers( team )
{
    if(team == "Closest") 
        return self setOrigin(self returnClosestPlayer().origin);
    rand = randomIntRange(0, level.players.size+1);
    self setOrigin(level.players[rand].origin);
}