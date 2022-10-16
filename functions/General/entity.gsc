/*
	CREDITS:
		Extinct [Writing All Of the Code]
		Mikeeeyy [Original Idea's & Example Code]

	FILE CONTAINS: 
	SpawnScriptModel  - done
	PlaceScriptModel	- done
	CopyScriptModel 	- done
	RotateScriptModel   - done
	ResetSctiptModel 	- done
	DeleteScriptModel	- done
	DeleteAllSpawnedScriptModels - done
	UndoLastScriptModel	- done
	ScriptModelDistance - done
	ScriptModelSnapping - done
	IgnoreCollisions	- done
	CopyExpandScriptModel - done

	BulkScriptModelCenter - done
	BulkScriptModelHeight - done
	BulkScriptModelRadius - done
	BulkScriptModelPreview - done 
	BulkScriptModelPickup - done
	BulkScriptModelDrop - done
	BulkScriptModelDelete - done
	BulkScriptModelCancel - done
*/

spawnScriptModel( model )
{
	if(isDefined( self.scriptmodel_current ))
		self.scriptmodel_current delete();

	if(!isDefined( self.scriptmodel_array ))
		self.scriptmodel_array = [];

	if(!isDefined( self.scriptmodel_distance ))
		self.scriptmodel_distance = 200;

    if(!IsDefined( self.scriptmodel_scale ))
        self.scriptmodel_scale = 1;
	
	if(!isDefined( self.scriptmodel_angles ))
		self.scriptmodel_angles = (0,0,0);

	if(!isDefined( self.scriptmodel_current ))
		self.scriptmodel_current = modelSpawner( self.origin, model, self.scriptmodel_angles, undefined, ((self.scriptmodel_snapping) ? 1 : self.scriptmodel_scale) );

	while(isDefined( self.scriptmodel_current ))
	{
		position = ( isDefined( self.scriptmodel_collision ) ? self lookPos( self.scriptmodel_distance ) : self getEye() + anglesToForward( self getPlayerAngles() ) * self.scriptmodel_distance );

		self.scriptmodel_current moveTo( position, .1 );
		if(!isDefined( self.scriptmodel_current.Snapped ))
			self.scriptmodel_current.angles = self.scriptmodel_angles;

		snappableModels = [];
		scriptModels = GetEntArray("script_model", "classname");

		for (e = 0; e < scriptModels.size; e++)
		{
			if (scriptModels[e].model == self.scriptmodel_current.model && scriptModels[e] != self.scriptmodel_current && Distance( scriptModels[e].origin, position ) <= 128)
				snappableModels[snappableModels.size] = scriptModels[e];
		}

		if (isDefined( self.scriptmodel_snapping ) && IsInArray( level.snappable_models, self.scriptmodel_current.model ) && snappableModels.size)
		{
			ClosestModel = ArrayGetClosest( position, snappableModels );
			Index = GetIndexByKey( level.snappable_models, self.scriptmodel_current.model );

			Dimensions = StrTok( level.snappable_dimensions[Index], ";" );
			Dimensions[0] = StringToFloat(Dimensions[0]) * self.scriptmodel_scale;
			Dimensions[1] = StringToFloat(Dimensions[1]) * self.scriptmodel_scale;
			Dimensions[2] = StringToFloat(Dimensions[2]) * self.scriptmodel_scale;
			Dimensions[3] = (GetXModelCenterOffset( level.snappable_models[Index] )[2] * 1.9) * self.scriptmodel_scale; // auto calculates the height

			SnapPoints = [];
			for(i = 0; i < 2; i++)
				SnapPoints[i] = AnglesToForward(ClosestModel.angles) * (Dimensions[0] * ((i % 2) ? -1 : 1));
			for(i = 2; i < 4; i++)
				SnapPoints[i] = AnglesToRight(ClosestModel.angles) * (Dimensions[1] * ((i % 2) ? -1 : 1));

			SnapPoints[4] = AnglesToForward(ClosestModel.angles) * (Dimensions[2] * -1) + AnglesToRight(ClosestModel.angles) * Dimensions[2];
			SnapPoints[5] = AnglesToForward(ClosestModel.angles) * (Dimensions[2] * -1) + AnglesToRight(ClosestModel.angles) * (Dimensions[2] * -1);
			SnapPoints[6] = AnglesToForward(ClosestModel.angles) * Dimensions[2] + AnglesToRight(ClosestModel.angles) * Dimensions[2];
			SnapPoints[7] = AnglesToForward(ClosestModel.angles) * Dimensions[2] + AnglesToRight(ClosestModel.angles) * (Dimensions[2] * -1);

			for(i = 8; i < 10; i++)
				SnapPoints[i] = AnglesToUp(ClosestModel.angles) * (Dimensions[3] * ((i % 2) ? -1 : 1));

			SnapAngles = [];
			for(i = 0; i < 4; i++)
				SnapAngles[i] = ClosestModel.angles;
			for(i = 4; i < 8; i++)
				SnapAngles[i] = CombineAngles(ClosestModel.angles, (0, (i == 4 || i == 7) ? 90 : -90, 0));
			for(i = 8; i < 10; i++)
				SnapAngles[i] = ClosestModel.angles;

			SnapFx = [];
			for(i = 0; i < SnapPoints.size; i++)
			{
				SnapFx[i] = modelSpawner(ClosestModel.origin + SnapPoints[i], "tag_origin");
				SnapFx[i] SetVisibleToPlayer(self);
				SnapFx[i].SnapAngle = SnapAngles[i];
				
				//snapFx[i] clientfield::set("powerup_fx", 4);
			}

			ClosestSnapPoint = ArrayGetClosest(position, SnapFx);

			if(Distance(ClosestSnapPoint.origin, position) <= ((32 * self.scriptmodel_scale) + (10 * self.scriptmodel_scale)))
			{
				self.scriptmodel_current.origin = ClosestSnapPoint.origin;
				self.scriptmodel_current.angles = ClosestSnapPoint.SnapAngle;
				self.scriptmodel_current.Snapped = true;
			}

			if(Distance(ClosestSnapPoint.origin, position) > ((32 * self.scriptmodel_scale) + (10 * self.scriptmodel_scale)) && isDefined(self.scriptmodel_current.Snapped))
			{
				self.scriptmodel_current.origin = position;
				self.scriptmodel_current.Snapped = undefined;
			}
		}
		wait .05;

		if(isDefined(SnapFx))
			SnapFx DeleteAll();
	}
}

PlaceScriptModel()
{
	if(!isDefined( self.scriptmodel_current ))
		return;

	self.scriptmodel_array[self.scriptmodel_array.size] = self.scriptmodel_current;
	self.scriptmodel_current = undefined; 
}

CopyScriptModel()
{
	if(!isDefined( self.scriptmodel_current ))
		return;

	current = self.scriptmodel_current;
	copy = modelSpawner( current.origin, current.model, current.angles, undefined, self.scriptmodel_scale );
	self.scriptmodel_array[self.scriptmodel_array.size] = copy;
}

RotateScriptModel( type, direction )
{
	if(!isDefined( self.scriptmodel_current ))
		return;

	angles = [];
	for(e = 0; e < 3; e++)
		angles[e] = (type == e) ? (self.scriptmodel_current.angles[e] + 5 * direction) : self.scriptmodel_angles[e];
		
	self.scriptmodel_angles = (angles[0], angles[1], angles[2]);
}

ResetScriptModel()
{
	if(!isDefined( self.scriptmodel_current ))
		return;

	self.scriptmodel_angles = (0,0,0);
}

DeleteScriptModel()
{
	if(!isDefined( self.scriptmodel_current ))
		return;

	self.scriptmodel_current delete();
	self.scriptmodel_current = undefined; 
}

DeleteAllSpawnedScriptModels()
{
	if( self.scriptmodel_array.size <= 0 )
		return;

	foreach( model in self.scriptmodel_array )
		model delete();

	self.scriptmodel_array = [];
}

UndoLastScriptModel()
{
	index = self.scriptmodel_array.size - 1;
	self.scriptmodel_array[index] delete();
	self.scriptmodel_array[index] = undefined; 
}

ScriptModelDistance( amount )
{
	self.scriptmodel_distance += amount;
}

scriptModelCollisions()
{
	if(!isDefined( self.scriptmodel_collision ))
		self.scriptmodel_collision = true;
	else 
		self.scriptmodel_collision = undefined;
}

scriptModelSnapping()
{
	if(!isDefined( self.scriptmodel_snapping ))
		self.scriptmodel_snapping = true;
	else 
		self.scriptmodel_snapping = undefined;
}

CopyExpandScriptModel()
{
	Index = GetIndexByKey(level.snappable_models, self.scriptmodel_current.model);
	Dimensions = StrTok(level.snappable_dimensions[Index], ";");

	if (!isDefined(self.scriptmodel_current))
		return;
	if (!ArrayContainsKey(level.snappable_models, self.scriptmodel_current.model))
		return;

    self thread lockMenu("lock", "close");  

	Entity = modelSpawner(self.scriptmodel_current.origin, self.scriptmodel_current.model, self.scriptmodel_current.angles);
	self.scriptmodel_array[self.scriptmodel_array.size] = Entity;
	self.scriptmodel_current Delete();

	SnapFx = [];
	for (i = 0; i < 2; i++)
		SnapFx[i] = modelSpawner(Entity.origin + AnglesToForward(Entity.angles) * (StringToFloat(Dimensions[0]) * ((i % 2) ? -1 : 1)), "tag_origin", (-90, 0, 0));
	for (i = 2; i < 4; i++)
		SnapFx[i] = modelSpawner(Entity.origin + AnglesToRight(Entity.angles) * (StringToFloat(Dimensions[1]) * ((i % 2) ? -1 : 1)), "tag_origin", (-90, 0, 0));
	for (i = 4; i < 6; i++)
		SnapFx[i] = modelSpawner(Entity.origin + AnglesToUp(Entity.angles) * (StringToFloat(Dimensions[3]) * ((i % 2) ? -1 : 1)), "tag_origin", (-90, 0, 0));

	for (i = 0; i < SnapFx.size; i++)
	{
		PlayFxOnTag(level._effect["zapper_light_ready"], SnapFx[i], "tag_origin");
		if (i > 3)
			PlayFxOnTag(level._effect["zapper_light_notready"], SnapFx[i], "tag_origin");
	}
	wait .4;

	ExpandModels = [];
	for (;;)
	{
		ClosestSnapPoint = ArrayGetClosest(self.origin, SnapFx);
		Index = GetIndexByKey(SnapFx, ClosestSnapPoint);

		for(i = 0; i < 6; i++)
		{
			if(index == i)
			{
				Amount = Distance2D(self.origin, Entity.origin) / StringToFloat(Dimensions[ ( (index == 2 || index == 3) ? 1 : 0 ) ]);
				if(index == 4 || index == 5)
					Amount = Distance(self.origin, Entity.origin) / StringToFloat(Dimensions[3]);

				for (e = 0; e < Amount; e++)
				{
					if(index == 0 || index == 1)
						position = (Entity.origin + AnglesToForward(Entity.angles) * (e * StringToFloat(Dimensions[0]) * ((i % 2) ? -1 : 1)));
					if(index == 2 || index == 3)
						position = (Entity.origin + AnglesToRight(Entity.angles) * (e * StringToFloat(Dimensions[1]) * ((i % 2) ? -1 : 1)));
					if(index == 4 || index == 5)
						position = (Entity.origin + AnglesToUp(Entity.angles) * (e * StringToFloat(Dimensions[3]) * ((i % 2) ? -1 : 1)));

					if(!isDefined( ExpandModels[e] ))
                    {
						ExpandModels[e] = modelSpawner(position, Entity.model, Entity.angles);
                        ExpandModels[e] notSolid();
                    }
                    else 
						ExpandModels[e].origin = position;
				}

				foreach(e_index, expanded in ExpandModels)
				{
					if( isDefined(ExpandModels[e_index]) && e_index >= amount )
						ExpandModels[e_index] delete();
				}
			}
		}
		
		if (self UseButtonPressed())
		{
			for (i = 0; i < ExpandModels.size; i++)
            {
                ExpandModels[i] solid();
				self.scriptmodel_array[self.scriptmodel_array.size] = ExpandModels[i];
            }
            break;
		}

		if (self MeleeButtonPressed())
		{
			ExpandModels DeleteAll();
			break;
		}
		wait .05;
	}

	SnapFx DeleteAll();
	self thread SpawnScriptModel(Entity.model);
	self.CurrentEntity.angles = Entity.angles;

    self lockMenu("unlock", "open");
}

BulkScriptModelCenter()
{
	if(!isDefined( self.scriptmodel_bulk ))
		self.scriptmodel_bulk = spawnStruct();
	if(isDefined( self.scriptmodel_bulk.center.fx ))
		self.scriptmodel_bulk.center.fx delete();
	
	self.scriptmodel_bulk.center = spawnStruct();
	self.scriptmodel_bulk.center.origin = self.origin;
	self.scriptmodel_bulk.center.fx = modelSpawner( self.origin, "tag_origin" );
	self.scriptmodel_bulk.center.fx SetVisibleToPlayer( self );
	self.scriptmodel_bulk.center.fx clientfield::set( "powerup_fx", 2 );

	if(isDefined( self.scriptmodel_bulk.preview ))
		self thread BulkScriptModelPreview();
}

BulkScriptModelHeight( edit_value )
{
	if(!isDefined( self.scriptmodel_bulk.center ))
		return self iPrintLnBold( "Error: Define the center origin first.");
	if(isDefined( self.scriptmodel_bulk.height.fx ))
		self.scriptmodel_bulk.height.fx delete();

    position = (self.scriptmodel_bulk.center.origin[0], self.scriptmodel_bulk.center.origin[1], self.origin[2]);
    if(isDefined( self.scriptmodel_bulk.height ) && isDefined( edit_value ))
        position = self.scriptmodel_bulk.height.origin + (0, 0, edit_value);
		
	self.scriptmodel_bulk.height = SpawnStruct();
	self.scriptmodel_bulk.height.origin = position;
	self.scriptmodel_bulk.height.fx = modelSpawner( position, "tag_origin" );
	self.scriptmodel_bulk.height.fx SetVisibleToPlayer(self);
	self.scriptmodel_bulk.height.fx clientfield::set( "powerup_fx", 2 );

	if(isDefined( self.scriptmodel_bulk.preview ))
		self thread BulkScriptModelPreview();
    self refreshMenuToggles();
}

BulkScriptModelRadius( edit_value )
{
	if(!isDefined( self.scriptmodel_bulk.center ))
		return self iPrintLnBold( "Error: Define the center origin first.");
	if(isDefined( self.scriptmodel_bulk.radius.fx ))
		self.scriptmodel_bulk.radius.fx delete();

    position = (self.origin[0], self.origin[1], self.scriptmodel_bulk.center.origin[2]);
    if(isDefined( self.scriptmodel_bulk.radius ) && isDefined( edit_value ))
        position = self.scriptmodel_bulk.radius.origin + (edit_value, edit_value, self.scriptmodel_bulk.radius.origin[2]);

	self.scriptmodel_bulk.radius = spawnStruct();
	self.scriptmodel_bulk.radius.origin = position;
	self.scriptmodel_bulk.radius.fx = modelSpawner( position, "tag_origin" );
	self.scriptmodel_bulk.radius.fx SetVisibleToPlayer( self );
	self.scriptmodel_bulk.radius.fx clientfield::set( "powerup_fx", 2 );

	if(isDefined( self.scriptmodel_bulk.preview ))
		self thread BulkScriptModelPreview();
    self refreshMenuToggles();
}

BulkScriptModelPreview()
{
	if(!isDefined( self.scriptmodel_bulk.center ) || !isDefined( self.scriptmodel_bulk.height ) || !isDefined( self.scriptmodel_bulk.radius ))
		return self iPrintLnBold( "Error: Define the all aspects of the bulk editor first.");
	if(isDefined( self.scriptmodel_bulk.preview.fx ))
		self.scriptmodel_bulk.preview.fx DeleteAll();
	
	self.scriptmodel_bulk.preview = SpawnStruct();
	self.scriptmodel_bulk.preview.fx = [];

	for(i = 0; i < 2; i++)
	{
		for(e = 0; e < 360; e+=20)
		{
			radius = Distance2D(self.scriptmodel_bulk.center.origin, self.scriptmodel_bulk.radius.origin);
			position = self.scriptmodel_bulk.center.origin + (Cos(e) * radius, Sin(e) * radius, ((i) ? 0 : (self.scriptmodel_bulk.height.origin[2] - self.scriptmodel_bulk.center.origin[2])) );
			self.scriptmodel_bulk.preview.fx[self.scriptmodel_bulk.preview.fx.size] = modelSpawner( position, "tag_origin" );
			self.scriptmodel_bulk.preview.fx[self.scriptmodel_bulk.preview.fx.size - 1] SetVisibleToPlayer(self);
			self.scriptmodel_bulk.preview.fx[self.scriptmodel_bulk.preview.fx.size - 1] clientfield::set("powerup_fx", 1 );
		}
	}
}

BulkScriptModelPickup()
{
	if(!isDefined( self.scriptmodel_bulk.center ) || !isDefined( self.scriptmodel_bulk.height ) || !isDefined( self.scriptmodel_bulk.radius ))
		return self iPrintLnBold( "Error: Define the all aspects of the bulk editor first.");
    if(!isDefined( self.scriptmodel_distance ))
        self.scriptmodel_distance = 200;

	entities = getEntArray();
	distance = Distance2D(self.scriptmodel_bulk.center.origin, self.scriptmodel_bulk.radius.origin) + 1;

	selected_ents = [];
	foreach( ent in entities )
	{
		if( (distance2D(ent.origin, self.scriptmodel_bulk.center.origin) <= distance) && ((ent.origin[2] >= self.scriptmodel_bulk.center.origin[2] - 5)) && (ent.origin[2] <= self.scriptmodel_bulk.height.origin[2]) && !isPlayer( ent ))
			selected_ents[selected_ents.size] = ent;
	}

	self.scriptmodel_bulk.anchor = SpawnStruct();
	self.scriptmodel_bulk.anchor.linker = modelSpawner(self.scriptmodel_bulk.center.origin, "tag_origin");
	self.scriptmodel_bulk.anchor.attached = selected_ents;

	foreach( ent in selected_ents )
	{
		ent.old_origin = ent.origin;
		ent.old_angles = ent.angles;
		ent linkTo( self.scriptmodel_bulk.anchor.linker, "tag_origin" );
	}

	self refreshMenuToggles();
	while(isDefined( self.scriptmodel_bulk.anchor.linker ))
	{
		position = ( isDefined( self.scriptmodel_collision ) ? self lookPos( self.scriptmodel_distance ) : self getEye() + anglesToForward( self getPlayerAngles() ) * self.scriptmodel_distance );
		self.scriptmodel_bulk.anchor.linker MoveTo(position, 0.1);
		wait .05;
	}
}

BulkScriptModelDrop()
{
	if(!isDefined( self.scriptmodel_bulk.anchor.linker ))
		return self iPrintLnBold( "Error: Anchor linker not found." );

	self BulkScriptModelDeleteFX();
	self thread BulkScriptModelPreview();
}

BulkScriptModelDelete()
{
	if(!isDefined( self.scriptmodel_bulk.anchor.linker ))
		return self iPrintLnBold( "Error: Anchor linker not found." );

	foreach( ent in self.scriptmodel_bulk.anchor.attached )
		ent delete();

	self BulkScriptModelDeleteFX();
	self thread BulkScriptModelPreview();
}

BulkScriptModelCancel()
{
	if(!isDefined( self.scriptmodel_bulk.anchor.linker ))
		return self iPrintLnBold( "Error: Anchor linker not found." );

	foreach( ent in self.scriptmodel_bulk.anchor.attached )
	{
		ent.origin = ent.old_origin;
		ent.angles = ent.old_angles;
	}

	self BulkScriptModelDeleteFX();
	self thread BulkScriptModelPreview();
}

BulkScriptModelDeleteFX()
{
	if(isDefined( self.scriptmodel_bulk.center.fx ))
		self.scriptmodel_bulk.center.fx delete();
	if(isDefined( self.scriptmodel_bulk.height.fx ))
		self.scriptmodel_bulk.height.fx delete();
	if(isDefined( self.scriptmodel_bulk.radius.fx ))
		self.scriptmodel_bulk.radius.fx delete();
	if(isDefined( self.scriptmodel_bulk.preview.fx ))
		self.scriptmodel_bulk.preview.fx DeleteAll();
	if(isDefined( self.scriptmodel_bulk.anchor.linker ))	
	{
		self.scriptmodel_bulk.anchor.linker delete();
		self.scriptmodel_bulk.anchor = undefined;
	}
	self dynamicOptionFix();
}

BulkScriptModelReset()
{
	self BulkScriptModelDeleteFX();
	self.scriptmodel_bulk.center = undefined;
	self.scriptmodel_bulk.radius = undefined;
	self.scriptmodel_bulk.height = undefined;
	self.scriptmodel_bulk.preview = undefined;
	self.scriptmodel_bulk = undefined;
}

modelScale(val, decrease)
{
    if(!isDefined( self.scriptmodel_scale ))
        self.scriptmodel_scale = 1;
    
    if(IsDefined( decrease )) 
        self.scriptmodel_scale = val;
    else if(isDefined( val )) 
        self.scriptmodel_scale = val;
    else 
        self.scriptmodel_scale = 1;
    
    if(isDefined( self.scriptmodel_current ))
        self.scriptmodel_current SetScale( self.scriptmodel_scale );
    self refreshMenuToggles();
} 
