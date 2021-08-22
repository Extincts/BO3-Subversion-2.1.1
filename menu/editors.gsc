progressbar( min, max, mult, time )
{        
    if( isDefined( self.was_edited ))
        return true;

    self endon("disconnect");
    curs     = min-1;
    cap_curs = (self getCursor() > 10) ? 9 : self getCursor();
    
    self lockMenu("lock", "open");
    self thread deleteLineInfo();

    while( curs <= max-1 )
    {
        curs += mult;
        math       = (98 / max) * curs;
        position_x = (max) / ((108 - 14));
        xPosition = self.menu["OPT"][cap_curs].x;

        if(IsDefined( self.eMenu[ cap_curs ].toggle ))
            xPosition -= 20;

        progress = [];
        progress[progress.size] = self createRectangle("RIGHT", "CENTER", xPosition + 240, self.menu["OPT"][cap_curs].y, 108, 14, (0,0,0), "white", 4, 1); //BG
        progress[progress.size] = self createRectangle("LEFT", "CENTER", progress[progress.size-1].x -107 + (curs / position_x), progress[progress.size-1].y, 12, 12, self.presets["SCROLL_STITLE_BG"], "white", 5, 1); //INNER
        progress[progress.size] = self createText("objective", 1, "RIGHT", "CENTER", xPosition + 111, progress[progress.size-2].y, 5, 1, int( min(curs, 100) ), (1,1,1));
        progress[progress.size] = self createText("objective", 1, "RIGHT", "CENTER", xPosition + 126, progress[progress.size-2].y, 5, 1, "/" + max, (1,1,1));
        
        wait time;
        self destroyAll( progress );
    }
    self setMenuText();
    self notify("progress_done");
    wait .05;
    self lockMenu("unlock", "open");
}

areYouSure()
{
    if( isDefined( self.was_edited ))
        return true;

    self lockMenu("lock", "open");
    self thread deleteLineInfo();
    
    cap_curs = (self getCursor() > 10) ? 9 : self getCursor();
    xPos     = self.menu["OPT"][cap_curs].x + ((IsDefined( self.eMenu[ self getCursor() ].toggle )) ? 0 : 20);
    
    youSure  = [];
    youSure[youSure.size] = self createRectangle("RIGHT", "CENTER", xPos + 221, self.menu["OPT"][cap_curs].y, 18, 12, rgb(15,14,15), "white", 5, 1); //INNER
    youSure[youSure.size] = self createRectangle("RIGHT", "CENTER", xPos + 202, self.menu["OPT"][cap_curs].y, 18, 12, rgb(62,58,63), "white", 5, 1); //INNER
    youSure[youSure.size] = self createRectangle("RIGHT", "CENTER", xPos + 222, self.menu["OPT"][cap_curs].y, 39, 14, (0,0,0), "white", 4, 1); //BG
    youSure[youSure.size] = self createText("small", 1, "LEFT", "CENTER", xPos + 185, self.menu["OPT"][cap_curs].y, 6, 1, " Yes     No", (1,1,1));
    youSure[youSure.size] = self createText("small", 1, "RIGHT", "CENTER", xPos + 180, self.menu["OPT"][cap_curs].y, 5, 1, "Are You Sure?", (1,1,1));
    wait .2;
    
    curs = 0;
    while(!self UseButtonPressed())
    {
        if( self attackButtonPressed() || self adsButtonPressed() )
        {
            youSure[curs].color = rgb(62,58,63);
            curs += self attackButtonPressed();
            curs -= self adsButtonPressed();
            
            if( curs < 0 ) curs = 1;
            if( curs > 1 ) curs = 0;
            youSure[curs].color = rgb(15,14,15);
            wait .2;
        }
        wait .05;
    }
    self destroyAll( youSure );
    wait .1;
    self lockMenu("unlock", "open");
    if( curs == 0 )
        return true;
    return false;    
}

deleteLineInfo( curs = self getCursor() )
{
    curs = (self getCursor() > 10) ? 9 : self getCursor();
    self.menu["UI_SLIDE"][curs] destroy();
    self.menu["UI_SLIDE"][curs + 10] destroy();
    self.menu["UI_SLIDE"]["VAL"] destroy();
    
    self.menu["UI_SLIDE"]["STRING_"+curs] destroy();
}

do_keyboard( title = "Keyboard" )
{ 
    keys = [];
    keys[0] = ["0", "A", "N", ":"];
    keys[1] = ["1", "B", "O", ";"];
    keys[2] = ["2", "C", "P", ">"];
    keys[3] = ["3", "D", "Q", "$"];
    keys[4] = ["4", "E", "R", "#"];
    keys[5] = ["5", "F", "S", "-"];
    keys[6] = ["6", "G", "T", "*"];
    keys[7] = ["7", "H", "U", "+"];
    keys[8] = ["8", "I", "V", "@"];
    keys[9] = ["9", "J", "W", "/"];
    keys[10] = ["^", "K", "X", "_"];
    keys[11] = ["!", "L", "Y", "["];
    keys[12] = ["?", "M", "Z", "]"];
    
    UI = [];
    for(i=0;i<13;i++)
    {
        row = "";
        for(e=0;e<4;e++)
            row += keys[i][e] + "\n";
        UI["keys_"+i] = createText( "objective", 1.2, "LEFT", "CENTER", -125 + (i*20), -30, 4, 1, row, (1,1,1) );
    }
    
    UI["TITLE"] = createText( "objective", 1.4, "TOP", "CENTER", 0, -82, 4, 1, toUpper( title ), (1,1,1) );
    UI["PREVIEW"] = createText( "objective", 1.2, "TOP", "CENTER", 0, -55, 4, 1, "", (1,1,1) );
    UI["INSRUCT_0"] = createText( "objective", 1, "TOP", "CENTER", 0, 30, 4, 1, "Capitals - [{+frag}] : Backspace - [{+melee}] : Confirm - [{+gostand}] : Cancel - [{+stance}]", (1,1,1) );
    UI["INSRUCT_1"] = createText( "objective", 1, "TOP", "CENTER", 0, 40, 4, 1, "Up - [{+actionslot 1}] : Down - [{+actionslot 2}] : Left - [{+actionslot 3}] : Right [{+actionslot 4}]", (1,1,1) );
    
    UI["BG"] = createRectangle( "TOP", "CENTER", 0, -90, 300, 120, (0,0,0), "white", 0, .7 );
    UI["RESULT"] = createRectangle( "TOP", "CENTER", 0, -59, 300, 20, (0,0,0), "white", 1, .7 );
    UI["CURSOR"] = createRectangle( "LEFT", "CENTER", UI["keys_0"].x - 1, UI["keys_0"].y, 14, 14, (1,0,0), "white", 2, .7 );
    
    result   = "";
    curs_x   = 0;
    curs_y   = 0;
    capitals = 1;
    
    while( true ) 
    {
        if( self ActionSlotThreeButtonPressed() )         curs_x = minus_keyboard_curs( curs_x, 0, 12 ); 
        else if( self ActionSlotFourButtonPressed() )     curs_x = plus_keyboard_curs( curs_x, 0, 12 );
        else if( self ActionSlotOneButtonPressed() )      curs_y = minus_keyboard_curs( curs_y, 0, 3 );
        else if( self ActionSlotTwoButtonPressed() )      curs_y = plus_keyboard_curs( curs_y, 0, 3 );
        else if( self JumpButtonPressed() )
            break; 
        else if( self StanceButtonPressed() )
            return self destroyAll( UI );
            
        if( self UseButtonPressed() )
        {
            result += (capitals ? toLower( keys[curs_x][curs_y] ) : keys[curs_x][curs_y] );
            wait .2;
        }
        else if( self MeleeButtonPressed() && result.size > 0 )
        {
            temp = "";
            for(e=0;e<result.size-1;e++)
                temp += result[e];
            result = temp;
            wait .2;
        }
        else if( self FragButtonPressed() ) 
        {
            capitals = capitals ? 0 : 1;
            for(i=0;i<13;i++)
            {
                row = "";
                for(e=0;e<4;e++)
                    row += (capitals ? (toLower( keys[i][e] ) + " \n") : (keys[i][e] + "\n") );
                UI["keys_"+i] setText( row );
            }
            wait .2;
        }
        
        UI["CURSOR"].x = UI["keys_" + curs_x ].x - 4;
        UI["CURSOR"].y = UI["keys_0"].y + (curs_y * 14.5);
        UI["PREVIEW"] setText( result );
        wait .05;
    }
    self destroyAll( UI );
    return result;
}  

plus_keyboard_curs( curs, min, max ) //12 - 3
{
    curs++;
    if( curs > max )
        curs = min;
    wait .2; 
    return curs;
}

minus_keyboard_curs( curs, max, min ) //12 - 0
{
    curs--;
    if( curs < max )
        curs = min;
    wait .2; 
    return curs;    
}
