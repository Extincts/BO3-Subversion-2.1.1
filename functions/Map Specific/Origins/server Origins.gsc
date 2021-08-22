set_captured_zones()
{
    if(level clientfield::get("zone_capture_hud_all_generators_captured"))
        return;
    foreach(generator in struct::get_array("s_generator", "targetname"))
    {
        generator capture_generator( self );
        util::wait_network_frame();
    }
}

capture_generator( player )
{
    level.zone_capture.last_zone_captured = self;
    self set_player_controlled_zone();
    self.n_current_progress = 100;
    level clientfield::set("state_" + self.script_noteworthy, 2);
    level clientfield::set(self.script_noteworthy, self.n_current_progress / 100);
}

set_player_controlled_zone()
{
    if(!self flag::get("player_controlled"))
    {
        foreach(e_player in level.players)
            e_player thread zm_craftables::player_show_craftable_parts_ui(undefined, "zmInventory.capture_generator_wheel_widget", 0);
    }
    self flag::set("player_controlled");
    self flag::clear("attacked_by_recapture_zombies");
    level clientfield::set("zone_capture_hud_generator_" + self.script_int, 1);
    level clientfield::set("zone_capture_monolith_crystal_" + self.script_int, 0);
    if(!isdefined(self.perk_fx_func) || [[self.perk_fx_func]]())
        level clientfield::set("zone_capture_perk_machine_smoke_fx_" + self.script_int, 1);
    self flag::set("player_controlled");
    update_captured_zone_count();
    self enable_perk_machines_in_zone();
    self enable_random_perk_machines_in_zone();
    self enable_mystery_boxes_in_zone();
    level flag::set("power_on" + self.script_int);
    level notify("zone_captured_by_player", self.str_zone);
}

enable_perk_machines_in_zone()
{
    if(isdefined(self.perk_machines) && IsArray(self.perk_machines))
    {
        a_keys = getArrayKeys(self.perk_machines);
        for(i = 0; i < a_keys.size; i++)
        {
            level notify(a_keys[i] + "_on");
        }
        for(i = 0; i < a_keys.size; i++)
        {
            e_perk_trigger = self.perk_machines[a_keys[i]];
            e_perk_trigger.is_locked = 0;
            e_perk_trigger zm_perks::reset_vending_hint_string();
        }
    }
}

enable_random_perk_machines_in_zone()
{
    if(isdefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
    {
        foreach(random_perk_machine in self.perk_machines_random)
        {
            random_perk_machine.is_locked = 0;
            if(isdefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
            {
                random_perk_machine set_perk_random_machine_state("idle");
                continue;
            }
            random_perk_machine set_perk_random_machine_state("away");
        }
    }
}

set_perk_random_machine_state(State)
{
    wait(0.1);
    for(i = 0; i < self GetNumZBarrierPieces(); i++)
    {
        self HideZBarrierPiece(i);
    }
    self notify("zbarrier_state_change");
    self [[level.perk_random_machine_state_func]](State);
}

enable_mystery_boxes_in_zone()
{
    foreach(mystery_box in self.mystery_boxes)
    {
        mystery_box.is_locked = 0;
        mystery_box.zbarrier [[level.magic_box_zbarrier_state_func]]("player_controlled"); 
        mystery_box.zbarrier clientfield::set("magicbox_runes", 1);
    }
}

update_captured_zone_count()
{
    level.total_capture_zones = get_captured_zone_count();
    if(level.total_capture_zones == 6)
        level flag::set("all_zones_captured");
    else
        level flag::clear("all_zones_captured");
}

get_captured_zone_count()
{
    n_player_controlled_zones = 0;
    foreach(generator in level.zone_capture.zones)
    {
        if(generator flag::get("player_controlled"))
            n_player_controlled_zones++;
    }
    return n_player_controlled_zones;
}

pickup_crystal( id )
{
    for(e = 1; e <= 4; e++)
        level notify("player_teleported", self, e);

    foreach(index, s_craftable in level.zombie_include_craftables)
    {
        if(!IsSubStr( index, tolower(id) )) 
            continue;
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            if(isdefined( s_piece.pieceSpawn ) && s_piece.pieceName == "gem")
                self zm_craftables::player_take_piece(s_piece.pieceSpawn);
        }
    }
}
