spawnModel(model)
{
    self notify("SHOOT_MODEL_END");
    if(isDefined(self.currentModel))
    {
        self.currentModel setModel(model);
        self resetModelAngles(0,0,0);
        return;
    }
    
    if(!isDefined(self.modelDistance))
        self.modelDistance = 180;
    if(!IsDefined(self.modelScale))
        self.modelScale = 1;
        
    vector                 = self getEye() + vectorScale(anglesToforward(self getPlayerAngles()), self.modelDistance);
    self.currentModel      = spawnStruct();
    self.currentModel      = modelSpawner( vector, model, undefined, undefined, self.modelScale );
    self.currentModel.spin = [];
    for(a=0;a<3;a++)
        self.currentModel.spin[a] = 0;
        
    self thread moveModel();
}

moveModel()
{
    self endon("disconnect");
    self endon("game_ended");
    self endon("death");
    
    while(isDefined(self.currentModel))
    {
        if(!isDefined(self.ignoreCollisions))
            self.currentModel moveTo(bulletTrace(self getEye(),self getEye()+vectorScale(anglesToforward(self getPlayerAngles()),self.modelDistance),false,self.currentModel)["position"],.1);
        else
            self.currentModel moveTo(self getEye()+vectorScale(anglesToforward(self getPlayerAngles()),self.modelDistance),.1);
        wait .1;
    }
}

placeModel()
{
    if(!isDefined(level.forgeSpawnedArray)) 
        level.forgeSpawnedArray = [];
    
    if(isDefined(self.currentModel))
    {
        ent = modelSpawner(self.currentModel.origin, self.currentModel.model, self.currentModel.angles, undefined, self.modelScale);
        self undoFeature(ent,self.currentModel.model);
        self.currentModel delete();
        self.closestEnt = undefined;
    }
}

undoFeature(ent,model)
{
    level.forgeSpawnedArray[level.forgeSpawnedArray.size] = ent;
    
    if(!isDefined(self.forgeID)) 
        self.forgeID = [];
    if(!isDefined(self.forgeModel[model]))
        self.forgeModel[model] = [];

    self.forgeModel[model][self.forgeModel[model].size] = ent;
    self.forgeID[self.forgeID.size] = model;
}

copyModel()
{
    if(!isDefined(level.forgeSpawnedArray))
        level.forgeSpawnedArray = [];
    
    if(isDefined(self.currentModel))
    {
        ent = modelSpawner(self.currentModel.origin,self.currentModel.model,self.currentModel.angles, undefined, self.modelScale);
        self thread undoFeature(ent,self.currentModel.model);
    } 
}

rotateModel(num,dir)
{
    self.currentModel.spin[num] += 18*dir;
    self.currentModel rotateTo((self.currentModel.spin[0],self.currentModel.spin[1],self.currentModel.spin[2]),.25);

    if(self.currentModel.spin[num] > 360 || self.currentModel.spin[num] < 0)
    {
        self.currentModel.spin[num] -= 360*dir; wait .05;
        self.currentModel rotateTo((self.currentModel.spin[0],self.currentModel.spin[1],self.currentModel.spin[2]),.25);
    }
}

deleteModel()
{
    if(isDefined(self.currentModel))
    {
        self.currentModel delete();
        self.closestEnt = undefined;
    }
}

modelUndo()
{
    if(self.forgeID.size == 0)
        return;
    model = self.forgeID[self.forgeID.size-1];
    self.forgeModel[model][self.forgeModel[model].size-1] delete();
    self.forgeModel[model][self.forgeModel[model].size-1] = undefined;
    self.forgeID[self.forgeID.size-1] = undefined;
}

modelDistance(val, decrease)
{
    if(!isDefined( self.currentModel )) 
        return;
    if(!isDefined( self.modelDistance ))
        self.modelDistance = 180;
    
    if(IsDefined( decrease )) 
        self.modelDistance -= val;
    else if(isDefined( val ) ) 
        self.modelDistance += val;
    else 
        self.modelDistance = 200;
}

modelScale(val, decrease)
{
    if(!isDefined( self.modelDistance ))
        self.modelScale = 1;
    
    if(IsDefined( decrease )) 
        self.modelScale = val;
    else if(isDefined( val )) 
        self.modelScale = val;
    else 
        self.modelScale = 1;
    
    if(isDefined( self.currentModel ))
        self.currentModel SetScale( self.modelScale );
    self refreshMenuToggles();
}

ignoreCollisions()
{
    if(!isDefined(self.ignoreCollisions))
        self.ignoreCollisions = true;
    else
        self.ignoreCollisions = undefined;
}

deleteAllSpawned()
{
    if(!isDefined(level.forgeSpawnedArray)) return;
    for(a=0;a<level.forgeSpawnedArray.size;a++)
        if(isDefined(level.forgeSpawnedArray[a]))
            level.forgeSpawnedArray[a] delete();
    level.forgeSpawnedArray = undefined;

    for(a=0;a<level.players.size;a++)
    {
        level.players[a].forgeID = [];
        level.players[a].forgeModel = [];
        level.players[a].closestEnt = undefined;
    }
}

resetModelAngles(a,a1,a2)
{
    self.currentModel.spin[0] = a;
    self.currentModel.spin[1] = a1;
    self.currentModel.spin[2] = a2;
    self.currentModel.angles = (self.currentModel.spin[0],self.currentModel.spin[1],self.currentModel.spin[2]);
}

teleportModel( ent )
{
    if(!isDefined( self.modelDistance ))    
        self.modelDistance = 180;
    if(IsDefined( ent ))    
        ent.origin = lookPos( self.modelDistance, "position" );
}
