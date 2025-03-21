--[[

  ▄████▄   ▒█████   ████▄ ▄███▓
 ▒██▀ ▀█  ▒██▒  ██▒▓██▒▀█▀ ██▒
 ▒▓█    ▄ ▒██░  ██▒▓██    ▓██░
 ▒▓▓▄ ▄██▒▒██   ██░▒██    ▒██ 
 ▒ ▓███▀ ░░ ████▓▒░▒██▒   ░██▒
 ░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒░   ░  ░
   ░  ▒     ░ ▒ ▒░ ░  ░      ░
 ░        ░ ░ ░ ▒  ░      ░   
 ░ ░          ░ ░         ░   
 ░                             

     C S N   //   WTF.LUA
     Created in fire. Runs on regret.
     If you're trying to understand this – you're already lost.

--]]

local clones = {}
local spawnedAnimals = {}
local spawnedPeds = {}
local target_clone = nil 
local animals = nil 
local peds = nil 
local anm_x, anm_y, anm_z = nil
local a = "script_shows@fireperformer@act1_p1"
local b = "action_performer"
local TextTick = nil 


local function drawText(text, r, g, b, a, scaleX, scaleY, posX, posY)
    natives.uidebug_bgSetTextScale(scaleX, scaleY)
    natives.uidebug_bgSetTextColor(r, g, b, a)
    natives.uidebug_bgDisplayText(tostring(text), posX, posY)
end

	

local misc = menu.addSubmenu('self', '~t3~Misc', '')

local function playAnimation(ped, animDict, animName, speed, speedMultiplier, duration, flags, playbackRate, p8, p9, p10, taskFilter, p12)
  if not natives.streaming_hasAnimDictLoaded(animDict) then
      natives.streaming_requestAnimDict(animDict)
      while not natives.streaming_hasAnimDictLoaded(animDict) do
          system.yield(0)
      end
  end

  if useCustomFlagsType1 then
      flags = 29 
  end

    if useCustomFlagsType2 then
      flags = 17
      p9 = -1 
  end
  
  natives.task_taskPlayAnim(ped, animDict, animName, speed, speedMultiplier, duration, flags, playbackRate, p8, p9, p10, taskFilter, p12)
end

local function config_peds(entity) 
  natives.ped_setPedKeepTask(entity, true)
  natives.entity_setEntityInvincible(entity, true)
  natives.ped_setPedConfigFlag(entity, 61, true)
  natives.ped_setPedCanBeLassoed(entity, false)
  natives.ped_setPedCanBeTargetted(entity, false)
  natives.ped_setPedCanRagdoll(entity, false)
  natives.ped_setBlockingOfNonTemporaryEvents(entity, true)
  natives.ped_setPedFleeAttributes(entity, 0, false)
  natives.ped_setPedCombatAttributes(entity, 17, true)
  natives.ped_setPedLassoHogtieFlag(entity, 0, false)
end

local function setFollow(pet, playerPed)
    if pet and playerPed then
        natives.task_taskFollowToOffsetOfEntity(
            pet,             
            playerPed,        
            0.0,              
            -2.0,             
            0.0,              
            2.0,             
            999999,           
            1.0,              
            true,           
            false,            
            false,           
            false,            
            false,            
            false             
        )
    end
end

menu.addToggleButton(misc, '::THE LEADER::', 'YUH', false, function(toggle, idx)
    local PlayerPed = player.getLocalPed()
    local x, y, z = natives.entity_getEntityCoords(PlayerPed, true, true)
    local target = player.getPed(idx)
    if toggle then
        if natives.entity_doesEntityExist(target_clone) or natives.entity_doesEntityExist(animals) or natives.entity_doesEntityExist(peds) then notifications.alertDanger('ERROS:', 'Cannot do this action at the moment, please delete any spawned in entites you have first.') return end  
        for i = 1, 5 do
            animals = spawner.spawnPed(0x69A37A7B, x+1.2, y+1.0, z, true);config_peds(animals);natives.ped_setPedScale(animals, 1.0)
            peds = spawner.spawnPed(0x99372227, x+1.2, y+1.0, z, true)
            target_clone = natives.ped_clonePed(target, true, true, true);table.insert(clones, target_clone)-- Create the clone, and put it in the list
            local miniPeds = spawner.spawnPed(0xD0C13881, x+0.0, y+0.0, z+0.0, true);natives.ped_setPedScale(miniPeds, 0.3);config_peds(miniPeds)
            if natives.entity_doesEntityExist(target_clone) then config_peds(target_clone) ; natives.entity_attachEntityToEntity(target_clone, peds, "SKEL_Neck1", 0.0, -0.40, 0+0.45, 0, 0, 0.0, true, false, true, true, true, true, 1, true) end
            if natives.entity_doesEntityExist(peds) then config_peds(peds) ; table.insert(spawnedPeds, peds) ; natives.ped_setPedOntoMount(peds, animals, -1, true) else notifications.alertInfo('Spawner', 'could not set the peds on mount') end
            natives.weapon_giveWeaponToPed(peds, 0x7A8A724A, 0, true, false, "SET_CURRENT_PED_WEAPON", true, 0, 0, "_ADD_AMMO_TO_PED", true, 0, 0)
            if natives.entity_doesEntityExist(animals) then table.insert(spawnedAnimals, animals) ; anm_x, anm_y, anm_z = natives.entity_getEntityCoords(animals, true, true) ;natives.graphics_useParticleFxAsset('anm_fire');natives.graphics_startNetworkedParticleFxNonLoopedAtCoord('ent_anim_exp_grd_lantern', anm_x, anm_y, anm_z, 0.0, 0.0, 0.0, 1.0, false, false, false)  else notifications.alertInfo('Spawner', 'could not spawn the animals') end
            if natives.entity_doesEntityExist(miniPeds) then table.insert(spawnedPeds, miniPeds) end
            if natives.invoke(0xB980061DA992779D, 'bool', target_clone) then 
                if natives.invoke(0x6D9F5FAA7488BA46, 'bool', target_clone) then 
                    natives.entity_attachEntityToEntity(miniPeds, target_clone, 249, 0.0, 0.0, 0.0,    0, 0, 0.0, true, false, true, true, true, true, 1, true)
                elseif not natives.invoke(0x6D9F5FAA7488BA46, 'bool', target_clone) then 
                    natives.entity_attachEntityToEntity(miniPeds, target_clone, 320, 0.0, 0.0, 0.0,    0, 0, 0.0, true, false, true, true, true, true, 1, true)
                end
            else
                notifications.alertDanger("Target", "target isn't human.")
            end
            playAnimation(target_clone, a, b, -4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            playAnimation(target_clone,   "script_gfh@joe@scenarios@prop_human_seat_chair_table@clean_rifle_smoke@joe@idle_b", "idle_d", -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false)
            --mini peds 
            playAnimation(miniPeds, "amb_creature_mammal@world_cat_eating@idle", "idle_a", -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false)
            playAnimation(miniPeds, a, b, -4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            --, -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false) ::: ,-4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            setFollow(animals, PlayerPed)
        end
        TextTick = system.registerTick(function(frame)
            drawText("CSN :: THE LEADER", 255, 255, 255, 255, 1.0, 1.0, 0.0, 0.0)
        end)        
    else 
        system.yield(200)
        natives.graphics_useParticleFxAsset('anm_fire');natives.graphics_startNetworkedParticleFxNonLoopedAtCoord('ent_anim_exp_grd_lantern', anm_x, anm_y, anm_z, 0.0, 0.0, 0.0, 1.0, false, false, false)
        for _, clone in ipairs(clones) do
            spawner.deletePed(clone)
        end
        clones = {}
        for _, animal in ipairs(spawnedAnimals) do 
            spawner.deletePed(animal)
        end
        spawnedAnimals = {}
        for _, ped in ipairs(spawnedPeds) do 
            spawner.deletePed(ped)
        end
        spawnedPeds = {}
        system.unregisterTick(TextTick)
        TextTick = nil
    end
end)

--- at player section
--- 
---     if natives.invoke(0xB980061DA992779D, 'bool', TARGET_PED_FLOWER) then -- IS_PED_HUMAN
--if natives.invoke(0x6D9F5FAA7488BA46, 'bool', TARGET_PED_FLOWER) then -- IS_PED_MALE

menu.addToggleButton('player', '::THE LEADER::', 'YUH', false, function(toggle, idx)
    local PlayerPed = player.getLocalPed()
    local x, y, z = natives.entity_getEntityCoords(PlayerPed, true, true)
    local target = player.getPed(idx)
    if toggle then
        if natives.entity_doesEntityExist(target_clone) or natives.entity_doesEntityExist(animals) or natives.entity_doesEntityExist(peds) then notifications.alertDanger('ERROS:', 'Cannot do this action at the moment, please delete any spawned in entites you have first.') return end  
        for i = 1, 5 do
            animals = spawner.spawnPed(0x69A37A7B, x+1.2, y+1.0, z, true);config_peds(animals);natives.ped_setPedScale(animals, 1.0)
            peds = spawner.spawnPed(0x99372227, x+1.2, y+1.0, z, true)
            target_clone = natives.ped_clonePed(target, true, true, true);table.insert(clones, target_clone)-- Create the clone, and put it in the list
            local miniPeds = spawner.spawnPed(0xD0C13881, x+0.0, y+0.0, z+0.0, true);natives.ped_setPedScale(miniPeds, 0.3);config_peds(miniPeds)
            if natives.entity_doesEntityExist(target_clone) then config_peds(target_clone) ; natives.entity_attachEntityToEntity(target_clone, peds, "SKEL_Neck1", 0.0, -0.40, 0+0.45, 0, 0, 0.0, true, false, true, true, true, true, 1, true) end
            if natives.entity_doesEntityExist(peds) then config_peds(peds) ; table.insert(spawnedPeds, peds) ; natives.ped_setPedOntoMount(peds, animals, -1, true) else notifications.alertInfo('Spawner', 'could not set the peds on mount') end
            natives.weapon_giveWeaponToPed(peds, 0x7A8A724A, 0, true, false, "SET_CURRENT_PED_WEAPON", true, 0, 0, "_ADD_AMMO_TO_PED", true, 0, 0)
            if natives.entity_doesEntityExist(animals) then table.insert(spawnedAnimals, animals) ; anm_x, anm_y, anm_z = natives.entity_getEntityCoords(animals, true, true) ;natives.graphics_useParticleFxAsset('anm_fire');natives.graphics_startNetworkedParticleFxNonLoopedAtCoord('ent_anim_exp_grd_lantern', anm_x, anm_y, anm_z, 0.0, 0.0, 0.0, 1.0, false, false, false)  else notifications.alertInfo('Spawner', 'could not spawn the animals') end
            if natives.entity_doesEntityExist(miniPeds) then table.insert(spawnedPeds, miniPeds) end
            if natives.invoke(0xB980061DA992779D, 'bool', target_clone) then 
                if natives.invoke(0x6D9F5FAA7488BA46, 'bool', target_clone) then 
                    natives.entity_attachEntityToEntity(miniPeds, target_clone, 249, 0.0, 0.0, 0.0,    0, 0, 0.0, true, false, true, true, true, true, 1, true)
                elseif not natives.invoke(0x6D9F5FAA7488BA46, 'bool', target_clone) then 
                    natives.entity_attachEntityToEntity(miniPeds, target_clone, 320, 0.0, 0.0, 0.0,    0, 0, 0.0, true, false, true, true, true, true, 1, true)
                end
            else
                notifications.alertDanger("Target", "target isn't human.")
            end
            playAnimation(target_clone, a, b, -4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            playAnimation(target_clone,   "script_gfh@joe@scenarios@prop_human_seat_chair_table@clean_rifle_smoke@joe@idle_b", "idle_d", -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false)
            --mini peds 
            playAnimation(miniPeds, "amb_creature_mammal@world_cat_eating@idle", "idle_a", -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false)
            playAnimation(miniPeds, a, b, -4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            --, -1.5, -8.0, -1, 1, 180.0, false, 0, false, "", false) ::: ,-4.5, -8.0, -1, 17, 0.0, false, -1, false, "", false)
            setFollow(animals, PlayerPed)
        end
        TextTick = system.registerTick(function(frame)
            drawText("CSN :: THE LEADER", 255, 255, 255, 255, 1.0, 1.0, 0.0, 0.0)
        end)        
    else 
        system.yield(200)
        natives.graphics_useParticleFxAsset('anm_fire');natives.graphics_startNetworkedParticleFxNonLoopedAtCoord('ent_anim_exp_grd_lantern', anm_x, anm_y, anm_z, 0.0, 0.0, 0.0, 1.0, false, false, false)
        for _, clone in ipairs(clones) do
            spawner.deletePed(clone)
        end
        clones = {}
        for _, animal in ipairs(spawnedAnimals) do 
            spawner.deletePed(animal)
        end
        spawnedAnimals = {}
        for _, ped in ipairs(spawnedPeds) do 
            spawner.deletePed(ped)
        end
        spawnedPeds = {}
        system.unregisterTick(TextTick)
        TextTick = nil
    end
end)


menu.addButton(misc, 'RESET FOLLOW LOGIC', 'If they break, press this.', function()
    for _, ped in ipairs(spawnedPeds) do
        if natives.entity_doesEntityExist(ped) then
            natives.task_clearPedTasksImmediately(ped)
            setFollow(ped, player.getLocalPed())
        end
    end
end)

menu.addButton('player', 'RESET FOLLOW LOGIC', 'If they break, press this.', function()
    for _, ped in ipairs(spawnedPeds) do
        if natives.entity_doesEntityExist(ped) then
            natives.task_clearPedTasksImmediately(ped)
            setFollow(ped, player.getLocalPed())
        end
    end
end)
wtf.lua



