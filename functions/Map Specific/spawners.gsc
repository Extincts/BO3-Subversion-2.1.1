spawn_margwas( amount, type = "none" )
{
    for(e=0;e<int(amount);e++)
    {
        if(getMapName() == "Revelations")
        {
            level.var_b32a2aa0 = 0;
            level.var_ba0d6d40 = level.round_number;
            level notify("between_round_over");   
        }
        else 
        {
            s_location = self.origin;
            level.var_b398aafa[0].script_forcespawn = 1;
            ai = zombie_utility::spawn_zombie(level.var_b398aafa[0], "margwa", s_location);
            ai DisableAimAssist();
            ai.actor_damage_func = ai.overrideActorDamage;
            ai.canDamage = 0;
            ai.targetname = "margwa";
            ai.holdFire = 1;
            e_player = zm_utility::get_closest_player(s_location.origin);
            v_dir = e_player.origin - s_location.origin;
            v_dir = VectorNormalize(v_dir);
            v_angles = VectorToAngles(v_dir);
            ai ForceTeleport(s_location.origin, v_angles);
            if(isdefined(level.var_7cef68dc))
                ai thread function_8d578a58();
            ai.ignore_round_robbin_death = 1;
            ai thread function_3d56f587();
            if(toLower( type ) == "super" || math::cointoss())
                ai clientfield::set("supermargwa", 1);
        }
        wait .05;
    }
}

spawn_mechz(amount)
{
    for(e=0;e<int(amount);e++)
    {
        if(getMapName() == "Revelations")
        {
            level.var_b32a2aa0 = 1; //0 - margwa : 1 - panzer
            level.var_ba0d6d40 = level.round_number;
            level notify("between_round_over");  
        }
        else if(getMapName() == "Origins")
        {
            level notify("spawn_mechz");
            level.mechz_left_to_spawn++;
        }
        else 
        {
            level.var_b20dd348 = level.round_number;
            level notify("between_round_over");  
            level notify("start_of_round");
        }
        wait 2;
    }
}

function_8d578a58()
{
    self waittill("death", attacker, mod, weapon);
    foreach(player in level.players)
    {
        if(player.am_i_valid && (!isdefined(level.var_1f6ca9c8) && level.var_1f6ca9c8) && (!isdefined(self.var_2d5d7413) && self.var_2d5d7413))
        {
            scoreevents::processScoreEvent("kill_margwa", player, undefined, undefined);
        }
    }
    level notify(#"hash_1a2d33d7");
    [[level.var_7cef68dc]]();
}

function_3d56f587()
{
    util::wait_network_frame();
    self clientfield::increment("margwa_fx_spawn");
    wait(3);
    self function_26c35525();
    self.canDamage = 1;
    self.needSpawn = 1;
}

function_26c35525()
{
    self.isFrozen = 0;
    self show();
    self solid();
    self PathMode("move allowed");
}

spawn_raps( amount )
{
    level thread special_raps_spawn( amount, self.origin );
}

special_raps_spawn(n_to_spawn = 1, s_spawn_loc)
{
    raps = GetEntArray("zombie_raps", "targetname");
    if(isdefined(raps) && raps.size >= 9)
        return 0;

    count = 0;
    while(count < n_to_spawn)
    {
        players = GetPlayers();
        favorite_enemy = get_favorite_enemy();
        if(!isdefined(favorite_enemy))
        {
            wait(RandomFloatRange(0.6666666, 1.333333));
            continue;
        }

        s_spawn_loc = calculate_spawn_position(favorite_enemy);
        if(!isdefined(s_spawn_loc))
        {
            wait(RandomFloatRange(0.6666666, 1.333333));
            continue;
        }
        ai = zombie_utility::spawn_zombie(level.raps_spawners[0]);
        if(isdefined(ai))
        {
            ai.favoriteenemy = favorite_enemy;
            ai.favoriteenemy.hunted_by++;
            s_spawn_loc thread raps_spawn_fx(ai, s_spawn_loc);
            count++;
        }
        wait 1.25;
    }
    return 1;
}

raps_spawn_fx(ai, ent)
{
    ai endon("death");
    if(!isdefined(ent))
    {
        ent = self;
    }
    ai vehicle_ai::set_state("scripted");
    trace = bullettrace(ent.origin, ent.origin + VectorScale((0, 0, -1), 720), 0, ai);
    raps_impact_location = trace["position"];
    angle = VectorToAngles(ai.favoriteenemy.origin - ent.origin);
    angles = (ai.angles[0], angle[1], ai.angles[2]);
    ai.origin = raps_impact_location;
    ai.angles = angles;
    ai Hide();
    pos = raps_impact_location + VectorScale((0, 0, 1), 720);
    if(!BulletTracePassed(ent.origin, pos, 0, ai))
    {
        trace = bullettrace(ent.origin, pos, 0, ai);
        pos = trace["position"];
    }
    portal_fx_location = spawn("script_model", pos);
    portal_fx_location SetModel("tag_origin");
    PlayFXOnTag(level._effect["raps_portal"], portal_fx_location, "tag_origin");
    ground_tell_location = spawn("script_model", raps_impact_location);
    ground_tell_location SetModel("tag_origin");
    PlayFXOnTag(level._effect["raps_ground_spawn"], ground_tell_location, "tag_origin");
    ground_tell_location playsound("zmb_meatball_spawn_tell");
    playsoundatposition("zmb_meatball_spawn_rise", pos);
    ai thread cleanup_meteor_fx(portal_fx_location, ground_tell_location);
    wait(0.5);
    raps_meteor = spawn("script_model", pos);
    model = ai.model;
    raps_meteor SetModel(model);
    raps_meteor.angles = angles;
    raps_meteor PlayLoopSound("zmb_meatball_spawn_loop", 0.25);
    PlayFXOnTag(level._effect["raps_meteor_fire"], raps_meteor, "tag_origin");
    fall_dist = sqrt(DistanceSquared(pos, raps_impact_location));
    fall_time = fall_dist / 720;
    raps_meteor moveto(raps_impact_location, fall_time);
    raps_meteor.ai = ai;
    raps_meteor thread cleanup_meteor();
    wait(fall_time);
    raps_meteor delete();
    if(isdefined(portal_fx_location))
    {
        portal_fx_location delete();
    }
    if(isdefined(ground_tell_location))
    {
        ground_tell_location delete();
    }
    ai vehicle_ai::set_state("combat");
    ai.origin = raps_impact_location;
    ai.angles = angles;
    ai show();
    playFX(level._effect["raps_impact"], raps_impact_location);
    playsoundatposition("zmb_meatball_spawn_impact", raps_impact_location);
    Earthquake(0.3, 0.75, raps_impact_location, 512);
    ai zombie_setup_attack_properties_raps();
    ai SetVisibleToAll();
    ai.ignoreme = 0;
    ai notify("visible");
}

cleanup_meteor()
{
    self endon("death");
    self.ai waittill("death");
    self delete();
}

cleanup_meteor_fx(portal_fx, ground_tell)
{
    self waittill("death");
    if(isdefined(portal_fx))
    {
        portal_fx delete();
    }
    if(isdefined(ground_tell))
    {
        ground_tell delete();
    }
}

zombie_setup_attack_properties_raps()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    self.ignoreall = 0;
    self.meleeAttackDist = 64;
    self.disableArrivals = 1;
    self.disableExits = 1;
}

get_favorite_enemy()
{
    raps_targets = GetPlayers();
    e_least_hunted = undefined;
    for(i = 0; i < raps_targets.size; i++)
    {
        e_target = raps_targets[i];
        if(!isdefined(e_target.hunted_by))
        {
            e_target.hunted_by = 0;
        }
        if(!zm_utility::is_player_valid(e_target))
        {
            continue;
        }
        if(isdefined(level.is_player_accessible_to_raps) && ![[level.is_player_accessible_to_raps]](e_target))
        {
            continue;
        }
        if(!isdefined(e_least_hunted))
        {
            e_least_hunted = e_target;
            continue;
        }
        if(e_target.hunted_by < e_least_hunted.hunted_by)
        {
            e_least_hunted = e_target;
        }
    }
    return e_least_hunted;
}

calculate_spawn_position(favorite_enemy)
{
    position = favorite_enemy.last_valid_position;
    if(!isdefined(position))
    {
        position = favorite_enemy.origin;
    }
    if(level.players.size == 1)
    {
        N_RAPS_SPAWN_DIST_MIN = 450;
        N_RAPS_SPAWN_DIST_MAX = 900;
    }
    else if(level.players.size == 2)
    {
        N_RAPS_SPAWN_DIST_MIN = 450;
        N_RAPS_SPAWN_DIST_MAX = 850;
    }
    else if(level.players.size == 3)
    {
        N_RAPS_SPAWN_DIST_MIN = 700;
        N_RAPS_SPAWN_DIST_MAX = 1000;
    }
    else
    {
        N_RAPS_SPAWN_DIST_MIN = 800;
        N_RAPS_SPAWN_DIST_MAX = 1200;
    }
    query_result = PositionQuery_Source_Navigation(position, N_RAPS_SPAWN_DIST_MIN, N_RAPS_SPAWN_DIST_MAX, 200, 32, 16);
    if(query_result.data.size)
    {
        a_s_locs = Array::randomize(query_result.data);
        if(isdefined(a_s_locs))
        {
            foreach(s_loc in a_s_locs)
            {
                if(zm_utility::check_point_in_enabled_zone(s_loc.origin, 1, level.active_zones))
                {
                    s_loc.origin = s_loc.origin + VectorScale((0, 0, 1), 16);
                    return s_loc;
                }
            }
        }
    }
    return undefined;
}

/* SPAWN DOGS */
special_dog_spawn(num_to_spawn, spawners)
{
    dogs = GetAISpeciesArray("all", "zombie_dog");
    count = 0;
    while(count < num_to_spawn)
    {
        players = GetPlayers();
        favorite_enemy = get_favorite_enemy();
        if(isdefined(spawners))
        {
            if(!isdefined(spawn_point))
                spawn_point = spawners[RandomInt(spawners.size)];
            ai = zombie_utility::spawn_zombie(spawn_point);
            if(isdefined(ai))
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_point thread dog_spawn_fx(ai);
                count++;
                level flag::set("dog_clips");
            }
        }
        else if(isdefined(level.dog_spawn_func))
        {
            spawn_loc = [[level.dog_spawn_func]](level.dog_spawners, favorite_enemy);
            ai = zombie_utility::spawn_zombie(level.dog_spawners[0]);
            if(isdefined(ai))
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_loc thread dog_spawn_fx(ai, spawn_loc);
                count++;
                level flag::set("dog_clips");
            }
        }
        else
        {
            spawn_point = dog_spawn_factory_logic(favorite_enemy);
            ai = zombie_utility::spawn_zombie(level.dog_spawners[0]);
            if(isdefined(ai))
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_point thread dog_spawn_fx(ai, spawn_point);
                count++;
                level flag::set("dog_clips");
            }
        }
        wait .2;
    }
    return 1;
}

dog_spawn_fx(ai, ent)
{
    ai endon("death");
    ai SetFreeCameraLockOnAllowed(0);
    playFX(level._effect["lightning_dog_spawn"], ent.origin);
    playsoundatposition("zmb_hellhound_prespawn", ent.origin);
    wait(1.5);
    playsoundatposition("zmb_hellhound_bolt", ent.origin);
    Earthquake(0.5, 0.75, ent.origin, 1000);
    playsoundatposition("zmb_hellhound_spawn", ent.origin);
    if(isdefined(ai.favoriteenemy))
    {
        angle = VectorToAngles(ai.favoriteenemy.origin - ent.origin);
        angles = (ai.angles[0], angle[1], ai.angles[2]);
    }
    else
    {
        angles = ent.angles;
    }
    ai ForceTeleport(ent.origin, angles);
    ai zombie_setup_attack_properties_dog();
    ai util::stop_magic_bullet_shield();
    wait(0.1);
    ai show();
    ai SetFreeCameraLockOnAllowed(1);
    ai.ignoreme = 0;
    ai notify("visible");
}

dog_spawn_factory_logic(favorite_enemy)
{
    dog_locs = Array::randomize(level.zm_loc_types["dog_location"]);
    for(i = 0; i < dog_locs.size; i++)
    {
        if(isdefined(level.old_dog_spawn) && level.old_dog_spawn == dog_locs[i])
            continue;
        if(!isdefined(favorite_enemy))
            continue;
        dist_squared = DistanceSquared(dog_locs[i].origin, favorite_enemy.origin);
        if(dist_squared > 160000 && dist_squared < 1000000)
        {
            level.old_dog_spawn = dog_locs[i];
            return dog_locs[i];
        }
    }
    return dog_locs[0];
}

zombie_setup_attack_properties_dog()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    //self thread dog_behind_audio();
    self.ignoreall = 0;
    self.meleeAttackDist = 64;
    self.disableArrivals = 1;
    self.disableExits = 1;
    if(isdefined(level.dog_setup_func))
        self [[level.dog_setup_func]]();
}

/* Spawn Sentinel Drone */
special_sentinel_spawn(num_to_spawn)
{
    count = 0;
    while(count < num_to_spawn)
    {
        var_c94972aa = 0;
        s_spawn_loc = undefined;
        if(isdefined(level.var_2babfade))
            s_spawn_loc = [[level.var_2babfade]]();
        else
            s_spawn_loc = Array::random(level.zm_loc_types["sentinel_location"]);
        if(!isdefined(s_spawn_loc))
        {
            wait(RandomFloatRange(0.3333333, 0.6666667));
            return;
        }
        ai = function_fded8158(level.var_fda4b3f3[0]);
        if(isdefined(ai))
        {
            ai.nuke_damage_func = ::function_306f9403;
            ai.instakill_func = ::function_306f9403;
            ai.s_spawn_loc = s_spawn_loc;
            ai thread function_b27530eb(s_spawn_loc.origin);
            if(var_c94972aa)
            {
                ai.var_c94972aa = 1;
                ai.var_580a32ea = 6;
            }
            level.zombie_total--;
            count++;
        }
        wait .2;
    }
}

function_fded8158(spawner, s_spot)
{
    var_663b2442 = zombie_utility::spawn_zombie(level.var_fda4b3f3[0], "sentinel", s_spot);
    if(isdefined(var_663b2442))
    {
        var_663b2442.check_point_in_enabled_zone = zm_utility::check_point_in_playable_area;
    }
    return var_663b2442;
}

function_306f9403(player, mod, HIT_LOCATION)
{
    return 1;
}

function_b27530eb(v_pos)
{
    self endon("death");
    self vehicle::toggle_sounds(0);
    var_92968756 = v_pos + VectorScale((0, 0, 1), 30);
    self.origin = v_pos + VectorScale((0, 0, 1), 5000);
    self.angles = (0, randomIntRange(0, 360), 0);
    e_origin = spawn("script_origin", self.origin);
    e_origin.angles = self.angles;
    self LinkTo(e_origin);
    e_origin moveto(var_92968756, 3);
    e_origin playsound("zmb_sentinel_intro_spawn");
    wait 3;
    e_origin playsound("zmb_sentinel_intro_land");
    self clientfield::set("sentinel_spawn_fx", 1);
    wait(3);
    self clientfield::set("sentinel_spawn_fx", 0);
    wait(1);
    self vehicle::toggle_sounds(1);
    self.origin = var_92968756;
    self Unlink();
    e_origin delete();
    self flag::set("completed_spawning");
    wait(0.2);
}

/* Spawn Wasp */
special_wasp_spawn(n_to_spawn, spawn_point, n_radius, n_half_height, b_non_round, spawn_fx, b_return_ai, spawner_override)
{
    if(!isdefined(n_to_spawn))
        n_to_spawn = 1;
    if(!isdefined(n_radius))
        n_radius = 32;
    if(!isdefined(n_half_height))
        n_half_height = 32;
    if(!isdefined(spawn_fx))
        spawn_fx = 1;
    if(!isdefined(b_return_ai))
        b_return_ai = 0;
    if(!isdefined(spawner_override))
        spawner_override = undefined;
    wasp = GetEntArray("zombie_wasp", "targetname");
    if(isdefined(wasp) && wasp.size >= 9)
        return 0;
    count = 0;
    while(count < n_to_spawn)
    {
        players = GetPlayers();
        favorite_enemy = get_favorite_enemy();
        spawn_enemy = favorite_enemy;
        if(!isdefined(spawn_enemy))
            spawn_enemy = players[0];
        if(isdefined(level.wasp_spawn_func))
            spawn_point = [[level.wasp_spawn_func]](spawn_enemy);
        while(!isdefined(spawn_point))
        {
            if(!isdefined(spawn_point))
                spawn_point = wasp_spawn_logic(spawn_enemy);
            if(isdefined(spawn_point))
                break;
            wait(0.05);
        }
        spawner = level.wasp_spawners[0];
        if(isdefined(spawner_override))
            spawner = spawner_override;
        ai = zombie_utility::spawn_zombie(spawner);
        v_spawn_origin = spawn_point.origin;
        if(isdefined(ai))
        {
            queryResult = PositionQuery_Source_Navigation(v_spawn_origin, 0, n_radius, n_half_height, 15, "navvolume_small");
            if(queryResult.data.size)
            {
                point = queryResult.data[RandomInt(queryResult.data.size)];
                v_spawn_origin = point.origin;
            }
            ai set_parasite_enemy(favorite_enemy);
            ai.does_not_count_to_round = b_non_round;
            level thread wasp_spawn_init(ai, v_spawn_origin, spawn_fx);
            count++;
        }
        wait(level.zombie_vars["zombie_spawn_delay"]);
    }
    if(b_return_ai)
        return ai;
    return 1;
}

wasp_spawn_init(ai, origin, should_spawn_fx)
{
    if(!isdefined(should_spawn_fx))
        should_spawn_fx = 1;
    ai endon("death");
    ai SetInvisibleToAll();

    if(isdefined(origin))
        v_origin = origin;
    else
        v_origin = ai.origin;

    if(should_spawn_fx)
        playFX(level._effect["lightning_wasp_spawn"], v_origin);
    wait(1.5);
    Earthquake(0.3, 0.5, v_origin, 256);
    if(isdefined(ai.favoriteenemy))
        angle = VectorToAngles(ai.favoriteenemy.origin - v_origin);
    else
        angle = ai.angles;

    angles = (ai.angles[0], angle[1], ai.angles[2]);
    ai.origin = v_origin;
    ai.angles = angles;

    ai thread zombie_setup_attack_properties_wasp();
    if(isdefined(level._wasp_death_cb))
        ai callback::add_callback("hash_acb66515", level._wasp_death_cb);
    ai SetVisibleToAll();
    ai.ignoreme = 0;
    ai notify("visible");
}

zombie_setup_attack_properties_wasp()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    self thread wasp_behind_audio();
    self.ignoreall = 0;
    self.meleeAttackDist = 64;
    self.disableArrivals = 1;
    self.disableExits = 1;
    if(level.wasp_round_count == 2)
        self ai::set_behavior_attribute("firing_rate", "medium");
    else if(level.wasp_round_count > 2)
        self ai::set_behavior_attribute("firing_rate", "fast");
}

wasp_behind_audio()
{
    self thread stop_wasp_sound_on_death();
    self endon("death");
    self util::waittill_any("wasp_running", "wasp_combat");
    wait(3);
    while(1)
    {
        players = GetPlayers();
        for(i = 0; i < players.size; i++)
        {
            waspAngle = AngleClamp180(VectorToAngles(self.origin - players[i].origin)[1] - players[i].angles[1]);
            if(isalive(players[i]) && !isdefined(players[i].reviveTrigger))
            {
                if(Abs(waspAngle) > 90 && Distance2D(self.origin, players[i].origin) > 100)
                    wait(3);
            }
        }
        wait(0.75);
    }
}

stop_wasp_sound_on_death()
{
    self waittill("death");
    self stopsounds();
}

set_parasite_enemy(enemy)
{
    if(!is_target_valid(enemy))
        return;
    if(isdefined(self.parasiteEnemy))
    {
        if(!isdefined(self.parasiteEnemy.hunted_by))
            self.parasiteEnemy.hunted_by = 0;
        if(self.parasiteEnemy.hunted_by > 0)
            self.parasiteEnemy.hunted_by--;
    }
    self.parasiteEnemy = enemy;
    if(!isdefined(self.parasiteEnemy.hunted_by))
        self.parasiteEnemy.hunted_by = 0;
    self.parasiteEnemy.hunted_by++;
    self SetLookAtEnt(self.parasiteEnemy);
    self SetTurretTargetEnt(self.parasiteEnemy);
}

is_target_valid(target)
{
    if(!isdefined(target))
        return 0;
    if(!isalive(target))
        return 0;
    if(isPlayer(target) && target.sessionstate == "spectator")
        return 0;
    if(isPlayer(target) && target.sessionstate == "intermission")
        return 0;
    if(isdefined(target.ignoreme) && target.ignoreme)
        return 0;
    if(target IsNoTarget())
        return 0;
    if(isdefined(self.is_target_valid_cb))
        return self [[self.is_target_valid_cb]](target);
    return 1;
}

wasp_spawn_logic(favorite_enemy)
{
    spawn_dist_max = 1200;
    queryResult = PositionQuery_Source_Navigation(favorite_enemy.origin + (0, 0, randomIntRange(40, 100)), 300, spawn_dist_max, 10, 10, "navvolume_small");
    a_points = Array::randomize(queryResult.data);
    foreach(point in a_points)
    {
        if(BulletTracePassed(point.origin, favorite_enemy.origin, 0, favorite_enemy))
        {
            level.old_wasp_spawn = point;
            return point;
        }
    }
    return a_points[0];
}

/* SPAWN MANGLERS */
special_mangler_spawn( num_to_spawn )
{
    count = 0;
    while(count < num_to_spawn)
    {
        s_spawn_loc = undefined;
        var_19764360 = get_favorite_enemy();
        if(!isdefined(var_19764360))
        {
            wait(RandomFloatRange(0.3333333, 0.6666667));
            return;
        }
        if(isdefined(level.var_e80c1065))
            s_spawn_loc = [[level.var_e80c1065]](var_19764360);
        else
            s_spawn_loc = Array::random(level.zm_loc_types["raz_location"]);

        if(!isdefined(s_spawn_loc))
        {
            wait(RandomFloatRange(0.3333333, 0.6666667));
            return;
        }
        ai = function_665a13cd(level.var_6bca5baa[0]);
        if(isdefined(ai))
        {
            ai thread function_b8671cc0(s_spawn_loc);
            ai ForceTeleport(s_spawn_loc.origin, s_spawn_loc.angles);
            if(isdefined(var_19764360))
            {
                ai.favoriteenemy = var_19764360;
                ai.favoriteenemy.hunted_by++;
            }
            level.zombie_total--;
            count++;
            wait .2;
        }
        wait .05;
    }
}

function_665a13cd(spawner, s_spot)
{
    var_a09c80cd = zombie_utility::spawn_zombie(level.var_6bca5baa[0], "raz", s_spot);
    if(isdefined(var_a09c80cd))
    {
        var_a09c80cd.check_point_in_enabled_zone = zm_utility::check_point_in_playable_area;
        var_a09c80cd thread zombie_utility::round_spawn_failsafe();
        var_a09c80cd thread function_b8671cc0(s_spot);
    }
    return var_a09c80cd;
}

function_b8671cc0(s_spot)
{
    if(isdefined(level.var_71ab2462))
        self thread [[level.var_71ab2462]](s_spot);
    if(isdefined(level.var_ae95a175))
        self thread [[level.var_ae95a175]]();
}