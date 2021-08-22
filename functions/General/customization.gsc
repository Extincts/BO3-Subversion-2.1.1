RGB_Edit( slider, type, rgb )
{
    if(slider != "rainbow")
    {
        if(self.presets[ type ]+"" == "rainbow")
            return;
        
        vec3 = (0,0,0);
        R    = self.presets[ type ][0];
        G    = self.presets[ type ][1];
        B    = self.presets[ type ][2];
        
        if( rgb == "R" )        vec3 = ((slider / 255), G, B);
        if( rgb == "G" )        vec3 = (R, (slider / 255), B);
        if( rgb == "B" )        vec3 = (R, G, (slider / 255));    
    }
    else 
        vec3 = (self.presets[ type ] != "rainbow" ? "rainbow" : get_preset(type));
    
    self.presets[ type ] = vec3;
    self thread refreshMenu( true ); 
}

menuPosEditor()
{
    self thread refreshMenu();
    
    posEditor = [];
    posEditor[0]  = self createRectangle("TOPLEFT", "CENTER", self.presets["X"] - 1.6, self.presets["Y"] - 121.5, 263, 234, self.presets["OUTLINE"], "white", 0, 1);
    posEditor[1] = self createText("default", 1.4, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 90, 3, 1, "POSITION EDITOR", self.presets["TEXT"]);   
    posEditor[2] = self createText("default", 1.2, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 45, 3, 1, "^0* ^7USER CONTROLS^0 *^7", self.presets["TEXT"]);  
    posEditor[3] = self createText("default", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 30, 3, 1, "UP - [{+attack}]    DOWN - [{+speed_throw}]", self.presets["TEXT"]);  
    posEditor[4] = self createText("default", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 15, 3, 1, "LEFT - [{+actionslot 3}]    RIGHT - [{+actionslot 4}]", self.presets["TEXT"]);  
    posEditor[5] = self createText("default", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] + 10, 3, 1, "CONFIRM POSITION - [{+reload}]", self.presets["TEXT"]);  
    posEditor[6] = self createText("default", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] + 65, 3, 1, "*THIS MENU IS THICC*", self.presets["TEXT"]);  
    posEditor[7] = self createText("default", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] + 75, 3, 1, "*BE CAUTIOUS WHEN CHOOSING POSITION*", self.presets["TEXT"]);  
    wait .2;
    
    xPos = self.presets["X"]; yPos = self.presets["Y"];
    while( !self MeleeButtonPressed() )
    {
        if( self attackButtonPressed() )
        {
            yPos += 10;
            foreach( hud in posEditor )
                hud.y += 10;
            wait .1;       
        }
        else if( self adsButtonPressed() )
        {
            yPos -= 10;
            foreach( hud in posEditor )
                hud.y -= 10;
            wait .1;    
        }
        else if( self actionslotfourbuttonpressed() )
        {
            xPos += 10;
            foreach( hud in posEditor )
                hud.x += 10;
            wait .1;      
        }
        else if( self actionslotthreebuttonpressed() )
        {
            xPos -= 10;
            foreach( hud in posEditor )
                hud.x -= 10;
            wait .1;      
        }
        else if( self UseButtonPressed() )
            break;
        wait .05;
    }
    self.presets["X"] = xPos;
    self.presets["Y"] = yPos;
    self destroyAll( posEditor );
    self notify( "reopen_menu" );
}